import SwiftUI

class APIService {
    private let apiUrl = "https://agent.clicknote.app/api/v1/prediction/33885e0f-ce3b-4571-96f1-4d964fb68ebb"
    private let authToken = "Bearer zGFjcQG8a_Dqs_P0GiGMUT3Q1LPVfMypKHvPThnTsPI"
    private let lm = LocalizationManager.shared

    func queryModel(productName: String) async throws -> String {
        let language = lm.currentLanguageCode
        let data = ["question": "\(productName.lowercased()) - \(language)"]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: data) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: URL(string: apiUrl)!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(authToken, forHTTPHeaderField: "Authorization")

        let (responseData, _) = try await URLSession.shared.data(for: request)

        if let responseDict = try JSONSerialization.jsonObject(with: responseData) as? [String: Any] {
            if let responseText = responseDict["text"] as? String {
                return responseText
            } else if let responseText = responseDict["response"] as? String {
                return responseText
            } else if let responseArray = responseDict["responses"] as? [String], !responseArray.isEmpty {
                return responseArray.joined()
            }
        }

        return createMockResponse(for: productName)
    }

    private func createMockResponse(for productName: String) -> String {
        let muyBueno = lm.localizedString(forKey: "muy_bueno")
        let bueno = lm.localizedString(forKey: "bueno")
        let regular = lm.localizedString(forKey: "regular")

        switch productName.lowercased() {
        case "gansito":
            return "§ENERGÍA_RENOVABLE｜97｜\(muyBueno)｜\(lm.localizedString(forKey: "eq_gansito_energy"))｜Annual Report 2023, p. 42§§EMBALAJE_RECICLABLE｜92｜\(muyBueno)｜\(lm.localizedString(forKey: "eq_gansito_packaging"))｜Comunicado 26-ene-2024§§REUSO_AGUA｜60｜\(bueno)｜\(lm.localizedString(forKey: "eq_gansito_water"))｜Annual Report 2023, p. 90§§HUELLA_CARBONO｜25｜\(bueno)｜\(lm.localizedString(forKey: "eq_gansito_carbon"))｜Annual Report 2023, p. 45§"
        case "mantecadas":
            return "§ENERGÍA_RENOVABLE｜97｜\(muyBueno)｜\(lm.localizedString(forKey: "eq_mantecadas_energy"))｜Annual Report 2023, p. 43§§EMBALAJE_RECICLABLE｜90｜\(muyBueno)｜\(lm.localizedString(forKey: "eq_mantecadas_packaging"))｜Comunicado 26-ene-2024§§REUSO_AGUA｜62｜\(bueno)｜\(lm.localizedString(forKey: "eq_mantecadas_water"))｜Annual Report 2023, p. 92§§HUELLA_CARBONO｜28｜\(bueno)｜\(lm.localizedString(forKey: "eq_mantecadas_carbon"))｜Annual Report 2023, p. 46§"
        case "takis":
            return "§ENERGÍA_RENOVABLE｜97｜\(muyBueno)｜\(lm.localizedString(forKey: "eq_takis_energy"))｜Annual Report 2023, p. 44§§EMBALAJE_RECICLABLE｜92｜\(muyBueno)｜\(lm.localizedString(forKey: "eq_takis_packaging"))｜Comunicado 26-ene-2024§§REUSO_AGUA｜55｜\(regular)｜\(lm.localizedString(forKey: "eq_takis_water"))｜Annual Report 2023, p. 91§§HUELLA_CARBONO｜30｜\(bueno)｜\(lm.localizedString(forKey: "eq_takis_carbon"))｜Annual Report 2023, p. 47§"
        default:
            return "§ENERGÍA_RENOVABLE｜95｜\(muyBueno)｜Energía para 900 hogares por un día｜Annual Report 2023, p. 40§§EMBALAJE_RECICLABLE｜88｜\(muyBueno)｜Equivale a salvar 50 árboles por tonelada｜Comunicado 26-ene-2024§§REUSO_AGUA｜58｜\(regular)｜Ahorro de 14,000 litros diarios｜Annual Report 2023, p. 89§§HUELLA_CARBONO｜32｜\(bueno)｜Equivale a un viaje de 1.5km en auto｜Annual Report 2023, p. 44§"
        }
    }

    func parseMetrics(from response: String) -> [SustainabilityMetric] {
        let pattern = "§([^§]+)§"
        let regex = try? NSRegularExpression(pattern: pattern)
        let nsString = response as NSString
        let matches = regex?.matches(in: response, range: NSRange(location: 0, length: nsString.length)) ?? []

        return matches.compactMap { match in
            guard match.numberOfRanges > 1 else { return nil }
            let fields = nsString.substring(with: match.range(at: 1)).components(separatedBy: "｜")
            guard fields.count == 5,
                  let code = IndicatorCode.fromString(fields[0]),
                  let value = Double(fields[1]),
                  let category = Category.fromString(fields[2]) else { return nil }

            return SustainabilityMetric(
                indicatorCode: code,
                numericValue: value,
                category: category,
                dailyEquivalent: fields[3],
                source: fields[4]
            )
        }
    }
}

