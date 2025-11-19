//
//  SetGoalMacrosView.swift
//  FoodLens
//
//  Created by Melanie Escobar on 11/7/25.
//

import SwiftUI

struct SetGoalMacrosView: View {
    @EnvironmentObject var model: UserModel
    
    @State private var rec_calories: String = "2000"
    
    var body: some View {
//        ZStack {
//            Color.fwhite.ignoresSafeArea()
//            
//            VStack(spacing: 30) {
//                
//                // Fields
//                VStack(spacing: 20) {
//                
//                    
//                    // DAILY MACRO TARGET
//                    VStack {
//                        Text("Daily Macro Target")
//                            .foregroundStyle(.fblack)
//                            .font(.system(.title2, design: .rounded))
//                            .bold()
//                        
//                        Text("Macro nutrients must equal 100%")
//                            .foregroundStyle(.fred)
//                            .font(.system(.subheadline, design: .rounded))
//                            .bold()
//                            .padding(.vertical, 3)
//                        
//                        HStack(spacing: 20) {
//                            // carbs
//                            MacroPickerComponent(title: "Carbs", icon: "laurel.leading", color: .fyellow, grams: "143.0", modelGrams: $model.carbsGrams, modelPercent: $model.carbsPercent, percents: [20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70])
//                            
//                            // protein
//                            MacroPickerComponent(title: "Protein", icon: "bolt", color: .fblue, grams: "143.0", modelGrams: $model.proteinGrams, modelPercent: $model.proteinPercent, percents: [20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70])
//                            
//                            // fat
//                            MacroPickerComponent(title: "Fat", icon: "drop", color: .fbrown, grams: "53.0", modelGrams: $model.fatGrams, modelPercent: $model.fatPercent, percents: [10, 15, 20, 25, 30, 35, 40, 45])
//                        }
//                        .padding(.horizontal, 18)
//                        
//                        Button {
//                            // FIXME: not yet
//                        } label: {
//                            Text(model.calories == rec_calories ? "Recommended" : "reset to Recommended")
//                                .foregroundStyle(.fblack)
//                                .padding(8)
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 10)
//                                        .stroke(model.calories == rec_calories ? .clear : .fblack, lineWidth: 1)
//                                )
//                        }
//                        .disabled(model.calories == rec_calories)
//                        
//                    }
//                    .padding(.vertical, 15)
//                    .frame(maxWidth: .infinity)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(.fblack, lineWidth: 1)
//                    )
//
//                }
//                .padding(.horizontal, 10)
//                
//                Spacer()
//            }
//            .padding()
//        }
    }
}

#Preview {
    SetGoalMacrosView()
        .environmentObject(UserModel())
}




