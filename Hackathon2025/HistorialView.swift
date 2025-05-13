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

// Vista de historial estilo Pokédex
struct HistorialView: View {
    // Aquí recibimos los nombres de productos escaneados desde la vista principal
    let productosEscaneados: [String]

    // Simulamos un catálogo completo de productos posibles
    let todosLosProductos: [Producto] = [
        Producto(nombre: "Pan Integral", imagen: "diamond", escaneado: false),
        Producto(nombre: "Donas Bimbo", imagen: "diamond", escaneado: false),
        Producto(nombre: "Pan Blanco", imagen: "diamond", escaneado: false),
        Producto(nombre: "Pan Tostado", imagen: "diamond", escaneado: false)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                // Vamos creando una versión actualizada de cada producto según si fue escaneado o no
                ForEach(todosLosProductos.map { producto in
                    Producto(
                        nombre: producto.nombre,
                        imagen: producto.imagen,
                        escaneado: productosEscaneados.contains(producto.nombre)
                    )
                }) { producto in
                    VStack {
                        if producto.escaneado {
                            // Si fue escaneado, mostramos imagen normal y habilitamos clic
                            Button(action: {
                                // Aquí luego podemos conectar con otra vista
                                print("Viendo detalle de \(producto.nombre)")
                            }) {
                                Image(producto.imagen)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 120)
                            }
                        } else {
                            // Si no ha sido escaneado, mostramos imagen en grises
                            Image(producto.imagen)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 120)
                                .grayscale(1.0)
                                .opacity(0.4)
                        }

                        // Mostramos el nombre con color según estado
                        Text(producto.nombre)
                            .font(.caption)
                            .foregroundColor(producto.escaneado ? .primary : .gray)
                    }
                    .padding()
                }
            }
            .padding()
        }
        .navigationTitle("Historial")
    }
}

// Ejemplo de vista previa para desarrollo
struct HistorialView_Previews: PreviewProvider {
    static var previews: some View {
        // Probamos simulando que solo se ha escaneado "Pan Integral"
        HistorialView(productosEscaneados: ["Pan Integral"])
    }
}
