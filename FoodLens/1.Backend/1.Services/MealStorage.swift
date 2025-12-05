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

    // Preserving-id initializer (useful for edits)
    init(id: UUID, foodItem: FoodItem, mealType: String, servings: Double, date: Date) {
        self.id = id
        self.foodItem = foodItem
        self.mealType = mealType
        self.servings = servings
        self.date = date
    }

    // New entries generate a fresh id
    init(foodItem: FoodItem, mealType: String, servings: Double, date: Date) {
        self.id = UUID()
        self.foodItem = foodItem
        self.mealType = mealType
        self.servings = servings
        self.date = date
    }
    
    var totalCalories: Double { foodItem.calories * servings }
    var totalProtein: Double  { foodItem.protein  * servings }
    var totalCarbs: Double    { foodItem.carbs    * servings }
    var totalFat: Double      { foodItem.fat      * servings }

    // New totals
    var totalFiberG: Double   { foodItem.fiberG   * servings }
    var totalSugarsG: Double  { foodItem.sugarsG  * servings }
    var totalSodiumMg: Double { foodItem.sodiumMg * servings }
}

// Make it comparable/hashable by id only (no need for FoodItem to be Hashable)
extension LoggedMeal: Equatable {
    static func == (lhs: LoggedMeal, rhs: LoggedMeal) -> Bool { lhs.id == rhs.id }
}

extension LoggedMeal: Hashable {
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
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
        persist(meals)
    }

    func deleteMeal(id: UUID) {
        var meals = loadMeals()
        meals.removeAll { $0.id == id }
        persist(meals)
    }

    func updateMeal(_ updated: LoggedMeal) {
        var meals = loadMeals()
        if let idx = meals.firstIndex(where: { $0.id == updated.id }) {
            meals[idx] = updated
            persist(meals)
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
        return loadMeals().filter { calendar.isDateInToday($0.date) }
    }
    
    func mealsByType() -> [String: [LoggedMeal]] {
        let today = mealsForToday()
        return Dictionary(grouping: today, by: { $0.mealType })
    }

    // MARK: - New: Date-range helpers

    func meals(in interval: DateInterval) -> [LoggedMeal] {
        let all = loadMeals()
        return all.filter { interval.contains($0.date) }
    }

    func mealsForLastDays(_ days: Int, from reference: Date = Date()) -> [LoggedMeal] {
        let calendar = Calendar.current
        guard let start = calendar.date(byAdding: .day, value: -(max(days, 0)), to: reference) else { return [] }
        return meals(in: DateInterval(start: start, end: reference))
    }

    // MARK: - Helpers

    private func persist(_ meals: [LoggedMeal]) {
        if let data = try? JSONEncoder().encode(meals) {
            UserDefaults.standard.set(data, forKey: userKey)
        }
    }
}

