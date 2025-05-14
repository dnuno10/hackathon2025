//
//  Hackathon2025App.swift
//  Hackathon2025
//
//  Created by Daniel Nuno on 5/13/25.
//

import SwiftUI
import AVFoundation
import Vision
import CoreML
import UIKit

final class CameraPreviewUIView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}

@MainActor
class CameraViewModel: NSObject, ObservableObject {
    @Published var detectedProduct: ProductType?
    @Published var isProcessingImage = false
    @Published var showProductView = false
    @Published var errorMessage: String?
    @Published var showError = false

    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var productClassifier: VNCoreMLModel?

    override init() {
        super.init()
        setupCaptureSession()
        setupClassifier()
    }

    private func setupCaptureSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(input) else {
            setError(LocalizationManager.shared.localizedString(forKey: "camera_access_error"))
            session.commitConfiguration()
            return
        }

        session.addInput(input)

        guard session.canAddOutput(photoOutput) else {
            setError(LocalizationManager.shared.localizedString(forKey: "photo_output_error"))
            session.commitConfiguration()
            return
        }

        session.addOutput(photoOutput)
        session.commitConfiguration()

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }

    private func setupClassifier() {
        do {
            let config = MLModelConfiguration()
            let mlModel = try BimboML(configuration: config)
            productClassifier = try VNCoreMLModel(for: mlModel.model)
        } catch {
            setError("\(LocalizationManager.shared.localizedString(forKey: "model_loading_error")): \(error.localizedDescription)")
        }
    }

    func capturePhoto() {
        guard !isProcessingImage else { return }
        isProcessingImage = true
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    private func classify(_ cgImage: CGImage) {
        guard let classifier = productClassifier else {
            DispatchQueue.main.async { self.isProcessingImage = false }
            return
        }

        let request = VNCoreMLRequest(model: classifier) { [weak self] req, _ in
            defer { DispatchQueue.main.async { self?.isProcessingImage = false } }

            guard let self = self,
                  let results = req.results as? [VNClassificationObservation],
                  let top = results.first, top.confidence > 0.8 else {
                return
            }

            let id = top.identifier.lowercased()
            if let product = ProductType.allCases.first(where: { $0.apiValue.lowercased() == id }) {
                DispatchQueue.main.async {
                    self.detectedProduct = product
                    self.showProductView = true
                    self.session.stopRunning()
                }
            }
        }

        request.imageCropAndScaleOption = .centerCrop
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }

    private func setError(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.showError = true
            self.isProcessingImage = false
        }
    }

    func resumeSession() {
        if !session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.startRunning()
            }
        }
    }
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let error = error {
            setError("\(LocalizationManager.shared.localizedString(forKey: "capture_error")): \(error.localizedDescription)")
            return
        }

        guard let data = photo.fileDataRepresentation(),
              let uiImage = UIImage(data: data),
              let cgImage = uiImage.cgImage else {
            setError(LocalizationManager.shared.localizedString(forKey: "image_processing_error"))
            return
        }

        classify(cgImage)
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.backgroundColor = .black
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        if let conn = view.previewLayer.connection, conn.isVideoOrientationSupported {
            conn.videoOrientation = .portrait
        }
        return view
    }

    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {
        uiView.previewLayer.frame = uiView.bounds
    }
}

struct CameraView: View {
    @StateObject private var vm = CameraViewModel()
    @State private var showGuide = true
    @ObservedObject private var localizer = LocalizationManager.shared

    var body: some View {
        NavigationView {
            ZStack {
                CameraPreviewView(session: vm.session)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()

                    if showGuide {
                        VStack(spacing: 16) {
                            Image(systemName: "camera")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                            Text(localizer.localizedString(forKey: "camera_guide"))
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.35))
                                .cornerRadius(16)
                        }
                        .padding(.bottom, 70)
                    }

                    Button(action: {
                        showGuide = false
                        vm.capturePhoto()
                    }) {
                        ZStack {
                            Circle().fill(Color.white).frame(width: 70, height: 70)
                            Circle().stroke(Color.white, lineWidth: 2).frame(width: 85, height: 85)
                        }
                    }
                    .disabled(vm.isProcessingImage)
                    .padding(.bottom, 40)
                }

                if vm.isProcessingImage {
                    Color.black.opacity(0.6).edgesIgnoringSafeArea(.all)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
            }
            .sheet(isPresented: $vm.showProductView, onDismiss: {
                vm.resumeSession()
            }) {
                if let product = vm.detectedProduct {
                    BimboSustainabilityMetricsView(product: product)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(localizer.localizedString(forKey: "camera_title"))
                        .foregroundColor(.white)
                        .font(.system(size: 23, weight: .semibold))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 7) {
                        NavigationLink(destination: CatalogoView().toolbarRole(.editor)
) {
                            Image(systemName: "magnifyingglass.circle.fill")
                                .font(.system(size: 25))
                                .foregroundColor(.white)
                        }
                        NavigationLink(destination: MyProfileView().toolbarRole(.editor)
) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 25))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .alert(isPresented: $vm.showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(vm.errorMessage ?? localizer.localizedString(forKey: "unknown_error")),
                    dismissButton: .default(Text(localizer.localizedString(forKey: "ok_button"))) {
                        vm.resumeSession()
                    }
                )
            }
        }
    }
}

@main
struct Hackathon2025App: App {
    var body: some Scene {
        WindowGroup {
            WelcomeView()
        }
    }
}
