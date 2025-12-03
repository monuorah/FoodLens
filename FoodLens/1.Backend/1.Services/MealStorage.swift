//
//  MealStorage.swift
//  FoodLens
//
//  Created by Melanie and Muna on 12/1/24.
//

import Foundation

struct LoggedMeal: Codable, Identifiable {
    let id: UUID
    let foodItem: FoodItem
    let mealType: String
    let servings: Double
    let date: Date
    
    init(foodItem: FoodItem, mealType: String, servings: Double, date: Date) {
        self.id = UUID()
        self.foodItem = foodItem
        self.mealType = mealType
        self.servings = servings
        self.date = date
    }
    
    var totalCalories: Double { foodItem.calories * servings }
    var totalProtein: Double { foodItem.protein * servings }
    var totalCarbs: Double { foodItem.carbs * servings }
    var totalFat: Double { foodItem.fat * servings }
}

class MealStorage {
    static let shared = MealStorage()
    private let key = "savedMeals"
    
    func saveMeal(_ meal: LoggedMeal) {
        var meals = loadMeals()
        meals.append(meal)
        
        if let data = try? JSONEncoder().encode(meals) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func loadMeals() -> [LoggedMeal] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let meals = try? JSONDecoder().decode([LoggedMeal].self, from: data) else {
            return []
        }
        return meals
    }
    
    func mealsForToday() -> [LoggedMeal] {
        let calendar = Calendar.current
        return loadMeals().filter { meal in
            calendar.isDateInToday(meal.date)
        }
    }
    
    func mealsByType() -> [String: [LoggedMeal]] {
        let today = mealsForToday()
        return Dictionary(grouping: today, by: { $0.mealType })
    }
}
