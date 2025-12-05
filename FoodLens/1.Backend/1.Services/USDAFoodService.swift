//
//  USDAFoodService.swift
//  FoodLens
//
//  Created by Melanie and Muna on 12/1/24.
//

import Foundation

struct USDASearchResponse: Codable {
    let foods: [USDAFood]
}

struct USDAFood: Codable, Identifiable {
    let fdcId: Int
    let description: String
    let foodNutrients: [USDANutrient]
    
    var id: Int { fdcId }
}

struct USDANutrient: Codable {
    let nutrientId: Int
    let nutrientName: String
    let value: Double
    let unitName: String
}

class USDAFoodService {
    static let shared = USDAFoodService()
    
    private let baseURL = "https://api.nal.usda.gov/fdc/v1"
    private let apiKey = Config.usdaApiKey
    
    func searchFoods(query: String) async throws -> [FoodItem] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "\(baseURL)/foods/search?query=\(encodedQuery)&api_key=\(apiKey)&dataType=Foundation,SR Legacy"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)

        // Debug: Print raw response
        if let jsonString = String(data: data, encoding: .utf8) {
            print("USDA Response: \(jsonString.prefix(500))...")
        }

        let response = try JSONDecoder().decode(USDASearchResponse.self, from: data)

        return response.foods.map { food in
            FoodItem(from: food)
        }
    }
    
    func getFoodDetails(fdcId: Int) async throws -> FoodItem {
        let urlString = "\(baseURL)/food/\(fdcId)?api_key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let food = try JSONDecoder().decode(USDAFood.self, from: data)
        
        return FoodItem(from: food)
    }
}

// MARK: - FoodItem Extension for USDA

extension FoodItem {
    // Common USDA nutrient IDs
    // 1008 kcal, 1003 protein g, 1005 carbs g, 1004 fat g
    // 1079 fiber g, 2000 sugars g, 1093 sodium mg
    init(from usdaFood: USDAFood) {
        self.id = usdaFood.fdcId
        self.name = usdaFood.description

        var cals = 0.0
        var prot = 0.0
        var carb = 0.0
        var fat  = 0.0
        var fiber = 0.0
        var sugars = 0.0
        var sodiumMg = 0.0

        for nutrient in usdaFood.foodNutrients {
            switch nutrient.nutrientId {
            case 1008: cals = nutrient.value
            case 1003: prot = nutrient.value
            case 1005: carb = nutrient.value
            case 1004: fat  = nutrient.value
            case 1079: fiber = nutrient.value
            case 2000: sugars = nutrient.value
            case 1093: sodiumMg = nutrient.value
            default: break
            }
        }

        self.calories = cals
        self.protein  = prot
        self.carbs    = carb
        self.fat      = fat
        self.fiberG   = fiber
        self.sugarsG  = sugars
        self.sodiumMg = sodiumMg
        self.servingSize = "100g"
    }
}

