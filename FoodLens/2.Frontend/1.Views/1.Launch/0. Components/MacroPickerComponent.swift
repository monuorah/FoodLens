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
    
    @Binding var grams: Double?
    @Binding var percent: Int
    var percents: [Int]
    
    // Called when the user finishes editing grams (so parent can sync percents)
    var onGramsCommit: () -> Void
    
    // Bridge Double? <-> String for the TextField
    private var gramsTextBinding: Binding<String> {
        Binding<String>(
            get: {
                if let g = grams {
                    return g.formatted(.number.precision(.fractionLength(0...1)))
                } else {
                    return ""
                }
            },
            set: { newValue in
                let cleaned = newValue.replacingOccurrences(of: ",", with: ".")
                if cleaned.isEmpty {
                    grams = nil
                } else if let value = Double(cleaned) {
                    grams = value
                }
                // if invalid, just ignore; keeps last valid value
            }
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .foregroundStyle(color)
            
            // Grams input
            HStack {
                TextField("0", text: gramsTextBinding)
                    .keyboardType(.decimalPad)
                    .onSubmit {
                        onGramsCommit()
                    }
                Text("g")
                    .foregroundStyle(.fblack)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.fgray, lineWidth: 1)
            )
            
            // Percent picker
            Picker(title, selection: $percent) {
                ForEach(percents, id: \.self) { p in
                    Text("\(p)%").tag(p)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.fgray, lineWidth: 1)
            )
            .tint(.fblack)
        }
    }
}
