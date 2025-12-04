// EditMealView.swift

import SwiftUI

struct EditMealView: View {
    let meal: LoggedMeal
    @Environment(\.dismiss) private var dismiss

    @State private var selectedMealType: String
    @State private var servings: Double

    init(meal: LoggedMeal) {
        self.meal = meal
        _selectedMealType = State(initialValue: meal.mealType)
        _servings = State(initialValue: meal.servings)
    }

    var body: some View {
        ZStack {
            Color.fwhite.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 16) {
                Text(meal.foodItem.name)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.fblack)

                Text("Meal Type")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)

                Menu {
                    Button("Breakfast") { selectedMealType = "Breakfast" }
                    Button("Lunch") { selectedMealType = "Lunch" }
                    Button("Dinner") { selectedMealType = "Dinner" }
                    Button("Snacks") { selectedMealType = "Snacks" }
                } label: {
                    HStack {
                        Text(selectedMealType)
                            .foregroundStyle(.fblack)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.12))
                    .cornerRadius(12)
                }

                Text("Servings (\(meal.foodItem.servingSize))")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)

                HStack(spacing: 16) {
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
                        .background(Color.secondary.opacity(0.12))
                        .cornerRadius(10)

                    Button {
                        servings += 0.5
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.forange)
                    }
                }

                Spacer()

                Button {
                    let updated = LoggedMeal(
                        id: meal.id,
                        foodItem: meal.foodItem,
                        mealType: selectedMealType,
                        servings: servings,
                        date: meal.date
                    )
                    MealStorage.shared.updateMeal(updated)
                    dismiss()
                } label: {
                    Text("Save Changes")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.fgreen)
                        .cornerRadius(12)
                        .foregroundStyle(.fwhite)
                        .fontWeight(.semibold)
                }
            }
            .padding()
        }
        .navigationTitle("Edit Food")
        .navigationBarTitleDisplayMode(.inline)
    }
}
