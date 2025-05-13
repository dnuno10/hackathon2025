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

// Vista de perfil
struct MyProfileView: View {
    let nombreUsuario = "Alex González"
    let rachaActual = 5 // En días

    let amigos = [
        Amigo(nombre: "María", imagen: "perfil_amigo1", racha: 7),
        Amigo(nombre: "Carlos", imagen: "perfil_amigo2", racha: 3),
        Amigo(nombre: "Ana", imagen: "perfil_amigo3", racha: 10)
    ]

    let insignias = [
        Insignia(emoji: "🔥", titulo: "Racha encendida", descripcion: "Llevas más de 3 días escaneando."),
        Insignia(emoji: "🌱", titulo: "Eco Explorer", descripcion: "Escaneaste tu primer producto ecológico."),
        Insignia(emoji: "🏆", titulo: "Primer logro", descripcion: "Registraste tu primer producto.")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Encabezado con perfil y racha
                HStack(alignment: .center, spacing: 16) {
                    Image("perfil_usuario")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.4), lineWidth: 1))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(nombreUsuario)
                            .font(.title2)
                            .bold()
                        Text("🔥 Racha actual: \(rachaActual) días")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                    Spacer()
                }
                .padding(.horizontal)

                // Rachas de amigos
                Text("Rachas de amigos")
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
                                Text("\(amigo.racha) días")
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

                // Insignias del usuario
                Text("Insignias obtenidas")
                    .font(.headline)
                    .padding(.horizontal)

                VStack(spacing: 12) {
                    ForEach(insignias) { insignia in
                        HStack(alignment: .center, spacing: 12) {
                            Text(insignia.emoji)
                                .font(.largeTitle)

                            VStack(alignment: .leading) {
                                Text(insignia.titulo)
                                    .font(.subheadline)
                                    .bold()
                                Text(insignia.descripcion)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Mi Perfil")
    }
}
// Vista previa para desarrollo
