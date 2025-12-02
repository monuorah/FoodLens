//
//  FoodView.swift
//  FoodLens
//
//  Created by Melanie & Muna on 10/29/25.
//

import SwiftUI

struct FoodView: View {
    var title: String = "Egg"
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.fwhite.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 15) {
                // Title
                Text(title)
                    .foregroundStyle(.fblack)
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.black)
                
                Spacer()
                
                // Meal Type
                Text("Meal Type")
                    .foregroundStyle(.fblack)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.semibold)

                PillField(label: "Breakfast", fullWidth: true)

                // Serving Size + Number of Servings

                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Serving Size")
                            .foregroundStyle(.fblack)
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.semibold)
                        PillField(label: "1 gram", fullWidth: false)
                    }
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("# of Servings")
                            .foregroundStyle(.fblack)
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.semibold)
                        PillField(label: "1", fullWidth: false)
                    }
                }
                
                // Calories Ring
                VStack(spacing: 18) {
                    CaloriesRingView(
                        mainValueText: "286 cal",
                        mainArc: .forange,
                        smallArc1: .fblack,
                        smallArc2: .fgreen
                    )
                    .frame(width: 180, height: 180)
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 8)

                // Macros row
                HStack(alignment: .top) {
                    MacroColumn(
                        percentText: "3 %",
                        gramsText: "1.9 g",
                        label: "Carbs",
                        color: .fgreen
                    )
                    Spacer()
                    MacroColumn(
                        percentText: "63 %",
                        gramsText: "19.9 g",
                        label: "Fat",
                        color: .forange
                    )
                    Spacer()
                    MacroColumn(
                        percentText: "35 %",
                        gramsText: "24.8 g",
                        label: "Protein",
                        color: .fblack
                    )
                }
                .padding(.horizontal, 6)

                Spacer()

                // Save button
                Button {
                    dismiss()
                } label: {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color.fgreen)
                        .cornerRadius(14)
                        .foregroundStyle(.fwhite)
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                }
                .padding(.top, 8)
            }
            .padding()

        }
    }
}

private struct PillField: View {
    let label: String
    let fullWidth: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.secondary.opacity(0.15))
            HStack {
                Text(label)
                    .foregroundStyle(.secondary)
                    .font(.system(.title3, design: .rounded))
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .frame(height: 56)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
        .frame(maxWidth: fullWidth ? .infinity : 180, alignment: .leading)
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

// STATIC AS OF RIGHT NOW
private struct CaloriesRingView: View {
    let mainValueText: String
    let mainArc: Color
    let smallArc1: Color
    let smallArc2: Color

    // Static arc proportions
    private let mainPortion: CGFloat = 0.78
    private let small1: CGFloat = 0.10
    private let small2: CGFloat = 0.06

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.secondary.opacity(0.15), lineWidth: 14)

            // Main arc (orange)
            Circle()
                .trim(from: 0, to: mainPortion)
                .stroke(mainArc, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))

            // Small arc 1 (purple)
            Circle()
                .trim(from: mainPortion + 0.02, to: min(mainPortion + 0.02 + small1, 1.0))
                .stroke(smallArc1, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))

            // Small arc 2 (green)
            Circle()
                .trim(from: mainPortion + 0.02 + small1 + 0.02, to: min(mainPortion + 0.02 + small1 + 0.02 + small2, 1.0))
                .stroke(smallArc2, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90)) // Rotates the arc so the path’s 0 position is at 12 o’clock (top) instead of the default 3 o’clock (right), which is typical for ring charts.

            Text(mainValueText)
                .foregroundStyle(.fblack)
                .font(.system(.title3, design: .rounded))
        }
        .padding(8)
    }
}

#Preview {
    FoodView()
}
