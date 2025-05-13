// //
// //  His.swift
// //  Hackathon2025
// //
// //  Created by Daniel Nuno on 5/13/25.
// //

// import SwiftUI


// struct HistorialView: View {
//     let productosEscaneados: [String] // Puedes eliminar si ya no lo usas

//     @State private var productoSeleccionado: Producto? = nil
//     @State private var mostrarAlerta = false
//     @State private var mensajeAlerta = ""

//     let todosLosProductos: [Producto] = [
//         Producto(nombre: "Gansito", imagen: "gansito", escaneado: true),
//         Producto(nombre: "Barritas Fresa", imagen: "barritasfresa", escaneado: false),
//         Producto(nombre: "Canelitas", imagen: "canelitas", escaneado: false),
//         Producto(nombre: "Donas Bimbo", imagen: "donasbimbo", escaneado: false),
//         Producto(nombre: "Mantecadas", imagen: "mantecadas", escaneado: true),
//         Producto(nombre: "Nito", imagen: "nito", escaneado: false),
//         Producto(nombre: "Pan Bimbo", imagen: "panbimbo", escaneado: false),
//         Producto(nombre: "Takis", imagen: "takis", escaneado: false),
//         Producto(nombre: "Rebanadas Bimbo", imagen: "rebanadasbimbo", escaneado: false),
//         Producto(nombre: "Tortillinas", imagen: "tortillinas", escaneado: false)
//     ]

//     var body: some View {
//         ScrollView {
//             LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
//                 ForEach(todosLosProductos) { producto in
//                     Button(action: {
//                         productoSeleccionado = producto
//                     }) {
//                         VStack {
//                             Image(producto.imagen)
//                                 .resizable()
//                                 .scaledToFit()
//                                 .frame(height: 120)
//                             Text(producto.nombre)
//                                 .font(.caption)
//                                 .foregroundColor(.primary)
//                         }
//                     }
//                     .buttonStyle(PlainButtonStyle())
//                 }
//             }
//             .padding()
//         }
//         .navigationTitle("Historial")
//         .sheet(item: $productoSeleccionado) { producto in
//             if let productType = ProductType.fromNombre(producto.nombre) {
//                 BimboSustainabilityMetricsView(product: productType)
//                     .presentationDetents([.fraction(1)])
//             } else {
//                 Text("No hay información de sostenibilidad para este producto.")
//                     .padding()
//             }
//         }
//     }
// }

// // Asegúrate de que ProductType.fromNombre funcione así:
// extension ProductType {
//     static func fromNombre(_ nombre: String) -> ProductType? {
//         ProductType.allCases.first { $0.apiValue.lowercased() == nombre.lowercased() }
//     }
// }
