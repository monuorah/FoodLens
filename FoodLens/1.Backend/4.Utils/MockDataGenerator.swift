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
    static func generateMockWeights(startWeight: Double = 175, targetWeight: Double = 165, unit: String = "lbs") {
        let calendar = Calendar.current
        let totalDays = 30
        let weightChange = targetWeight - startWeight
        let dailyChange = weightChange / Double(totalDays)

        // Generate weight entries every 2-3 days
        var currentDay = 0
        while currentDay < totalDays {
            guard let date = calendar.date(byAdding: .day, value: -currentDay, to: Date()) else { break }

            // Add some randomness to simulate real weight fluctuations
            let baseWeight = startWeight + (dailyChange * Double(currentDay))
            let randomVariation = Double.random(in: -1.5...1.5)
            let weight = baseWeight + randomVariation

            let entry = WeightEntry(weight: weight, unit: unit, date: date)
            WeightStorage.shared.saveWeight(entry)

            // Skip 2-3 days
            currentDay += Int.random(in: 2...3)
        }

        print("✅ Generated mock weights for past 30 days (trend: \(startWeight) → \(targetWeight) \(unit))")
    }

    /// Call this to generate both meals and weights at once
    static func generateAllMockData() {
        generateMockMeals()
        generateMockWeights()
        print("✅ All mock data generated!")
    }
}
