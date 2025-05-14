import Foundation
import SwiftUI

// MARK: - Data Models

struct SustainabilityMetric: Identifiable {
    let id = UUID()
    let indicatorCode: IndicatorCode
    let numericValue: Double
    let category: Category
    let dailyEquivalent: String
    let source: String
    
    var isPositiveIndicator: Bool {
        indicatorCode != .huellaCarbono
    }
}

enum IndicatorCode: String, CaseIterable {
    case energiaRenovable = "ENERGÍA_RENOVABLE"
    case embalajeReciclable = "EMBALAJE_RECICLABLE"
    case reusoAgua = "REUSO_AGUA"
    case huellaCarbono = "HUELLA_CARBONO"
    case impactoSocial = "IMPACTO_SOCIAL"

    var descriptionKey: String {
        return "desc_\(rawValue.lowercased())"
    }
    
    var unit: String {
        switch self {
        case .energiaRenovable, .embalajeReciclable, .reusoAgua:
            return "%"
        case .huellaCarbono:
            return "g CO₂-e"
        case .impactoSocial:
            return ""
        }
    }
    
    var icon: String {
        switch self {
        case .energiaRenovable:
            return "bolt.fill"
        case .embalajeReciclable:
            return "arrow.3.trianglepath"
        case .reusoAgua:
            return "drop.fill"
        case .huellaCarbono:
            return "smoke.fill"
        case .impactoSocial:
            return "person.3.fill"
        }
    }
    
    static func fromString(_ codeString: String) -> IndicatorCode? {
        return IndicatorCode.allCases.first { $0.rawValue == codeString }
    }
}

enum Category: String, CaseIterable {
    case muyMalo = "Muy malo"
    case malo = "Malo"
    case regular = "Regular"
    case bueno = "Bueno"
    case muyBueno = "Muy bueno"
    
    var color: Color {
        switch self {
        case .muyMalo:
            return .red
        case .malo:
            return .orange
        case .regular:
            return .yellow
        case .bueno:
            return .green
        case .muyBueno:
            return .mint
        }
    }

    var localizedKey: String {
        return rawValue.lowercased().replacingOccurrences(of: " ", with: "_")
    }
    
    static func fromString(_ categoryString: String) -> Category? {
        let normalized = categoryString.lowercased()
        return Category.allCases.first {
            $0.rawValue.lowercased() == normalized
        }
    }
}

enum ProductType: String, CaseIterable {
    case gansito = "Gansito"
    case mantecadas = "Mantecadas"
    case takis = "Takis"
    
    var image: String {
        return rawValue.lowercased()
    }
    
    var categoryKey: String {
        switch self {
        case .gansito, .mantecadas:
            return "category_bolleria"
        case .takis:
            return "category_botanas"
        }
    }

    var localizedKey: String {
        return "product_\(rawValue.lowercased().replacingOccurrences(of: " ", with: "_"))"
    }
    
    var apiValue: String {
        switch self {
        case .mantecadas:
            return "Mantecadas"
        default:
            return rawValue
        }
    }
}
