//
//  Components+Charts.swift
//  FoodLens
//
//  Helper views used by TrendsView
//

import SwiftUI
import Charts

// MARK: - RoundedCard

struct RoundedCard<Content: View>: View {
    var content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - MacroRow

struct MacroRow: View {
    let name: String
    let goalPercent: Int
    let actualPercent: Int
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(name)
                    .foregroundStyle(.fblack)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                Spacer()
                Text("\(actualPercent)%")
                    .foregroundStyle(tint)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                Text("of \(goalPercent)%")
                    .foregroundStyle(.secondary)
                    .font(.system(.footnote, design: .rounded))
            }
            ProgressBar(progress: progressRatio, tint: tint)
        }
    }

    private var progressRatio: Double {
        guard goalPercent > 0 else { return 0 }
        return min(max(Double(actualPercent) / Double(goalPercent), 0), 1)
    }
}

struct ProgressBar: View {
    let progress: Double
    let tint: Color

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: 8)
                Capsule()
                    .fill(tint)
                    .frame(width: geo.size.width * progress, height: 8)
            }
        }
        .frame(height: 8)
    }
}

// MARK: - GraphPlaceholder

struct GraphPlaceholder: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.secondary.opacity(0.1))
            .frame(height: 160)
            .overlay {
                Text("No data")
                    .foregroundStyle(.secondary)
                    .font(.system(.footnote, design: .rounded))
            }
    }
}

// MARK: - TopFoodRow

struct TopFoodRow: View {
    let name: String
    let count: Int

    var body: some View {
        HStack {
            Text(name)
                .foregroundStyle(.fblack)
                .font(.system(.body, design: .rounded))
                .lineLimit(1)
            Spacer()
            Text("×\(count)")
                .foregroundStyle(.secondary)
                .font(.system(.subheadline, design: .rounded))
        }
        .padding(.vertical, 4)
    }
}

// MARK: - InsightCard

struct InsightCard: View {
    let accent: Color
    let title: String
    let subtitle: String
    let trailingIcon: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(accent)
                .frame(width: 10, height: 10)
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .foregroundStyle(.fblack)
                        .font(.system(.headline, design: .rounded))
                    Spacer()
                    Image(systemName: trailingIcon)
                        .foregroundStyle(accent)
                }
                Text(subtitle)
                    .foregroundStyle(.secondary)
                    .font(.system(.subheadline, design: .rounded))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        )
    }
}

// MARK: - WeightChart

struct WeightChart: View {
    let entries: [WeightEntry]

    var body: some View {
        Chart(entries) { entry in
            LineMark(
                x: .value("Date", entry.date),
                y: .value("Weight", entry.weight)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(Color.fgreen)

            PointMark(
                x: .value("Date", entry.date),
                y: .value("Weight", entry.weight)
            )
            .foregroundStyle(Color.fgreen.opacity(0.7))
            .symbolSize(20)
        }
        .frame(height: 180)
    }
}

// MARK: - CalorieChart

struct CalorieChart: View {
    let history: [(date: Date, calories: Double)]

    var body: some View {
        Chart(history, id: \.date) { item in
            BarMark(
                x: .value("Date", item.date),
                y: .value("Calories", item.calories)
            )
            .foregroundStyle(Color.forange.opacity(0.8))
        }
        .frame(height: 180)
    }
}
