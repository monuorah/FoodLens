//
//  FoodItem.swift
//  FoodLens
//
//  Created by Melanie & Muna on 12/2/24.
//

import Foundation

struct FoodItem: Identifiable, Hashable, Codable {
    let id: Int
    let name: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let servingSize: String

    // Added nutrients
    let fiberG: Double
    let sugarsG: Double
    let sodiumMg: Double

    // Memberwise initializer for manual creation (e.g., in previews)
    // New nutrients have defaults so existing calls continue to compile.
    init(
        id: Int,
        name: String,
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double,
        servingSize: String,
        fiberG: Double = 0,
        sugarsG: Double = 0,
        sodiumMg: Double = 0
    ) {
        self.id = id
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.servingSize = servingSize
        self.fiberG = fiberG
        self.sugarsG = sugarsG
        self.sodiumMg = sodiumMg
    }

    // Custom Codable to remain backward‑compatible with older saved data (where new keys don’t exist)
    enum CodingKeys: String, CodingKey {
        case id, name, calories, protein, carbs, fat, servingSize
        case fiberG, sugarsG, sodiumMg
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id          = try c.decode(Int.self,    forKey: .id)
        name        = try c.decode(String.self, forKey: .name)
        calories    = try c.decode(Double.self, forKey: .calories)
        protein     = try c.decode(Double.self, forKey: .protein)
        carbs       = try c.decode(Double.self, forKey: .carbs)
        fat         = try c.decode(Double.self, forKey: .fat)
        servingSize = try c.decode(String.self, forKey: .servingSize)
        fiberG      = try c.decodeIfPresent(Double.self, forKey: .fiberG)   ?? 0
        sugarsG     = try c.decodeIfPresent(Double.self, forKey: .sugarsG)  ?? 0
        sodiumMg    = try c.decodeIfPresent(Double.self, forKey: .sodiumMg) ?? 0
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,          forKey: .id)
        try c.encode(name,        forKey: .name)
        try c.encode(calories,    forKey: .calories)
        try c.encode(protein,     forKey: .protein)
        try c.encode(carbs,       forKey: .carbs)
        try c.encode(fat,         forKey: .fat)
        try c.encode(servingSize, forKey: .servingSize)
        try c.encode(fiberG,      forKey: .fiberG)
        try c.encode(sugarsG,     forKey: .sugarsG)
        try c.encode(sodiumMg,    forKey: .sodiumMg)
    }
}

