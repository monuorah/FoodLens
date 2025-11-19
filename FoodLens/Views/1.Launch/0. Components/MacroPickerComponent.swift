//
//  MacroPickerComponent.swift
//  FoodLens
//
//  Created by Melanie Escobar on 11/9/25.
//

import SwiftUI

struct MacroPickerComponent: View {
    var title: String
    var icon: String
    var color: Color
    var grams: String
    var modelGrams: Binding<String>
    var modelPercent: Binding<Int>
    var percents: [Int]
    
    var body: some View {
        VStack {
            Label(title, systemImage: icon)
                .foregroundStyle(color)
            
            HStack {
                TextField(grams, text: modelGrams)
                    .keyboardType(.numberPad)
                Text("g")
                    .foregroundStyle(.fblack)
            }
            .padding(15)
            .frame(maxWidth: .infinity)
            .frame(height: 35)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.fgray, lineWidth: 1)
            )
            
            Picker(title, selection: modelPercent) {
                ForEach(percents, id: \.self) { percent in
                    Text("\(percent)%").tag(percent)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity)
            .frame(height: 35)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.fgray, lineWidth: 1)
            )
            .tint(.fblack)
        }
    }
}