class SustainabilityViewModel: ObservableObject {
    @Published var product: ProductType
    @Published var metrics: [SustainabilityMetric] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService = APIService()
    private let lm = LocalizationManager.shared

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
            let parsed = apiService.parseMetrics(from: response)
            metrics = parsed.isEmpty ? createFallbackMetrics() : parsed

            if metrics.isEmpty {
                errorMessage = lm.localizedString(forKey: "error_no_metrics")
            }
        } catch {
            errorMessage = String(format: lm.localizedString(forKey: "error_loading_data"), error.localizedDescription)
            metrics = createFallbackMetrics()
        }

        isLoading = false
    }

    private func createFallbackMetrics() -> [SustainabilityMetric] {
        switch product {
        case .gansito:
            return [
                .init(indicatorCode: .energiaRenovable, numericValue: 97, category: .muyBueno, dailyEquivalent: lm.localizedString(forKey: "eq_gansito_energy"), source: "Annual Report 2023, p. 42"),
                .init(indicatorCode: .embalajeReciclable, numericValue: 92, category: .muyBueno, dailyEquivalent: lm.localizedString(forKey: "eq_gansito_packaging"), source: "Comunicado 26-ene-2024"),
                .init(indicatorCode: .reusoAgua, numericValue: 60, category: .bueno, dailyEquivalent: lm.localizedString(forKey: "eq_gansito_water"), source: "Annual Report 2023, p. 90"),
                .init(indicatorCode: .huellaCarbono, numericValue: 25, category: .bueno, dailyEquivalent: lm.localizedString(forKey: "eq_gansito_carbon"), source: "Annual Report 2023, p. 45")
            ]
        case .mantecadas:
            return [
                .init(indicatorCode: .energiaRenovable, numericValue: 97, category: .muyBueno, dailyEquivalent: lm.localizedString(forKey: "eq_mantecadas_energy"), source: "Annual Report 2023, p. 43"),
                .init(indicatorCode: .embalajeReciclable, numericValue: 90, category: .muyBueno, dailyEquivalent: lm.localizedString(forKey: "eq_mantecadas_packaging"), source: "Comunicado 26-ene-2024"),
                .init(indicatorCode: .reusoAgua, numericValue: 62, category: .bueno, dailyEquivalent: lm.localizedString(forKey: "eq_mantecadas_water"), source: "Annual Report 2023, p. 92"),
                .init(indicatorCode: .huellaCarbono, numericValue: 28, category: .bueno, dailyEquivalent: lm.localizedString(forKey: "eq_mantecadas_carbon"), source: "Annual Report 2023, p. 46")
            ]
        case .takis:
            return [
                .init(indicatorCode: .energiaRenovable, numericValue: 97, category: .muyBueno, dailyEquivalent: lm.localizedString(forKey: "eq_takis_energy"), source: "Annual Report 2023, p. 44"),
                .init(indicatorCode: .embalajeReciclable, numericValue: 92, category: .muyBueno, dailyEquivalent: lm.localizedString(forKey: "eq_takis_packaging"), source: "Comunicado 26-ene-2024"),
                .init(indicatorCode: .reusoAgua, numericValue: 55, category: .regular, dailyEquivalent: lm.localizedString(forKey: "eq_takis_water"), source: "Annual Report 2023, p. 91"),
                .init(indicatorCode: .huellaCarbono, numericValue: 30, category: .bueno, dailyEquivalent: lm.localizedString(forKey: "eq_takis_carbon"), source: "Annual Report 2023, p. 47")
            ]
        }
    }
}
