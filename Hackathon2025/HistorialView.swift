//
//  His.swift
//  Hackathon2025
//
//  Created by Daniel Nuno on 5/13/25.
//

import SwiftUI

// Modelo básico de producto
struct Producto: Identifiable {
    let id = UUID()
    let nombre: String
    let imagen: String
    var escaneado: Bool
}

struct HistorialView: View {
    let productosEscaneados: [String]

    @State private var productoSeleccionado: Producto? = nil
    @State private var mostrarAlerta = false
    @State private var mensajeAlerta = ""

    let todosLosProductos: [Producto] = [
        Producto(nombre: "Gansito", imagen: "gansito", escaneado: true),
        Producto(nombre: "Barritas Fresa", imagen: "barritasfresa", escaneado: false),
        Producto(nombre: "Canelitas", imagen: "canelitas", escaneado: false),
        Producto(nombre: "Donas Bimbo", imagen: "donasbimbo", escaneado: false),
        Producto(nombre: "Mantecadas", imagen: "mantecadas", escaneado: true),
        Producto(nombre: "Nito", imagen: "nito", escaneado: false),
        Producto(nombre: "Pan Bimbo", imagen: "panbimbo", escaneado: false),
        Producto(nombre: "Takis", imagen: "takis", escaneado: false),
        Producto(nombre: "Rebanadas Bimbo", imagen: "rebanadasbimbo", escaneado: false),
        Producto(nombre: "Tortillinas", imagen: "tortillinas", escaneado: false)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                ForEach(todosLosProductos.map { producto in
                    Producto(
                        nombre: producto.nombre,
                        imagen: producto.imagen,
                        escaneado: producto.escaneado || productosEscaneados.contains(producto.nombre)
                    )
                }) { producto in
                    VStack {
                        if (producto.escaneado) {
                            Button(action: {
                                productoSeleccionado = producto
                            }) {
                                Image(producto.imagen)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 120)
                            }
                        } else {
                            Image(producto.imagen)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 120)
                                .grayscale(1.0)
                                .opacity(0.4)
                                .onTapGesture {
                                    mensajeAlerta = "¡Aún no has escaneado este producto! Sigue registrando tus compras para descubrir más información"
                                    mostrarAlerta = true
                                }
                        }
                        Text(producto.nombre)
                            .font(.caption)
                            .foregroundColor(producto.escaneado ? .primary : .gray)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Historial")
        .sheet(item: $productoSeleccionado) { producto in
            if let productType = ProductType.fromNombre(producto.nombre) {
                BimboSustainabilityMetricsView(product: productType)
                    .presentationDetents([.fraction(1)])
            } else {
                Text("No hay información de sostenibilidad para este producto.")
                    .padding()
            }
        }
        .alert(isPresented: $mostrarAlerta) {
            Alert(
                title: Text("¡Sigue explorando! 🚀"),
                message: Text(mensajeAlerta),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

// Asegúrate de que ProductType.fromNombre funcione así:
extension ProductType {
    static func fromNombre(_ nombre: String) -> ProductType? {
        ProductType.allCases.first { $0.apiValue.lowercased() == nombre.lowercased() }
    }
}
