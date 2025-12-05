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

    // Insights VM (LLM coaching via Firebase AI template)
    @StateObject private var insightsVM = InsightsViewModel(
        coach: LLMCoachService() // uses FirebaseAI template "nutritioncoach"
    )

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

                            // Insights (LLM coaching)
                            Text("Insights")
                                .foregroundStyle(.fblack)
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 10)

                            if insightsVM.isLoading {
                                RoundedCard {
                                    HStack {
                                        ProgressView().tint(.fgreen)
                                        Text("Generating your weekly coaching…")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            } else if let advice = insightsVM.advice {
                                // Summary card (new)
                                if let summary = advice.summary, !summary.isEmpty {
                                    RoundedCard {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Summary")
                                                .foregroundStyle(.fblack)
                                                .font(.system(.headline, design: .rounded))
                                            Text(summary)
                                                .foregroundStyle(.secondary)
                                                .font(.system(.subheadline, design: .rounded))
                                        }
                                    }
                                }

                                // Insight cards
                                ForEach(advice.insights) { ins in
                                    InsightCard(
                                        accent: ins.severity.accentColor,
                                        title: ins.title,
                                        subtitle: ins.message,
                                        trailingIcon: ins.severity.trailingIcon
                                    )
                                }

                                // Actions
                                if !advice.actions.isEmpty {
                                    RoundedCard {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Next steps")
                                                .foregroundStyle(.fblack)
                                                .font(.system(.headline, design: .rounded))
                                            ForEach(advice.actions, id: \.self) { a in
                                                HStack(alignment: .top, spacing: 8) {
                                                    Image(systemName: "checkmark.circle")
                                                        .foregroundStyle(.fgreen)
                                                    Text(a)
                                                        .foregroundStyle(.secondary)
                                                        .font(.system(.subheadline, design: .rounded))
                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                RoundedCard {
                                    Text("No insights yet. Log food to see coaching here.")
                                        .foregroundStyle(.secondary)
                                        .font(.system(.subheadline, design: .rounded))
                                }
                            }
                        }
                        .padding(.bottom, 24)
                    }
                }
                .padding(35)
            }
            .onAppear {
                loadMeals()
                refreshInsights()
            }
            .onChange(of: selectedRange) { _, _ in
                updateWeightEntries()
                refreshInsights()
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

    private func refreshInsights() {
        let window: StatsWindow = {
            switch selectedRange {
            case .daily:   return .daily
            case .weekly:  return .weekly
            case .monthly: return .monthly
            }
        }()
        Task { await insightsVM.refresh(window: window, userModel: userModel) }
    }
}

// MARK: - Helpers (UI mapping for severity)

private extension InsightSeverity {
    var accentColor: Color {
        switch self {
        case .success: return .fgreen
        case .info:    return .fblue
        case .warning: return .forange
        case .alert:   return .fred
        }
    }
    var trailingIcon: String {
        switch self {
        case .success: return "checkmark.seal.fill"
        case .info:    return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .alert:   return "exclamationmark.octagon.fill"
        }
    }
}

#Preview {
    TrendsView()
}
