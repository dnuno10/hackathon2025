//
//  PerfilView.swift
//  Hackathon2025
//
//  Created by Daniel Nuno on 5/13/25.
//

import SwiftUI

// Datos simulados
struct Amigo: Identifiable {
    let id = UUID()
    let nombre: String
    let imagen: String
    let racha: Int
}

struct Insignia: Identifiable {
    let id = UUID()
    let emoji: String
    let titulo: String
    let descripcion: String
}

struct InsigniaDetailView: View {
    let insignia: Insignia

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text(insignia.emoji)
                .font(.system(size: 120))
            Text(insignia.titulo)
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
            Text(insignia.descripcion)
                .font(.system(size: 20))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

// Vista de perfil
struct MyProfileView: View {
    let nombreUsuario = "Axel Nuño"
    let rachaActual = 96 // En días

    let amigos = [
        Amigo(nombre: "Carlos", imagen: "imgFriend1", racha: 7),
        Amigo(nombre: "Ana", imagen: "imgFriend2", racha: 10),
        Amigo(nombre: "Pepe", imagen: "imgFriend3", racha: 3),
        Amigo(nombre: "María", imagen: "imgFriend4", racha: 32)
    ]

    let insignias = [
        Insignia(emoji: "🔥", titulo: "Racha encendida", descripcion: "Llevas más de 3 días escaneando."),
        Insignia(emoji: "🌱", titulo: "Eco Explorer", descripcion: "Escaneaste tu primer producto ecológico."),
        Insignia(emoji: "🏆", titulo: "Primer logro", descripcion: "Registraste tu primer producto."),
        Insignia(emoji: "🍎", titulo: "Nutri Ninja", descripcion: "Escaneaste 10 productos saludables."),
        Insignia(emoji: "📦", titulo: "Empaque Experto", descripcion: "Identificaste 5 productos con empaque reciclable."),
        Insignia(emoji: "💧", titulo: "Hidratado", descripcion: "Escaneaste 3 bebidas saludables."),
        Insignia(emoji: "🌍", titulo: "Amigo del Planeta", descripcion: "Escaneaste 10 productos ecológicos."),
        Insignia(emoji: "⚡", titulo: "Velocidad Máxima", descripcion: "Escaneaste 5 productos en menos de un minuto."),
        Insignia(emoji: "🎯", titulo: "Objetivo Cumplido", descripcion: "Completaste tu primera meta semanal."),
    ]

    @State private var insigniaSeleccionada: Insignia? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Encabezado con perfil y racha
                HStack(alignment: .center, spacing: 36) {
                    Image("imgUser")
                        .resizable()
                        .frame(width: 120, height: 120) // Increased size
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.4), lineWidth: 2)) // Slightly thicker border

                    VStack(alignment: .leading, spacing: 8) { // Increased spacing
                        Text(nombreUsuario)
                            .font(.title) // Larger font
                            .bold()
                        Text("🔥 \(rachaActual)")
                            .font(.title3) // Larger font
                            .foregroundColor(.orange)
                    }
                    Spacer()
                }
                .padding(.horizontal)

                // Rachas de amigos
                Text("Tus Rachas 🔥")
                    .font(.headline)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(amigos) { amigo in
                            VStack {
                                Image(amigo.imagen)
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                                Text(amigo.nombre)
                                    .font(.caption)
                                    .bold()
                                Text("🔥 \(amigo.racha)")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal)
                }

                Text("Tus Insignias 🎖️")
                    .font(.headline)
                    .padding(.horizontal)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 16)], spacing: 16) {
                    ForEach(insignias) { insignia in
                        Button(action: {
                            insigniaSeleccionada = insignia
                        }) {
                            VStack {
                                Text(insignia.emoji)
                                    .font(.system(size: 36))
                                Text(insignia.titulo)
                                    .font(.caption)
                                    .bold()
                                    .multilineTextAlignment(.center)
                            }
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }   
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Mi Perfil")
        .sheet(item: $insigniaSeleccionada) { insignia in
            InsigniaDetailView(insignia: insignia)
                .presentationDetents([.fraction(0.75)])
                .id(insignia.id) // Identificar cada modal por su insignia
        }
    }
}
