//
//  TrendsView.swift
//  FoodLens
//
//  Created by Melanie & Muna on 10/29/25.
//

import SwiftUI
import Charts

struct TrendsView: View {
    @EnvironmentObject var userModel: UserModel

    enum Range: String, CaseIterable, Identifiable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        var id: String { rawValue }
    }

    @State private var selectedRange: Range = .daily
    @State private var todaysMeals: [LoggedMeal] = []
    @State private var weightEntries: [WeightEntry] = []

    // MARK: - Calories/Macros

    private var totalCalories: Double {
        todaysMeals.reduce(0) { $0 + $1.totalCalories }
    }

    private var totalCarbs: Double {
        todaysMeals.reduce(0) { $0 + $1.totalCarbs }
    }

    private var totalFat: Double {
        todaysMeals.reduce(0) { $0 + $1.totalFat }
    }

    private var totalProtein: Double {
        todaysMeals.reduce(0) { $0 + $1.totalProtein }
    }

    private var totalMacros: Double {
        totalCarbs + totalFat + totalProtein
    }

    private var carbsPercent: Int {
        guard totalMacros > 0 else { return 0 }
        return Int((totalCarbs / totalMacros) * 100)
    }

    private var fatPercent: Int {
        guard totalMacros > 0 else { return 0 }
        return Int((totalFat / totalMacros) * 100)
    }

    private var proteinPercent: Int {
        guard totalMacros > 0 else { return 0 }
        return Int((totalProtein / totalMacros) * 100)
    }

    private var calorieGoal: Double {
        userModel.activeCalories ?? 2200
    }

    private var calorieProgress: Double {
        guard calorieGoal > 0 else { return 0 }
        return min(totalCalories / calorieGoal, 1.0)
    }

    // MARK: - Weight (entry -> onboarding/settings -> goal)

    private var selectedWeightUnitSymbol: String {
        userModel.selectedWeightUnit == .imperial ? "lbs" : "kg"
    }

    private var latestWeightEntry: WeightEntry? {
        WeightStorage.shared.mostRecentWeight()
    }

    private var currentWeight: Double {
        if let entry = latestWeightEntry { return entry.weight }
        if let cw = userModel.currentWeight { return cw }
        return userModel.goalWeight ?? 0
    }

    private var currentWeightUnit: String {
        if let entry = latestWeightEntry { return entry.unit }
        return selectedWeightUnitSymbol
    }

    private var weightGoal: Double {
        userModel.goalWeight ?? (userModel.currentWeight ?? 0)
    }

    // Change over the selected range (end - start)
    private var weightChangeDelta: Double {
        let daysToShow = selectedRange == .weekly ? 7 : 30
        let entries = WeightStorage.shared
            .weightsForLastDays(daysToShow)
            .sorted { $0.date < $1.date }
        guard let first = entries.first, let last = entries.last else { return 0 }
        return last.weight - first.weight
    }

    private var weightChangeIcon: String {
        if weightChangeDelta > 0 { return "arrow.up.right" }
        if weightChangeDelta < 0 { return "arrow.down.right" }
        return "minus"
    }

    private var weightChangeColor: Color {
        if weightChangeDelta > 0 { return .fred }     // up = gain
        if weightChangeDelta < 0 { return .fgreen }   // down = loss
        return .secondary
    }

    private var averageWeight: Double {
        let daysToShow = selectedRange == .weekly ? 7 : 30
        let weights = WeightStorage.shared.weightsForLastDays(daysToShow)
        guard !weights.isEmpty else { return currentWeight }
        let total = weights.reduce(0.0) { $0 + $1.weight }
        return total / Double(weights.count)
    }

    // MARK: - Foods

    private var macroGoals: (carbs: Int, fat: Int, protein: Int) {
        (carbs: userModel.carbsPercent, fat: userModel.fatPercent, protein: userModel.proteinPercent)
    }

    private var topFoods: [(name: String, count: Int)] {
        let allMeals = MealStorage.shared.loadMeals()
        var foodCounts: [String: Int] = [:]
        for meal in allMeals {
            foodCounts[meal.foodItem.name, default: 0] += 1
        }
        return foodCounts
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { (name: $0.key, count: $0.value) }
    }

    private var calorieHistory: [(date: Date, calories: Double)] {
        let calendar = Calendar.current
        let allMeals = MealStorage.shared.loadMeals()
        let daysToShow = selectedRange == .weekly ? 7 : 30
        guard let startDate = calendar.date(byAdding: .day, value: -daysToShow, to: Date()) else { return [] }

        let mealsInRange = allMeals.filter { $0.date >= startDate }

        var caloriesByDate: [Date: Double] = [:]
        for meal in mealsInRange {
            let dayStart = calendar.startOfDay(for: meal.date)
            caloriesByDate[dayStart, default: 0] += meal.totalCalories
        }

        return caloriesByDate
            .map { (date: $0.key, calories: $0.value) }
            .sorted { $0.date < $1.date }
    }

    private var averageCalories: Double {
        let calendar = Calendar.current
        let allMeals = MealStorage.shared.loadMeals()
        let daysToShow = selectedRange == .weekly ? 7 : 30
        guard let startDate = calendar.date(byAdding: .day, value: -daysToShow, to: Date()) else { return 0 }

        let mealsInRange = allMeals.filter { $0.date >= startDate }

        var caloriesByDate: [Date: Double] = [:]
        for meal in mealsInRange {
            let dayStart = calendar.startOfDay(for: meal.date)
            caloriesByDate[dayStart, default: 0] += meal.totalCalories
        }

        guard !caloriesByDate.isEmpty else { return 0 }
        let totalCalories = caloriesByDate.values.reduce(0, +)
        return totalCalories / Double(caloriesByDate.count)
    }

    private var averageMacros: (carbs: Double, fat: Double, protein: Double) {
        let calendar = Calendar.current
        let allMeals = MealStorage.shared.loadMeals()
        let daysToShow = selectedRange == .weekly ? 7 : 30
        guard let startDate = calendar.date(byAdding: .day, value: -daysToShow, to: Date()) else { return (0,0,0) }

        let mealsInRange = allMeals.filter { $0.date >= startDate }

        var macrosByDate: [Date: (carbs: Double, fat: Double, protein: Double)] = [:]
        for meal in mealsInRange {
            let dayStart = calendar.startOfDay(for: meal.date)
            let current = macrosByDate[dayStart] ?? (0,0,0)
            macrosByDate[dayStart] = (
                carbs: current.carbs + meal.totalCarbs,
                fat: current.fat + meal.totalFat,
                protein: current.protein + meal.totalProtein
            )
        }

        guard !macrosByDate.isEmpty else { return (0,0,0) }
        let totalCarbs = macrosByDate.values.reduce(0.0) { $0 + $1.carbs }
        let totalFat = macrosByDate.values.reduce(0.0) { $0 + $1.fat }
        let totalProtein = macrosByDate.values.reduce(0.0) { $0 + $1.protein }
        let dayCount = Double(macrosByDate.count)

        return (
            carbs: totalCarbs / dayCount,
            fat: totalFat / dayCount,
            protein: totalProtein / dayCount
        )
    }

    private var averageMacroPercents: (carbs: Int, fat: Int, protein: Int) {
        let macros = averageMacros
        let total = macros.carbs + macros.fat + macros.protein
        guard total > 0 else { return (0,0,0) }
        return (
            carbs: Int((macros.carbs / total) * 100),
            fat: Int((macros.fat / total) * 100),
            protein: Int((macros.protein / total) * 100)
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fwhite.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 20) {
                    TitleComponent(title: "Trends")

                    Picker("Range", selection: $selectedRange) {
                        ForEach(Range.allCases) { r in
                            Text(r.rawValue).tag(r)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .tint(.fblack)

                    ScrollView {
                        VStack(spacing: 16) {
                            // Calories
                            RoundedCard {
                                HStack(alignment: .firstTextBaseline) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(selectedRange == .daily ? "Calories" : "Average Calories")
                                            .foregroundStyle(.fblack)
                                            .font(.system(.headline, design: .rounded))
                                        Text("Goal: \(Int(calorieGoal)) cal")
                                            .foregroundStyle(.secondary)
                                            .font(.system(.subheadline, design: .rounded))
                                    }
                                    Spacer()
                                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                                        Text(selectedRange == .daily ? "\(Int(totalCalories))" : "\(Int(averageCalories))")
                                            .foregroundStyle(.fgreen)
                                            .font(.system(.title2, design: .rounded))
                                            .fontWeight(.bold)
                                        Text("cal")
                                            .foregroundStyle(.secondary)
                                            .font(.system(.subheadline, design: .rounded))
                                    }
                                }

                                if selectedRange == .daily {
                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            Capsule()
                                                .fill(Color.secondary.opacity(0.2))
                                                .frame(height: 8)
                                            Capsule()
                                                .fill(Color.fgreen)
                                                .frame(width: geo.size.width * calorieProgress, height: 8)
                                        }
                                    }
                                    .frame(height: 8)
                                    .padding(.top, 10)
                                }

                                if selectedRange != .daily {
                                    if calorieHistory.isEmpty {
                                        GraphPlaceholder()
                                            .padding(.top, 10)
                                    } else {
                                        CalorieChart(history: calorieHistory)
                                            .padding(.top, 10)
                                    }
                                }
                            }

                            // Macros
                            RoundedCard {
                                VStack(alignment: .leading, spacing: 14) {
                                    Text("Macros")
                                        .foregroundStyle(.fblack)
                                        .font(.system(.headline, design: .rounded))

                                    MacroRow(name: "Carbs",   goalPercent: macroGoals.carbs,
                                             actualPercent: selectedRange == .daily ? carbsPercent : averageMacroPercents.carbs,
                                             tint: .fgreen)
                                    MacroRow(name: "Fat",     goalPercent: macroGoals.fat,
                                             actualPercent: selectedRange == .daily ? fatPercent : averageMacroPercents.fat,
                                             tint: .fred)
                                    MacroRow(name: "Protein", goalPercent: macroGoals.protein,
                                             actualPercent: selectedRange == .daily ? proteinPercent : averageMacroPercents.protein,
                                             tint: .forange)
                                }
                            }

                            // Weight
                            RoundedCard {
                                HStack(alignment: .firstTextBaseline) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(selectedRange == .daily ? "Weight" : "Change")
                                            .foregroundStyle(.fblack)
                                            .font(.system(.headline, design: .rounded))
                                        Text("Goal: \(Int(weightGoal)) \(selectedWeightUnitSymbol)")
                                            .foregroundStyle(.secondary)
                                            .font(.system(.subheadline, design: .rounded))
                                    }
                                    Spacer()
                                    if selectedRange == .daily {
                                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                                            Text("\(Int(currentWeight))")
                                                .foregroundStyle(.fgreen)
                                                .font(.system(.title2, design: .rounded))
                                                .fontWeight(.bold)
                                            Text(currentWeightUnit)
                                                .foregroundStyle(.secondary)
                                                .font(.system(.subheadline, design: .rounded))
                                        }
                                    } else {
                                        HStack(spacing: 6) {
                                            Image(systemName: weightChangeIcon)
                                                .foregroundStyle(weightChangeColor)
                                                .font(.system(size: 18, weight: .semibold))
                                            Text(abs(weightChangeDelta), format: .number.precision(.fractionLength(1)))
                                                .foregroundStyle(weightChangeColor)
                                                .font(.system(.title3, design: .rounded))
                                                .fontWeight(.bold)
                                            Text(currentWeightUnit)
                                                .foregroundStyle(.secondary)
                                                .font(.system(.subheadline, design: .rounded))
                                        }
                                    }
                                }

                                if selectedRange != .daily {
                                    if weightEntries.isEmpty {
                                        GraphPlaceholder()
                                            .padding(.top, 10)
                                    } else {
                                        WeightChart(entries: weightEntries)
                                            .padding(.top, 10)
                                    }
                                }
                            }

                            // Top foods
                            RoundedCard {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Top 5 Foods")
                                        .foregroundStyle(.fblack)
                                        .font(.system(.headline, design: .rounded))

                                    if topFoods.isEmpty {
                                        Text("No foods logged yet")
                                            .foregroundStyle(.secondary)
                                            .font(.system(.body, design: .rounded))
                                            .padding(.vertical, 8)
                                    } else {
                                        VStack(spacing: 8) {
                                            ForEach(topFoods, id: \.name) { food in
                                                TopFoodRow(name: food.name, count: food.count)
                                            }
                                        }
                                    }
                                }
                            }

                            // Insights (sample)
                            Text("Insights")
                                .foregroundStyle(.fblack)
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 10)

                            InsightCard(
                                accent: .fgreen,
                                title: "Great Fiber Intake",
                                subtitle: "You're meeting your fiber goals",
                                trailingIcon: "checkmark.seal.fill"
                            )
                            InsightCard(
                                accent: .fred,
                                title: "Low Protein Detected",
                                subtitle: "You averaged 45g/day this week (Goal: 80g)",
                                trailingIcon: "exclamationmark.triangle.fill"
                            )
                        }
                        .padding(.bottom, 24)
                    }
                }
                .padding(35)
            }
            .onAppear {
                loadMeals() // No mock seeding
            }
            .onChange(of: selectedRange) { _, _ in
                updateWeightEntries()
            }
        }
    }

    private func loadMeals() {
        todaysMeals = MealStorage.shared.mealsForToday()
        updateWeightEntries()
    }

    private func updateWeightEntries() {
        let daysToShow = selectedRange == .weekly ? 7 : 30
        weightEntries = WeightStorage.shared.weightsForLastDays(daysToShow)
    }
}

