//
//  WeightSheetView.swift
//  FoodLens
//
//  Created by Melanie Escobar on 11/7/25.
//

import SwiftUI

struct WeightSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var unit: String = "imperial" // "imperial" or "metric"
    @State private var weight: String = ""
    @State private var unitLabel: String = "lbs"
    
    var body: some View {
        ZStack {
            Color.fblack.ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Update Weight")
                    .foregroundStyle(.fwhite)
                    .font(.system(.title, design: .rounded))
                    .bold()
                    .padding(.top, 40)
                
                Spacer()
                
                HStack(spacing: 10) {
                    ZStack(alignment: .leading) {
                        if weight.isEmpty {
                            Text(unit == "imperial" ? "120" : "60")
                                .foregroundStyle(Color.fwhite.opacity(0.6))
                        }
                        TextField("", text: $weight)
                            .keyboardType(.numberPad)
                            .foregroundStyle(.fwhite)
                    }
                    .frame(width: 80)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.fwhite.opacity(0.2), lineWidth: 1)
                    )
                    
                    Picker("Unit", selection: $unit) {
                        Text("lbs").tag("imperial")
                        Text("kg").tag("metric")
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 140)
                }
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.fgreen)
                        .cornerRadius(10)
                        .foregroundStyle(.fwhite)
                        .fontWeight(.semibold)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}
