//
//  ThemeConstants.swift
//  Hackathon2025
//
//  Created by Daniel Nuno on 5/13/25.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64

        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17,
                                 (int >> 4 & 0xF) * 17,
                                 (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16,
                                 int >> 8 & 0xFF,
                                 int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24,
                           int >> 16 & 0xFF,
                           int >> 8 & 0xFF,
                           int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}





class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    private let themeKey = "app_theme_mode"
    // we run didSet each time the value from isDarkMode change
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: themeKey)
        }
    }
    // we read de value saved in the key "app_theme_mode"
    private init() {
        self.isDarkMode = UserDefaults.standard.object(forKey: themeKey) as? Bool ?? false
    }
    func toggleTheme() {
        isDarkMode.toggle()
    }

    var primary: Color {
        Color(hex: "0099FF")
    }
    
    var secondary: Color {
        Color(hex: "4ECDC4")
    }

    var accent: Color {
        Color(hex: "FF6B6B")
    }

    var background: Color {
        isDarkMode ? Color(hex: "1C1C1E") : Color(hex: "F7F7FF")
    }

    var cardBackground: Color {
        isDarkMode ? Color(hex: "2C2C2E") : Color(hex: "FFFFFF")
    }

    var textPrimary: Color {
        isDarkMode ? Color(hex: "F5F5F7") : Color(hex: "2A2D34")
    }

    var textSecondary: Color {
        isDarkMode ? Color(hex: "AFAFB4") : Color(hex: "6B6E76")
    }
}

struct AppTheme {
    static var primary: Color {
        ThemeManager.shared.primary
    }

    static var secondary: Color {
        ThemeManager.shared.secondary
    }

    static var accent: Color {
        ThemeManager.shared.accent
    }

    static var background: Color {
        ThemeManager.shared.background
    }

    static var cardBackground: Color {
        ThemeManager.shared.cardBackground
    }

    static var textPrimary: Color {
        ThemeManager.shared.textPrimary
    }

    static var textSecondary: Color {
        ThemeManager.shared.textSecondary
    }
    
    static let cornerRadius: CGFloat = 12
    static let padding: CGFloat = 16
    static let smallPadding: CGFloat = 8
    static let largePadding: CGFloat = 24
}

struct ThemeToggleButton: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        Button {
            themeManager.toggleTheme()
        } label: {
            Image(systemName: themeManager.isDarkMode ? "sun.max.fill" : "moon.fill")
                .font(.system(size: 20))
                .foregroundColor(themeManager.isDarkMode ? .yellow : AppTheme.textPrimary)
                .padding(8)
                .background(
                    Circle()
                        .fill(themeManager.isDarkMode ? AppTheme.cardBackground : Color.clear)
                        .overlay(
                            Circle()
                                .stroke(themeManager.isDarkMode ? Color.clear : AppTheme.textSecondary.opacity(0.3), lineWidth: 1)
                        )
                )
        }
    }
}
