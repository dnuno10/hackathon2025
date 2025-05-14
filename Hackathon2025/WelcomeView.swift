import SwiftUI

struct WelcomeView: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var localizer = LocalizationManager.shared

    let languages = [
        "es": "🇲🇽 Español",
        "en": "🇺🇸 English",
        "fr": "🇫🇷 Français"
    ]
    let languages_flag = [
        "es": "🇲🇽",
        "en": "🇺🇸",
        "fr": "🇫🇷"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                VStack(spacing: AppTheme.largePadding) {
                    HStack(spacing: 12) {
                        Spacer()
                        Menu {
                            ForEach(languages.keys.sorted(), id: \.self) { code in
                                Button {
                                    localizer.currentLanguage = code
                                } label: {
                                    Text("\(languages[code] ?? code)")
                                }
                            }
                        } label: {
                            Text(languages_flag[localizer.currentLanguage] ?? "🌐")
                                .font(.system(size: 36, weight: .bold))
                                .padding(8)
                        }
                        
                        .foregroundColor(AppTheme.textPrimary)
                        .cornerRadius(8)
                        ThemeToggleButton()

                        
                    }
                    .padding(.top)

                    Spacer()

                    VStack(spacing: AppTheme.smallPadding) {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)

                        Text(localizer.localizedString(forKey: "app_title"))
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                    }

                    VStack(spacing: AppTheme.padding) {
                        Text(localizer.localizedString(forKey: "welcome_slogan"))
                            .font(.title2.weight(.semibold))
                            .multilineTextAlignment(.center)
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "#34cea3"),
                                        Color(hex: "#5cdca4"),
                                        Color(hex: "#5cdca4"),
                                        Color(hex: "#34cea3"),
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .mask(
                                    Text(localizer.localizedString(forKey: "welcome_slogan"))
                                        .font(.title2.weight(.semibold))
                                        .multilineTextAlignment(.center)
                                )
                            )
                    }

                    Spacer()
                    Spacer()

                    VStack(spacing: 8) {
                        HStack {
                            Text("🌱").font(.system(size: 36, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Text("📦").font(.system(size: 36, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Text("💧").font(.system(size: 36, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                        }

                        Text(localizer.localizedString(forKey: "badge_info"))
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    }

                    VStack(spacing: AppTheme.padding) {
                        NavigationLink {
                            CameraView().toolbarRole(.editor)

                        } label: {
                            Text(localizer.localizedString(forKey: "start_button"))
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0x12 / 255, green: 0xbe / 255, blue: 0x9e / 255),
                                            AppTheme.primary.opacity(0.6)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(AppTheme.cornerRadius)
                        }
                    }
                    .padding(.horizontal)

                }
                .padding()
            }
            .navigationBarHidden(true)
            .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        }
    }
}
