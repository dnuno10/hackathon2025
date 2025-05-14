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
    let categoria: String
    let empresa: String
    let pais: String
}
import SwiftUI

struct CatalogoView: View {
    @State private var searchText = ""
    @State private var selectedCategorias: Set<String> = []
    @State private var selectedEmpresas: Set<String> = []
    @State private var selectedPaises: Set<String> = []
    @State private var productoSeleccionado: Producto? = nil
    @ObservedObject private var localizer = LocalizationManager.shared

    // Ejemplo de productos
    let productos: [Producto] = [
        Producto(nombre: "Gansito", imagen: "gansito", categoria: "Pastelitos", empresa: "Marinela", pais: "México"),
        Producto(nombre: "Canelitas", imagen: "canelitas", categoria: "Galletas", empresa: "Gamesa", pais: "México"),
        Producto(nombre: "Pan Bimbo", imagen: "panbimbo", categoria: "Pan", empresa: "Bimbo", pais: "México"),
        Producto(nombre: "Barritas Fresa", imagen: "barritasfresa", categoria: "Pastelitos", empresa: "Marinela", pais: "México"),
        Producto(nombre: "Donas Bimbo", imagen: "donasbimbo", categoria: "Pan dulce", empresa: "Bimbo", pais: "México"),
        Producto(nombre: "Mantecadas", imagen: "mantecadas", categoria: "Pan dulce", empresa: "Bimbo", pais: "México"),
        Producto(nombre: "Nito", imagen: "nito", categoria: "Pastelitos", empresa: "Marinela", pais: "México"),
        Producto(nombre: "Takis", imagen: "takis", categoria: "Botanas saladas", empresa: "Barcel", pais: "México"),
        Producto(nombre: "Rebanadas Bimbo", imagen: "rebanadasbimbo", categoria: "Pan dulce", empresa: "Bimbo", pais: "México"),
        Producto(nombre: "Tortillinas", imagen: "tortillinas", categoria: "Tortillas y flatbread", empresa: "Tía Rosa", pais: "México"),
        Producto(nombre: "Barritas Piña", imagen: "barritaspina", categoria: "Pastelitos", empresa: "Marinela", pais: "México"),
        Producto(nombre: "Donas Bimbo", imagen: "donasUSA", categoria: "Bollería", empresa: "Bimbo", pais: "Estados Unidos"),
        Producto(nombre: "Donut Española", imagen: "donutEsp", categoria: "Pan dulce", empresa: "Bimbo", pais: "España"),
        Producto(nombre: "Fango", imagen: "fangoArg", categoria: "Pan dulce", empresa: "Bimbo", pais: "Argentina"),
        Producto(nombre: "Hot Dog Buns", imagen: "hotdog", categoria: "Pan", empresa: "Bimbo", pais: "Estados Unidos"),
        Producto(nombre: "Little Bites", imagen: "littlebitesUSA", categoria: "Pastelitos", empresa: "Entenmann’s", pais: "Estados Unidos"),
        Producto(nombre: "Milpa Real Tortillas", imagen: "milpareal", categoria: "Tortillas y flatbed", empresa: "Milpa Real", pais: "México"),
        Producto(nombre: "Oatunt Muffins", imagen: "oatuntUSA", categoria: "Pan dulce", empresa: "Bimbo", pais: "Estados Unidos"),
        Producto(nombre: "Pingüinos", imagen: "pinguino", categoria: "Pastelitos", empresa: "Marinela", pais: "México"),
        Producto(nombre: "Runners", imagen: "runners", categoria: "Botanas saladas", empresa: "Bimbo", pais: "México")

        
    ]

    var categorias: [String] {
        Array(Set(productos.map { $0.categoria })).sorted()
    }
    var empresas: [String] {
        Array(Set(productos.map { $0.empresa })).sorted()
    }
    var paises: [String] {
        Array(Set(productos.map { $0.pais })).sorted()
    }

