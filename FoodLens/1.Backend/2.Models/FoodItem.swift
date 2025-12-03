//
//  FoodItem.swift
//  FoodLens
//
//  Created by Muna on 12/2/24.
//

import Foundation

struct FoodItem: Identifiable, Codable {
    let id: Int
    let name: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let servingSize: String

    // Memberwise initializer for manual creation (e.g., in previews)
    init(id: Int, name: String, calories: Double, protein: Double, carbs: Double, fat: Double, servingSize: String) {
        self.id = id
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.servingSize = servingSize
    }
}
