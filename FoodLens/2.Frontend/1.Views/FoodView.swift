//
//  FoodView.swift
//  FoodLens
//
//  Created by Melanie & Muna on 10/29/25.
//

import SwiftUI

struct FoodView: View {
    let foodItem: FoodItem
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedMealType = "Breakfast"
    @State private var servings: Double = 1.0

    var totalCalories: Double { foodItem.calories * servings }
    var totalProtein: Double { foodItem.protein * servings }
    var totalCarbs: Double { foodItem.carbs * servings }
    var totalFat: Double { foodItem.fat * servings }
    
    var totalMacros: Double { totalProtein + totalCarbs + totalFat }
    
    var proteinPercent: Int {
        guard totalMacros > 0 else { return 0 }
        return Int((totalProtein / totalMacros) * 100)
    }
    
    var carbsPercent: Int {
        guard totalMacros > 0 else { return 0 }
        return Int((totalCarbs / totalMacros) * 100)
    }
    
    var fatPercent: Int {
        guard totalMacros > 0 else { return 0 }
        return Int((totalFat / totalMacros) * 100)
    }

    var body: some View {
        ZStack {
            Color.fwhite.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 15) {
                // Title
                Text(foodItem.name)
                    .foregroundStyle(.fblack)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.black)
                
                // Meal Type
                Text("Meal Type")
                    .foregroundStyle(.fblack)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.semibold)

                Menu {
                    Button("Breakfast") { selectedMealType = "Breakfast" }
                    Button("Lunch") { selectedMealType = "Lunch" }
                    Button("Dinner") { selectedMealType = "Dinner" }
                    Button("Snacks") { selectedMealType = "Snacks" }
                } label: {
                    HStack {
                        Text(selectedMealType)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.15))
                    .cornerRadius(18)
                }

                // Servings
                VStack(alignment: .leading, spacing: 15) {
                    Text("Number of Servings (\(foodItem.servingSize) each)")
                        .foregroundStyle(.fblack)
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.semibold)
                    
                    HStack {
                        Button {
                            if servings > 0.5 { servings -= 0.5 }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.forange)
                        }
                        
                        Text(String(format: "%.1f", servings))
                            .frame(width: 60)
                            .padding(8)
                            .background(Color.secondary.opacity(0.15))
                            .cornerRadius(10)
                        
                        Button {
                            servings += 0.5
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.forange)
                        }
                    }
                }
                
                // Calories
                VStack(spacing: 10) {
                    Text("\(Int(totalCalories)) cal")
                        .foregroundStyle(.fblack)
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)

                // Macros
                HStack(alignment: .top) {
                    MacroColumn(
                        percentText: "\(carbsPercent)%",
                        gramsText: String(format: "%.1f g", totalCarbs),
                        label: "Carbs",
                        color: .fgreen
                    )
                    Spacer()
                    MacroColumn(
                        percentText: "\(fatPercent)%",
                        gramsText: String(format: "%.1f g", totalFat),
                        label: "Fat",
                        color: .forange
                    )
                    Spacer()
                    MacroColumn(
                        percentText: "\(proteinPercent)%",
                        gramsText: String(format: "%.1f g", totalProtein),
                        label: "Protein",
                        color: .fblack
                    )
                }

                Spacer()

                // Save button
                Button {
                    saveMeal()
                    dismiss()
                } label: {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color.fgreen)
                        .cornerRadius(14)
                        .foregroundStyle(.fwhite)
                        .fontWeight(.semibold)
                }
            }
            .padding()
        }
    }
    
    private func saveMeal() {
        let meal = LoggedMeal(
            foodItem: foodItem,
            mealType: selectedMealType,
            servings: servings,
            date: Date()
        )
        MealStorage.shared.saveMeal(meal)
    }
}

private struct MacroColumn: View {
    let percentText: String
    let gramsText: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(percentText)
                .foregroundStyle(color)
                .font(.system(.title3, design: .rounded))
                .fontWeight(.semibold)
            Text(gramsText)
                .foregroundStyle(.fblack)
                .font(.system(.headline, design: .rounded))
            Text(label)
                .foregroundStyle(.secondary)
                .font(.system(.subheadline, design: .rounded))
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    FoodView(foodItem: FoodItem(
        id: 1,
        name: "Chicken Breast",
        calories: 165,
        protein: 31,
        carbs: 0,
        fat: 3.6,
        servingSize: "100g"
    ))
}
