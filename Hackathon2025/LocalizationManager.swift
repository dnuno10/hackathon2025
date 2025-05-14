//
//  LocalizationManager.swift
//  Hackathon2025
//
//  Created by Daniel Nuno on 5/13/25.
//

import Foundation
import SwiftUI

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"

    var currentLanguageCode: String {
        return currentLanguage
    }

    func localizedString(forKey key: String) -> String {
        guard let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(key, comment: "")
        }
        return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
    }

    func setLanguage(_ code: String) {
        if currentLanguage != code {
            currentLanguage = code
        }
    }
}