// MARK: - Helpers

private struct RoundedCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.fwhite)
                .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
        )
    }
}

private struct MacroRow: View {
    let name: String
    let goalPercent: Int
    let actualPercent: Int
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .foregroundStyle(.fblack)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.semibold)

            HStack {
                Text("Goal")
                    .foregroundStyle(.secondary)
                    .font(.system(.caption, design: .rounded))
                    .frame(width: 50, alignment: .leading)
                ProgressBar(value: goalPercent, tint: tint.opacity(0.6))
                Text("\(goalPercent)%")
                    .foregroundStyle(.secondary)
                    .font(.system(.caption, design: .rounded))
            }

            HStack {
                Text("Actual")
                    .foregroundStyle(.secondary)
                    .font(.system(.caption, design: .rounded))
                    .frame(width: 50, alignment: .leading)
                ProgressBar(value: actualPercent, tint: tint)
                Text("\(actualPercent)%")
                    .foregroundStyle(.secondary)
                    .font(.system(.caption, design: .rounded))
            }
        }
    }
}

private struct ProgressBar: View {
    let value: Int // 0...100
    let tint: Color

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.secondary.opacity(0.15))
                Capsule()
                    .fill(tint)
                    .frame(width: geo.size.width * CGFloat(min(max(value, 0), 100)) / 100.0)
            }
        }
        .frame(height: 8)
        .frame(maxWidth: .infinity)
    }
}

