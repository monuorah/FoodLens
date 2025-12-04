//
//  MealStorage.swift
//  FoodLens
//
//  Created by Melanie and Muna on 12/1/24.
//

import Foundation
import FirebaseAuth

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

    private var userKey: String {
        guard let userId = Auth.auth().currentUser?.uid else {
            return "savedMeals_guest" // Fallback for signed-out state
        }
        return "savedMeals_\(userId)"
    }

    func saveMeal(_ meal: LoggedMeal) {
        var meals = loadMeals()
        meals.append(meal)

        if let data = try? JSONEncoder().encode(meals) {
            UserDefaults.standard.set(data, forKey: userKey)
        }
    }

    func loadMeals() -> [LoggedMeal] {
        guard let data = UserDefaults.standard.data(forKey: userKey),
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
