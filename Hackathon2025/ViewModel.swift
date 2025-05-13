//
//  ViewModel.swift
//  Hackathon2025
//
//  Created by Daniel Nuno on 5/13/25.
//

import SwiftUI

// MARK: - API Service

class APIService {
    private let apiUrl = "https://agent.clicknote.app/api/v1/prediction/33885e0f-ce3b-4571-96f1-4d964fb68ebb"
    private let authToken = "Bearer zGFjcQG8a_Dqs_P0GiGMUT3Q1LPVfMypKHvPThnTsPI"
    
    func queryModel(productName: String) async throws -> String {
        let data = ["question": productName]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: URL(string: apiUrl)!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(authToken, forHTTPHeaderField: "Authorization")
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        print("API HTTP response: \(response)")
        
        if let responseString = String(data: responseData, encoding: .utf8) {
            print("API raw response string: \(responseString)")
        }
        
        guard let responseDict = try JSONSerialization.jsonObject(with: responseData) as? [String: Any] else {
            throw URLError(.cannotParseResponse)
        }
        
        print("API response dict: \(responseDict)")
        
        if let responseText = responseDict["text"] as? String {
            return responseText
        } else if let responseText = responseDict["response"] as? String {
            return responseText
        } else if let responseArray = responseDict["responses"] as? [String], !responseArray.isEmpty {
            return responseArray.joined()
        } else {
            print("Could not parse API response, using mock data")
            return createMockResponse(for: productName)
        }
    }
    
    private func createMockResponse(for productName: String) -> String {
        switch productName.lowercased() {
        case "gansito":
            return "§ENERGÍA_RENOVABLE｜97｜Muy bueno｜Como alimentar 1,000 hogares por un día｜Annual Report 2023, p. 42§§EMBALAJE_RECICLABLE｜92｜Muy bueno｜Equivale a salvar 60 árboles por tonelada｜Comunicado 26-ene-2024§§REUSO_AGUA｜60｜Bueno｜Ahorro de 15,000 litros diarios｜Annual Report 2023, p. 90§§HUELLA_CARBONO｜25｜Bueno｜Equivale a un viaje de 1km en auto｜Annual Report 2023, p. 45§"
        case "mantecadas":
            return "§ENERGÍA_RENOVABLE｜97｜Muy bueno｜Como alimentar 1,200 hogares por un día｜Annual Report 2023, p. 43§§EMBALAJE_RECICLABLE｜90｜Muy bueno｜Equivale a salvar 55 árboles por tonelada｜Comunicado 26-ene-2024§§REUSO_AGUA｜62｜Bueno｜Ahorro de 16,000 litros diarios｜Annual Report 2023, p. 92§§HUELLA_CARBONO｜28｜Bueno｜Equivale a un viaje de 1.2km en auto｜Annual Report 2023, p. 46§"
        case "takis":
            return "§ENERGÍA_RENOVABLE｜97｜Muy bueno｜Equivale a plantar 500 árboles al año｜Annual Report 2023, p. 44§§EMBALAJE_RECICLABLE｜92｜Muy bueno｜Reducción de 30 toneladas de plástico｜Comunicado 26-ene-2024§§REUSO_AGUA｜55｜Regular｜Como llenar 11,000 botellas de 1L diarias｜Annual Report 2023, p. 91§§HUELLA_CARBONO｜30｜Bueno｜Equivalente a 2km en autobús｜Annual Report 2023, p. 47§"
        default:
            return "§ENERGÍA_RENOVABLE｜95｜Muy bueno｜Energía para 900 hogares por un día｜Annual Report 2023, p. 40§§EMBALAJE_RECICLABLE｜88｜Muy bueno｜Equivale a salvar 50 árboles por tonelada｜Comunicado 26-ene-2024§§REUSO_AGUA｜58｜Regular｜Ahorro de 14,000 litros diarios｜Annual Report 2023, p. 89§§HUELLA_CARBONO｜32｜Bueno｜Equivale a un viaje de 1.5km en auto｜Annual Report 2023, p. 44§"
        }
    }
    
