//
//  MockDataGenerator.swift
//  FoodLens
//
//  Created for testing and demo purposes
//

import Foundation

struct MockDataGenerator {

    /// Call this once to populate fake meal data for the past 30 days
    static func generateMockMeals() {
        let foods = [
            FoodItem(id: 1, name: "Chicken Breast", calories: 165, protein: 31, carbs: 0, fat: 3.6, servingSize: "100g"),
            FoodItem(id: 2, name: "Brown Rice", calories: 112, protein: 2.6, carbs: 24, fat: 0.9, servingSize: "100g"),
            FoodItem(id: 3, name: "Broccoli", calories: 55, protein: 3.7, carbs: 11, fat: 0.6, servingSize: "100g"),
            FoodItem(id: 4, name: "Eggs", calories: 155, protein: 13, carbs: 1.1, fat: 11, servingSize: "2 large"),
            FoodItem(id: 5, name: "Salmon", calories: 208, protein: 20, carbs: 0, fat: 13, servingSize: "100g"),
            FoodItem(id: 6, name: "Greek Yogurt", calories: 59, protein: 10, carbs: 3.6, fat: 0.4, servingSize: "100g"),
            FoodItem(id: 7, name: "Oatmeal", calories: 389, protein: 17, carbs: 66, fat: 7, servingSize: "100g"),
            FoodItem(id: 8, name: "Banana", calories: 89, protein: 1.1, carbs: 23, fat: 0.3, servingSize: "1 medium"),
            FoodItem(id: 9, name: "Almonds", calories: 579, protein: 21, carbs: 22, fat: 50, servingSize: "100g"),
            FoodItem(id: 10, name: "Sweet Potato", calories: 86, protein: 1.6, carbs: 20, fat: 0.1, servingSize: "100g"),
            FoodItem(id: 11, name: "Avocado", calories: 160, protein: 2, carbs: 9, fat: 15, servingSize: "1/2 avocado"),
            FoodItem(id: 12, name: "Spinach", calories: 23, protein: 2.9, carbs: 3.6, fat: 0.4, servingSize: "100g")
        ]

        let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]
        let calendar = Calendar.current

        // Generate meals for the past 30 days
        for dayOffset in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { continue }

            // 3-5 meals per day for realistic calorie totals
            let mealsPerDay = Int.random(in: 3...5)

            for _ in 0..<mealsPerDay {
                let food = foods.randomElement()!
                let mealType = mealTypes.randomElement()!
                let servings = Double.random(in: 1.0...3.0)

                // Randomize time of day for the meal
                let hour: Int
                switch mealType {
                case "Breakfast": hour = Int.random(in: 7...9)
                case "Lunch": hour = Int.random(in: 12...14)
                case "Dinner": hour = Int.random(in: 18...20)
                default: hour = Int.random(in: 10...16)
                }

                guard let mealDate = calendar.date(bySettingHour: hour, minute: Int.random(in: 0...59), second: 0, of: date) else { continue }

                let meal = LoggedMeal(
                    foodItem: food,
                    mealType: mealType,
                    servings: servings,
                    date: mealDate
                )

                MealStorage.shared.saveMeal(meal)
            }
        }

        print("✅ Generated mock meals for past 30 days")
    }

    /// Call this once to populate fake weight data for the past 30 days
    /// Treats startWeight as the BEGINNING of their journey (30 days ago), shows progress toward goal
    static func generateMockWeights(startWeight: Double = 175, targetWeight: Double = 165, unit: String = "lbs") {
        print("🔍 DEBUG: generateMockWeights called with startWeight=\(startWeight), targetWeight=\(targetWeight), unit=\(unit)")

        let calendar = Calendar.current
        let totalDays = 30

        // startWeight = what they weighed when they started (30 days ago)
        // targetWeight = their goal weight
        // We'll show realistic progress from start toward goal over 30 days

        let isLosingWeight = startWeight > targetWeight
        print("🔍 DEBUG: isLosingWeight=\(isLosingWeight)")

        // Realistic monthly progress: 5-8 lbs per month
        let monthlyProgress: Double = 8.0

        // Calculate current weight after 30 days of progress
        let currentWeight = isLosingWeight ? (startWeight - monthlyProgress) : (startWeight + monthlyProgress)

        print("🔍 DEBUG: Journey: \(startWeight) (30 days ago) → \(currentWeight) (today), goal: \(targetWeight)")

        // Daily change to get from startWeight (30 days ago) to currentWeight (today)
        let totalChange = currentWeight - startWeight
        let dailyChange = totalChange / Double(totalDays)

        // Generate weight entries every 2-3 days
        var daysAgo = totalDays
        while daysAgo >= 0 {
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) else {
                daysAgo -= Int.random(in: 2...3)
                continue
            }

            // Weight progresses from startWeight (daysAgo=30) to currentWeight (daysAgo=0)
            let daysOfProgress = totalDays - daysAgo
            let baseWeight = startWeight + (dailyChange * Double(daysOfProgress))
            let randomVariation = Double.random(in: -1.5...1.5)
            let weight = baseWeight + randomVariation

            let entry = WeightEntry(weight: weight, unit: unit, date: date)
            WeightStorage.shared.saveWeight(entry)

            daysAgo -= Int.random(in: 2...3)
        }

        let direction = isLosingWeight ? "DOWN" : "UP"
        print("✅ Generated mock weights: \(startWeight) → \(currentWeight) \(unit) (trending \(direction), \(monthlyProgress) lbs progress toward goal of \(targetWeight) \(unit))")
    }

    /// Call this to generate both meals and weights at once
    static func generateAllMockData(startWeight: Double? = nil, targetWeight: Double? = nil, unit: String = "lbs") {
        generateMockMeals()

        // Use provided weights or defaults
        let start = startWeight ?? 175
        let target = targetWeight ?? 165
        generateMockWeights(startWeight: start, targetWeight: target, unit: unit)

        print("✅ All mock data generated!")
    }
}
