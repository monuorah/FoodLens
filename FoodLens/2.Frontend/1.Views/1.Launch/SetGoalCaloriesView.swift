//
//  SetGoalCaloriesView.swift
//  FoodLens
//
//  Created by Melanie Escobar on 11/9/25.
//

import SwiftUI

struct SetGoalCaloriesView: View {
    @EnvironmentObject var model: UserModel
    
    var body: some View {
        ZStack {
            Color.fwhite.ignoresSafeArea()
            
            VStack(spacing: 30) {
                
                TitleComponent(title: "Daily Calorie Target")
                
                Text("Recommended")
                    .foregroundStyle(.fblue)
                    .font(.system(.title2, design: .rounded))
                    .bold()
                
                HStack {
                    // Explicitly unwrap and format; avoid LocalizedStringKey interpolation
                    Text(model.calories.map { $0.formatted(.number.precision(.fractionLength(0))) } ?? "—")
                        .frame(width: 70)
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.fgray, lineWidth: 1)
                        )
                    Text("cal")
                        .foregroundStyle(.fblack)
                }
                
                
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

//
//                    Picker("foodUnit", selection: $model.selectedEnergyUnit) {
//                        Text("cal").tag(EnergyUnit.kcal)
//                        Text("J").tag(EnergyUnit.kJ)
//                    }
//                    .pickerStyle(.menu)


// Fields
//VStack(spacing: 20) {
//
//    
//    // DAILY CALORIE TARGET
//    VStack {
//        Text("Daily Calorie Target")
//            .foregroundStyle(.fblack)
//            .font(.system(.title2, design: .rounded))
//            .bold()
//        
//        VStack {
//            HStack {
//                TextField(rec_calories, text: $model.calories)
//                    .keyboardType(.numberPad)
//                    .frame(width: 70)
//                    .padding(8)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(.fgray, lineWidth: 1)
//                    )
//                Text("cal")
//                    .foregroundStyle(.fblack)
//            }
//            
//            Button {
//                model.calories = rec_calories
//            } label: {
//                Text(model.calories == rec_calories ? "Recommended" : "reset to Recommended")
//                    .foregroundStyle(.fblack)
//                    .padding(8)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(model.calories == rec_calories ? .clear : .fblack, lineWidth: 1)
//                    )
//            }
//            .disabled(model.calories == rec_calories)
//        }
//        .onAppear {
//            if model.calories.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                model.calories = rec_calories
//            }
//        }
//    }
//    .padding(.vertical, 15)
//    .frame(maxWidth: .infinity)
//    .overlay(
//        RoundedRectangle(cornerRadius: 10)
//            .stroke(.fblack, lineWidth: 1)
//    )
//
//
//}
//.padding(.horizontal, 10)