    func parseMetrics(from response: String) -> [SustainabilityMetric] {
        var metrics: [SustainabilityMetric] = []
        
        print("Raw API response: \(response)")
        
        let pattern = "§([^§]+)§"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let nsString = response as NSString
        let matches = regex?.matches(in: response, options: [], range: NSRange(location: 0, length: nsString.length))
        
        matches?.forEach { match in
            if match.numberOfRanges > 1 {
                let metricString = nsString.substring(with: match.range(at: 1))
                
                let fields = metricString.components(separatedBy: "｜")
                
                if fields.count == 5 {
                    let indicatorCodeStr = fields[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    let numericValueStr = fields[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    let categoryStr = fields[2].trimmingCharacters(in: .whitespacesAndNewlines)
                    let dailyEquivalent = fields[3].trimmingCharacters(in: .whitespacesAndNewlines)
                    let source = fields[4].trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if let indicatorCode = IndicatorCode.fromString(indicatorCodeStr),
                       let numericValue = Double(numericValueStr),
                       let category = Category.fromString(categoryStr) {
                        
                        let metric = SustainabilityMetric(
                            indicatorCode: indicatorCode,
                            numericValue: numericValue,
                            category: category,
                            dailyEquivalent: dailyEquivalent,
                            source: source
                        )
                        
                        metrics.append(metric)
                        print("Parsed metric: \(indicatorCodeStr) = \(numericValue)")
                    } else {
                        print("Failed to parse values: code=\(indicatorCodeStr), value=\(numericValueStr), category=\(categoryStr)")
                    }
                } else {
                    print("Invalid field count: \(fields.count) in \(metricString)")
                }
            }
        }
        
        return metrics
    }
}

class SustainabilityViewModel: ObservableObject {
    @Published var product: ProductType
    @Published var metrics: [SustainabilityMetric] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let apiService = APIService()
    
    init(product: ProductType = .gansito) {
        self.product = product
        Task {
            await loadMetrics()
        }
    }
    
    @MainActor
    func loadMetrics() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.queryModel(productName: product.apiValue)
            let parsedMetrics = apiService.parseMetrics(from: response)
            
            if !parsedMetrics.isEmpty {
                metrics = parsedMetrics
            } else {
                let fallbackMetrics = createFallbackMetrics()
                if !fallbackMetrics.isEmpty {
                    metrics = fallbackMetrics
                } else {
                    errorMessage = "No se pudieron obtener métricas para este producto."
                }
            }
        } catch {
            print("API Error: \(error.localizedDescription)")
            errorMessage = "Error al cargar datos: \(error.localizedDescription)"
            
            metrics = createFallbackMetrics()
        }
        
        isLoading = false
    }
    
    private func createFallbackMetrics() -> [SustainabilityMetric] {
        switch product {
        case .gansito:
            return [
                SustainabilityMetric(
                    indicatorCode: .energiaRenovable,
                    numericValue: 97,
                    category: .muyBueno,
                    dailyEquivalent: "Como alimentar 1,000 hogares por un día",
                    source: "Annual Report 2023, p. 42"
                ),
                SustainabilityMetric(
                    indicatorCode: .embalajeReciclable,
                    numericValue: 92,
                    category: .muyBueno,
                    dailyEquivalent: "Equivale a salvar 60 árboles por tonelada",
                    source: "Comunicado 26-ene-2024"
                ),
                SustainabilityMetric(
                    indicatorCode: .reusoAgua,
                    numericValue: 60,
                    category: .bueno,
                    dailyEquivalent: "Ahorro de 15,000 litros diarios",
                    source: "Annual Report 2023, p. 90"
                ),
                SustainabilityMetric(
                    indicatorCode: .huellaCarbono,
                    numericValue: 25,
                    category: .bueno,
                    dailyEquivalent: "Equivale a un viaje de 1km en auto",
                    source: "Annual Report 2023, p. 45"
                )
            ]
        case .mantecadas:
            return [
                SustainabilityMetric(
                    indicatorCode: .energiaRenovable,
                    numericValue: 97,
                    category: .muyBueno,
                    dailyEquivalent: "Como alimentar 1,200 hogares por un día",
                    source: "Annual Report 2023, p. 43"
                ),
                SustainabilityMetric(
                    indicatorCode: .embalajeReciclable,
                    numericValue: 90,
                    category: .muyBueno,
                    dailyEquivalent: "Equivale a salvar 55 árboles por tonelada",
                    source: "Comunicado 26-ene-2024"
                ),
                SustainabilityMetric(
                    indicatorCode: .reusoAgua,
                    numericValue: 62,
                    category: .bueno,
                    dailyEquivalent: "Ahorro de 16,000 litros diarios",
                    source: "Annual Report 2023, p. 92"
                ),
                SustainabilityMetric(
                    indicatorCode: .huellaCarbono,
                    numericValue: 28,
                    category: .bueno,
                    dailyEquivalent: "Equivale a un viaje de 1.2km en auto",
                    source: "Annual Report 2023, p. 46"
                )
            ]
        case .takis:
            return [
                SustainabilityMetric(
                    indicatorCode: .energiaRenovable,
                    numericValue: 97,
                    category: .muyBueno,
                    dailyEquivalent: "Equivale a plantar 500 árboles al año",
                    source: "Annual Report 2023, p. 44"
                ),
                SustainabilityMetric(
                    indicatorCode: .embalajeReciclable,
                    numericValue: 92,
                    category: .muyBueno,
                    dailyEquivalent: "Reducción de 30 toneladas de plástico",
                    source: "Comunicado 26-ene-2024"
                ),
                SustainabilityMetric(
                    indicatorCode: .reusoAgua,
                    numericValue: 55,
                    category: .regular,
                    dailyEquivalent: "Como llenar 11,000 botellas de 1L diarias",
                    source: "Annual Report 2023, p. 91"
                ),
                SustainabilityMetric(
                    indicatorCode: .huellaCarbono,
                    numericValue: 30,
                    category: .bueno,
                    dailyEquivalent: "Equivalente a 2km en autobús",
                    source: "Annual Report 2023, p. 47"
                )
            ]
        }
    }
}
