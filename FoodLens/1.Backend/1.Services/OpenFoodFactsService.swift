//
//  OpenFoodFactsService.swift
//  FoodLens
//
//  Created by Muna on 12/4/24.
//

import Foundation

/// Service for looking up food products by barcode using the Open Food Facts API
/// https://world.openfoodfacts.org/
class OpenFoodFactsService {
    private let baseURL = "https://world.openfoodfacts.org/api/v2/product"

    enum LookupError: LocalizedError {
        case productNotFound
        case invalidResponse
        case networkError(Error)
        case missingNutritionData

        var errorDescription: String? {
            switch self {
            case .productNotFound:
                return "Product not found in database."
            case .invalidResponse:
                return "Invalid response from server."
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .missingNutritionData:
                return "Product found but missing nutrition data."
            }
        }
    }

    /// Look up a food product by its barcode (UPC/EAN)
    func lookupBarcode(_ barcode: String) async throws -> FoodItem {
        let urlString = "\(baseURL)/\(barcode).json"
        guard let url = URL(string: urlString) else {
            throw LookupError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.setValue("FoodLens iOS App - github.com/foodlens", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw LookupError.invalidResponse
        }

        if httpResponse.statusCode == 404 {
            throw LookupError.productNotFound
        }

        guard httpResponse.statusCode == 200 else {
            throw LookupError.invalidResponse
        }

        let result = try JSONDecoder().decode(OpenFoodFactsResponse.self, from: data)

        guard result.status == 1, let product = result.product else {
            throw LookupError.productNotFound
        }

        return try mapToFoodItem(product, barcode: barcode)
    }

    private func mapToFoodItem(_ product: OFFProduct, barcode: String) throws -> FoodItem {
        // Get product name
        let name = product.product_name ?? product.product_name_en ?? "Unknown Product"

        // Get nutriments (per 100g by default)
        guard let nutriments = product.nutriments else {
            throw LookupError.missingNutritionData
        }

        // Extract values (Open Food Facts uses _100g suffix for per-100g values)
        let calories = nutriments.energy_kcal_100g ?? nutriments.energy_kcal ?? 0
        let protein  = nutriments.proteins_100g   ?? nutriments.proteins   ?? 0
        let carbs    = nutriments.carbohydrates_100g ?? nutriments.carbohydrates ?? 0
        let fat      = nutriments.fat_100g        ?? nutriments.fat        ?? 0

        let fiberG   = nutriments.fiber_100g  ?? nutriments.fiber  ?? 0
        let sugarsG  = nutriments.sugars_100g ?? nutriments.sugars ?? 0
        let sodiumMg = nutriments.sodium_100g ?? nutriments.sodium ?? 0

        // Get serving size if available
        let servingSize = product.serving_size ?? "100g"

        return FoodItem(
            id: barcode.hashValue,
            name: name,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            servingSize: servingSize,
            fiberG: fiberG,
            sugarsG: sugarsG,
            sodiumMg: sodiumMg
        )
    }
}

// MARK: - Open Food Facts API Response Models

private struct OpenFoodFactsResponse: Codable {
    let status: Int // 1 = found, 0 = not found
    let product: OFFProduct?
}

private struct OFFProduct: Codable {
    let product_name: String?
    let product_name_en: String?
    let serving_size: String?
    let nutriments: OFFNutriments?
}

private struct OFFNutriments: Codable {
    // Per 100g values (preferred)
    let energy_kcal_100g: Double?
    let proteins_100g: Double?
    let carbohydrates_100g: Double?
    let fat_100g: Double?
    let fiber_100g: Double?
    let sugars_100g: Double?
    let sodium_100g: Double?

    // Fallback values
    let energy_kcal: Double?
    let proteins: Double?
    let carbohydrates: Double?
    let fat: Double?
    let fiber: Double?
    let sugars: Double?
    let sodium: Double?

    enum CodingKeys: String, CodingKey {
        case energy_kcal_100g = "energy-kcal_100g"
        case proteins_100g = "proteins_100g"
        case carbohydrates_100g = "carbohydrates_100g"
        case fat_100g = "fat_100g"
        case fiber_100g = "fiber_100g"
        case sugars_100g = "sugars_100g"
        case sodium_100g = "sodium_100g"

        case energy_kcal = "energy-kcal"
        case proteins
        case carbohydrates
        case fat
        case fiber
        case sugars
        case sodium
    }
}

