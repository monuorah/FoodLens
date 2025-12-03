//
//  SetGoalCaloriesView.swift
//  FoodLens
//
//  Created by Melanie & Muna on 11/9/25.
//

import SwiftUI

struct SetGoalCaloriesView: View {
    @EnvironmentObject var model: UserModel
    
    // Binding that edits customCalories, but shows active (custom or recommended)
    private var customCaloriesBinding: Binding<Double> {
        Binding<Double>(
            get: {
                // Prefer whatever the app is currently using
                (model.activeCalories ?? model.recommendedCalories ?? 0).rounded()
            },
            set: { newValue in
                // If they type something, treat it as custom
                model.customCalories = newValue
            }
        )
    }
    
    // Display strings
    private var recommendedText: String {
        if let value = model.recommendedCalories {
            return value.formatted(.number.precision(.fractionLength(0)))
        } else {
            return "—"
        }
    }
    
    private var activeText: String {
        if let value = model.activeCalories {
            return value.formatted(.number.precision(.fractionLength(0)))
        } else {
            return "—"
        }
    }
    
    private var unitLabel: String {
        model.selectedEnergyUnit == .kcal ? "kcal" : "kJ"
    }
    
    var body: some View {
        ZStack {
            Color.fwhite.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Title
                TitleComponent(title: "Daily Calorie Target")
                
                // Recommended block (read-only)
                VStack(spacing: 8) {
                    Text("Recommended")
                        .foregroundStyle(.fblue)
                        .font(.system(.title2, design: .rounded))
                        .bold()
                    
                    HStack {
                        Text(recommendedText)
                            .frame(width: 80)
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.fgray, lineWidth: 1)
                            )
                        
                        Text(unitLabel)
                            .foregroundStyle(.fblack)
                    }
                    
                    Text("Based on your height, weight, age, activity level, and goal.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Editable block (what the app will use)
                VStack(spacing: 16) {
                    Text("Your daily target")
                        .foregroundStyle(.fblack)
                        .font(.system(.title3, design: .rounded))
                        .bold()
                    
                    HStack {
                        TextField(
                            "2000",
                            value: customCaloriesBinding,
                            format: .number.precision(.fractionLength(0))
                        )
                        .keyboardType(.numberPad)
                        .frame(width: 80)
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.secondary.opacity(0.2), lineWidth: 1)
                        )
                        
                        Text(unitLabel)
                            .foregroundStyle(.fblack.opacity(0.8))
                    }
                    
                    // Little helper text showing what’s currently active
                    Text("Currently using \(activeText) \(unitLabel.lowercased()) per day.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button {
                        model.resetCaloriesToRecommended()
                    } label: {
                        Text("Reset to recommended")
                            .font(.callout)
                            .foregroundStyle(.fblue)
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.fblue.opacity(0.25), lineWidth: 1)
                            )
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.fwhite)
                        .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 4)
                )
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    SetGoalCaloriesView()
        .environmentObject(UserModel())
}