    var productosFiltrados: [Producto] {
        productos.filter { producto in
            let texto = searchText.lowercased()
            let matchesSearch = texto.isEmpty ||
                producto.nombre.lowercased().contains(texto) ||
                producto.categoria.lowercased().contains(texto) ||
                producto.empresa.lowercased().contains(texto) ||
                producto.pais.lowercased().contains(texto)
            let matchesCategoria = selectedCategorias.isEmpty || selectedCategorias.contains(producto.categoria)
            let matchesEmpresa = selectedEmpresas.isEmpty || selectedEmpresas.contains(producto.empresa)
            let matchesPais = selectedPaises.isEmpty || selectedPaises.contains(producto.pais)
            return matchesSearch && matchesCategoria && matchesEmpresa && matchesPais
        }
    }

    var body: some View {
        VStack {
            // SearchBar
            TextField(localizer.localizedString(forKey: "catalog_search_placeholder"), text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            // Filtros siempre visibles
            VStack(alignment: .leading, spacing: 8) {
                Text(localizer.localizedString(forKey: "catalog_filter_category"))
                    .font(.subheadline)
                    .padding(.leading)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(categorias, id: \.self) { categoria in
                            FilterChip(label: categoria, isSelected: selectedCategorias.contains(categoria)) {
                                if selectedCategorias.contains(categoria) {
                                    selectedCategorias.remove(categoria)
                                } else {
                                    selectedCategorias.insert(categoria)
                                }
                            }
                        }
                    }.padding(.horizontal)
                }

                Text(localizer.localizedString(forKey: "catalog_filter_company"))
                    .font(.subheadline)
                    .padding(.leading)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(empresas, id: \.self) { empresa in
                            FilterChip(label: empresa, isSelected: selectedEmpresas.contains(empresa)) {
                                if selectedEmpresas.contains(empresa) {
                                    selectedEmpresas.remove(empresa)
                                } else {
                                    selectedEmpresas.insert(empresa)
                                }
                            }
                        }
                    }.padding(.horizontal)
                }

                Text(localizer.localizedString(forKey: "catalog_filter_country"))
                    .font(.subheadline)
                    .padding(.leading)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(paises, id: \.self) { pais in
                            FilterChip(label: pais, isSelected: selectedPaises.contains(pais)) {
                                if selectedPaises.contains(pais) {
                                    selectedPaises.remove(pais)
                                } else {
                                    selectedPaises.insert(pais)
                                }
                            }
                        }
                    }.padding(.horizontal)
                }
            }
            .transition(.opacity)

            // Productos agrupados por empresa
            ScrollView {
                ForEach(empresas, id: \.self) { empresa in
                    let productosEmpresa = productosFiltrados.filter { $0.empresa == empresa }
                    Group {
                        if !productosEmpresa.isEmpty {
                            Section(header: Text(empresa).font(.headline).padding(.leading)) {
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                                    ForEach(productosEmpresa) { producto in
                                        Button(action: {
                                            productoSeleccionado = producto
                                        }) {
                                            VStack {
                                                Image(producto.imagen)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 100)
                                                Text(producto.nombre)
                                                    .font(.caption)
                                            }
                                            .padding()
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(localizer.localizedString(forKey: "catalog_title"))
        .sheet(item: $productoSeleccionado) { producto in
            if let productType = ProductType.fromNombre(producto.nombre) {
                BimboSustainabilityMetricsView(product: productType)
                    .presentationDetents([.fraction(1)])
            } else {
                CatalogoNoInfoView(producto: producto)
                    .presentationDetents([.fraction(1)])
            }
        }
    }
}

// Chip de filtro reutilizable
struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

// Extension para ProductType
extension ProductType {
    static func fromNombre(_ nombre: String) -> ProductType? {
        ProductType.allCases.first { $0.apiValue.lowercased() == nombre.lowercased() }
    }
}

// Nueva vista para productos sin información
struct CatalogoNoInfoView: View {
    let producto: Producto
    @ObservedObject private var localizer = LocalizationManager.shared
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 20) {
                    Image(producto.imagen)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 240)
                        .padding(.top, 20)
                    
                    Text(producto.nombre)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.bottom, 8)
                    
                    Text(producto.categoria)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color("1976D2"))
                        )
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.2),
                            Color.blue.opacity(0.8)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedCorner(radius: 32, corners: [.bottomLeft, .bottomRight]))
                )

                InfoPanel(text: localizer.localizedString(forKey: "catalog_no_data_message"))
            }
            .padding(.bottom, 24)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color("F5F7FA"), Color("E4EAF6")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle(localizer.localizedString(forKey: "catalog_no_data_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
