//
//  Models.swift
//  Hackathon2025
//
//  Created by Daniel Nuno on 5/13/25.
//

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
    
    var description: String {
        switch self {
        case .energiaRenovable:
            return "% de electricidad renovable usada en la fabricación"
        case .embalajeReciclable:
            return "% de material reciclable/compostable en el empaque"
        case .reusoAgua:
            return "% de agua reutilizada vs 2020"
        case .huellaCarbono:
            return "Emisiones por unidad (cradle-to-gate)"
        case .impactoSocial:
            return "Personas beneficiadas por programas ligados a la marca"
        }
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

enum Category: String {
    case muyMalo = "Muy malo"
    case malo = "Malo"
    case regular = "Regular"
    case bueno = "Bueno"
    case muyBueno = "Muy bueno"
    
    var color: Color {
        switch self {
        case .muyMalo:
            return Color.red
        case .malo:
            return Color.orange
        case .regular:
            return Color.yellow
        case .bueno:
            return Color.green
        case .muyBueno:
            return Color.mint
        }
    }
    
    static func fromString(_ categoryString: String) -> Category? {
        switch categoryString.lowercased() {
        case "muy malo": return .muyMalo
        case "malo": return .malo
        case "regular": return .regular
        case "bueno": return .bueno
        case "muy bueno": return .muyBueno
        default: return nil
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
    
    var category: String {
        switch self {
        case .gansito, .mantecadas:
            return "Bollería Indulgente"
        case .takis:
            return "Botanas Picantes"
        }
    }
    
    var apiValue: String {
        switch self {
        case .mantecadas:
            return "Mantecadas"
        default:
            return self.rawValue
        }
    }
}


