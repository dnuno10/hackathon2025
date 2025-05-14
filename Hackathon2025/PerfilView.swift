import SwiftUI

// MARK: - Models

struct Amigo: Identifiable {
    let id = UUID()
    let nombre: String
    let imagen: String
    let racha: Int
}

struct Insignia: Identifiable {
    let id = UUID()
    let emoji: String
    let tituloKey: String
    let descripcionKey: String
}

// MARK: - Detail View

struct InsigniaDetailView: View {
    let insignia: Insignia
    @ObservedObject private var localizer = LocalizationManager.shared

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text(insignia.emoji)
                .font(.system(size: 120))
            Text(localizer.localizedString(forKey: insignia.tituloKey))
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
            Text(localizer.localizedString(forKey: insignia.descripcionKey))
                .font(.system(size: 20))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

// MARK: - Profile View

struct MyProfileView: View {
    @ObservedObject private var localizer = LocalizationManager.shared

    let nombreUsuario = "Axel Nuño"
    let rachaActual = 96
    let nivel = 33
    let experienciaActual = 88.0
    let experienciaMaxima = 100.0

    let amigos: [Amigo] = [
        Amigo(nombre: "Carlos", imagen: "imgFriend1", racha: 7),
        Amigo(nombre: "Ana", imagen: "imgFriend2", racha: 10),
        Amigo(nombre: "Pepe", imagen: "imgFriend3", racha: 3),
        Amigo(nombre: "María", imagen: "imgFriend4", racha: 32)
    ]

    let insignias: [Insignia] = [
        Insignia(emoji: "🛒", tituloKey: "badge_first_title", descripcionKey: "badge_first_desc"),
        Insignia(emoji: "🌱", tituloKey: "badge_eco_title", descripcionKey: "badge_eco_desc"),
        Insignia(emoji: "🏆", tituloKey: "badge_goal_title", descripcionKey: "badge_goal_desc"),
        Insignia(emoji: "🍎", tituloKey: "badge_healthy_title", descripcionKey: "badge_healthy_desc"),
        Insignia(emoji: "📦", tituloKey: "badge_packaging_title", descripcionKey: "badge_packaging_desc"),
        Insignia(emoji: "💧", tituloKey: "badge_water_title", descripcionKey: "badge_water_desc"),
        Insignia(emoji: "🌍", tituloKey: "badge_planet_title", descripcionKey: "badge_planet_desc"),
        Insignia(emoji: "⚡", tituloKey: "badge_speed_title", descripcionKey: "badge_speed_desc"),
        Insignia(emoji: "🎯", tituloKey: "badge_goal_title", descripcionKey: "badge_goal_desc")
    ]

    @State private var insigniaSeleccionada: Insignia? = nil
    @State private var experiencia: Double = 0.0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center, spacing: 24) {
                    Image("imgUser")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.4), lineWidth: 2))

                    VStack(alignment: .leading, spacing: 8) {
                        Text(nombreUsuario)
                            .foregroundColor(.white)
                            .font(.title)
                            .bold()

                        HStack(spacing: 24) {
                            VStack(alignment: .center) {
                                Text("\(nivel)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Nivel")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("🔥 \(rachaActual)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.orange)
                                Text(localizer.localizedString(forKey: "profile_friends_title"))
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .frame(height: 12)
                                    .foregroundColor(Color.white.opacity(0.2))
                                Capsule()
                                    .frame(width: CGFloat(experiencia / experienciaMaxima) * 140, height: 12)
                                    .foregroundColor(.white)
                                    .animation(.easeOut(duration: 1.2), value: experiencia)
                            }
                            Text("\(Int(experiencia))/\(Int(experienciaMaxima)) XP")
                                .font(.caption2)
                                .foregroundColor(.white)
                        }
                        .padding(.top, 4)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                experiencia = experienciaActual
                            }
                        }
                    }

                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0x12 / 255, green: 0xbe / 255, blue: 0x9e / 255),
                                    AppTheme.primary.opacity(0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            
                            )
                        )
                )
                .padding(.horizontal)


                // Sección de amigos
                Text(localizer.localizedString(forKey: "profile_friends_title"))
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

                // Sección de insignias
                Text(localizer.localizedString(forKey: "profile_badges_title"))
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
                                Text(localizer.localizedString(forKey: insignia.tituloKey))
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
        .navigationTitle(localizer.localizedString(forKey: "profile_title"))
        .sheet(item: $insigniaSeleccionada) { insignia in
            InsigniaDetailView(insignia: insignia)
                .presentationDetents([.fraction(0.75)])
                .id(insignia.id)
        }
    }
}