private struct GraphPlaceholder: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondary.opacity(0.12))
            Text("Graph goes here")
                .foregroundStyle(.secondary)
                .font(.system(.subheadline, design: .rounded))
        }
        .frame(height: 120)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
}

private struct TopFoodRow: View {
    let name: String
    let count: Int

    var body: some View {
        HStack {
            Text(name)
                .foregroundStyle(.fblack)
                .font(.system(.body, design: .rounded))
            Spacer()
            Text("\(count)x")
                .foregroundStyle(.secondary)
                .font(.system(.subheadline, design: .rounded))
        }
        .padding(10)
        .background(Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct InsightCard: View {
    let accent: Color
    let title: String
    let subtitle: String
    let trailingIcon: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Rectangle()
                .fill(accent)
                .frame(width: 6)
                .cornerRadius(3)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .foregroundStyle(.fblack)
                    .font(.system(.headline, design: .rounded))
                Text(subtitle)
                    .foregroundStyle(.secondary)
                    .font(.system(.subheadline, design: .rounded))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Image(systemName: trailingIcon)
                .foregroundStyle(accent)
                .font(.system(size: 22, weight: .semibold))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.fwhite)
                .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
        )
    }
}

private struct WeightChart: View {
    let entries: [WeightEntry]

    var body: some View {
        Chart {
            ForEach(entries) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Weight", entry.weight)
                )
                .foregroundStyle(Color.fgreen)
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Date", entry.date),
                    y: .value("Weight", entry.weight)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.fgreen.opacity(0.3), Color.fgreen.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", entry.date),
                    y: .value("Weight", entry.weight)
                )
                .foregroundStyle(Color.fgreen)
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month().day())
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .frame(height: 120)
    }
}

private struct CalorieChart: View {
    let history: [(date: Date, calories: Double)]

    var body: some View {
        Chart {
            ForEach(history, id: \.date) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Calories", entry.calories)
                )
                .foregroundStyle(Color.forange)
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Date", entry.date),
                    y: .value("Calories", entry.calories)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.forange.opacity(0.3), Color.forange.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", entry.date),
                    y: .value("Calories", entry.calories)
                )
                .foregroundStyle(Color.forange)
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month().day())
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .frame(height: 120)
    }
}

#Preview {
    TrendsView()
}
