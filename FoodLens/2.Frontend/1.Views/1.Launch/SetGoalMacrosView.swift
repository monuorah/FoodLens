//
//  SetGoalMacrosView.swift
//  FoodLens
//
//  Created by Melanie Escobar on 11/7/25.
//

import SwiftUI

struct SetGoalMacrosView: View {
    @EnvironmentObject var model: UserModel
    
    private var sumPercent: Int {
        model.carbsPercent + model.proteinPercent + model.fatPercent
    }
    
    private var sumErrorText: String? {
        sumPercent == 100
            ? nil
            : "Macro percentages must add up to 100% (currently \(sumPercent)%)."
    }
    
    var body: some View {
        ZStack {
            Color.fwhite.ignoresSafeArea()
            
            VStack(spacing: 30) {
                TitleComponent(title: "Daily Macro Target")
                
                VStack(spacing: 16) {
                    Text("Macros must equal 100%")
                        .foregroundStyle(sumErrorText == nil ? Color.secondary : Color.fred)
                        .font(.system(.subheadline, design: .rounded))
                        .bold()
                    
                    if let sumErrorText {
                        Text(sumErrorText)
                            .foregroundStyle(.fred)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    
                    // 3 macro pickers
                    HStack(spacing: 20) {
                        // Carbs
                        MacroPickerComponent(
                            title: "Carbs",
                            icon: "laurel.leading",
                            color: .fyellow,
                            grams: $model.carbsGrams,
                            percent: $model.carbsPercent,
                            percents: [20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70]
                        ) {
                            // user edited grams -> recompute percents & grams from model
                            model.updateMacroPercentsFromGrams()
                            model.updateMacroGramsFromPercents()
                        }
                        
                        // Protein
                        MacroPickerComponent(
                            title: "Protein",
                            icon: "bolt",
                            color: .fblue,
                            grams: $model.proteinGrams,
                            percent: $model.proteinPercent,
                            percents: [10, 15, 20, 25, 30, 35, 40, 45, 50]
                        ) {
                            model.updateMacroPercentsFromGrams()
                            model.updateMacroGramsFromPercents()
                        }
                        
                        // Fat
                        MacroPickerComponent(
                            title: "Fat",
                            icon: "drop",
                            color: .fbrown,
                            grams: $model.fatGrams,
                            percent: $model.fatPercent,
                            percents: [10, 15, 20, 25, 30, 35, 40, 45]
                        ) {
                            model.updateMacroPercentsFromGrams()
                            model.updateMacroGramsFromPercents()
                        }
                    }
                    .padding(.horizontal, 18)
                    
                    // Reset button
                    Button {
                        model.resetMacrosToRecommended()
                    } label: {
                        Text("Reset to recommended split")
                            .foregroundStyle(.fblack)
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.fblack, lineWidth: 1)
                            )
                    }
                }
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.fblack, lineWidth: 1)
                )
                .padding(.horizontal, 10)
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            // make sure grams exist based on current percents + calories
            model.updateMacroGramsFromPercents()
        }
        // When user changes percents (via picker), recompute grams
        .onChange(of: model.carbsPercent) { _ in
            model.updateMacroGramsFromPercents()
        }
        .onChange(of: model.proteinPercent) { _ in
            model.updateMacroGramsFromPercents()
        }
        .onChange(of: model.fatPercent) { _ in
            model.updateMacroGramsFromPercents()
        }
    }
}

#Preview {
    SetGoalMacrosView()
        .environmentObject(UserModel())
}
