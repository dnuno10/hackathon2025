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

        // Camera input
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .back),
              let input = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(input) else {
            setError("No se pudo acceder a la cámara")
            session.commitConfiguration()
            return
        }
        session.addInput(input)

        // Photo output
        guard session.canAddOutput(photoOutput) else {
            setError("No se pudo configurar la salida de foto")
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
            setError("Error al cargar el modelo: \(error.localizedDescription)")
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
        let request = VNCoreMLRequest(model: classifier) { [weak self] req, err in
            defer { DispatchQueue.main.async { self?.isProcessingImage = false } }
            guard let self = self,
                  let results = req.results as? [VNClassificationObservation],
                  let top = results.first,
                  top.confidence > 0.8 else { return }

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
            setError("Error al capturar foto: \(error.localizedDescription)")
            return
        }
        guard let data = photo.fileDataRepresentation(),
              let uiImage = UIImage(data: data),
              let cgImage = uiImage.cgImage else {
            setError("Error al procesar la imagen capturada")
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
        if let conn = view.previewLayer.connection,
           conn.isVideoOrientationSupported {
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
                            Text("Presiona para tomar foto")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(8)
                        }
                        .padding(.bottom, 120)
                    }

                    Button(action: {
                        showGuide = false
                        vm.capturePhoto()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 70, height: 70)
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 85, height: 85)
                        }
                    }
                    .disabled(vm.isProcessingImage)
                    .padding(.bottom, 40)
                }

                if vm.isProcessingImage {
                    Color.black.opacity(0.6).edgesIgnoringSafeArea(.all)
                    ProgressView("Analizando…")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .foregroundColor(.white)
                        .scaleEffect(1.5)
                }

                
            }.sheet(isPresented: $vm.showProductView, onDismiss: {
                vm.resumeSession()
            }) {
                if let product = vm.detectedProduct {
                    BimboSustainabilityMetricsView(product: product)
                }
            }

            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Captura Producto")
                        .foregroundColor(.white)
                        .font(.headline)
                }
            }

            .alert(isPresented: $vm.showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(vm.errorMessage ?? "Error desconocido"),
                    dismissButton: .default(Text("OK")) {
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
            CameraView()
        }
    }
}
