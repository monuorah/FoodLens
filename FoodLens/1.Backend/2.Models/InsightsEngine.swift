// InsightsEngine.swift
import Foundation

enum StatsWindow: String, Codable { case daily, weekly, monthly }

struct StatsSnapshot: Codable {
    let window: StatsWindow
    let startDate: Date
    let endDate: Date
    let daysInWindow: Int
    let loggedDays: Int

    // Averages per logged day
    let avgCalories: Double
    let avgProteinG: Double
    let avgCarbsG: Double
    let avgFatG: Double
    let avgFiberG: Double
    let avgSugarsG: Double
    let avgSodiumMg: Double

    // Goals (resolved to grams where possible)
    let goalCalories: Double?
    let goalProteinG: Double?
    let goalCarbsG: Double?
    let goalFatG: Double?
    let goalFiberG: Double?    // defaulted from calories if nil
    let goalSugarsG: Double?   // defaulted from calories if nil
    let goalSodiumMg: Double?  // default 2300 mg
}

enum InsightSeverity: String, Codable { case success, info, warning, alert }

struct Insight: Codable, Identifiable {
    let id: String
    let title: String
    let message: String
    let severity: InsightSeverity
}

enum InsightsEngine {
    static func snapshot(window: StatsWindow, userModel: UserModel, reference: Date = Date()) -> StatsSnapshot {
        let calendar = Calendar.current

        // Compute start/end/days with a statement switch (not an expression switch)
        let start: Date
        let end: Date
        let days: Int

        switch window {
        case .daily:
            let s = calendar.startOfDay(for: reference)
            let e = calendar.date(byAdding: .day, value: 1, to: s)!
            start = s
            end = e
            days = 1

        case .weekly:
            let s = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: reference))!
            let e = calendar.date(byAdding: .day, value: 1, to: reference)!
            start = s
            end = e
            days = 7

        case .monthly:
            let s = calendar.date(byAdding: .day, value: -29, to: calendar.startOfDay(for: reference))!
            let e = calendar.date(byAdding: .day, value: 1, to: reference)!
            start = s
            end = e
            days = 30
        }

        let meals = MealStorage.shared.meals(in: DateInterval(start: start, end: end))
        var byDay: [Date: (kcal: Double, p: Double, c: Double, f: Double, fi: Double, su: Double, na: Double)] = [:]

        for m in meals {
            let d = calendar.startOfDay(for: m.date)
            var t = byDay[d] ?? (0,0,0,0,0,0,0)
            t.kcal += m.totalCalories
            t.p    += m.totalProtein
            t.c    += m.totalCarbs
            t.f    += m.totalFat
            t.fi   += m.totalFiberG
            t.su   += m.totalSugarsG
            t.na   += m.totalSodiumMg
            byDay[d] = t
        }

        let loggedDays = byDay.count
        func avg(_ keyPath: KeyPath<(kcal: Double, p: Double, c: Double, f: Double, fi: Double, su: Double, na: Double), Double>) -> Double {
            guard loggedDays > 0 else { return 0 }
            let total = byDay.values.reduce(0) { $0 + $1[keyPath: keyPath] }
            return total / Double(loggedDays)
        }

        // Resolve goals
        let goalCalories = userModel.activeCalories
        let macroGoalsG: (p: Double?, c: Double?, f: Double?) = {
            if let pg = userModel.proteinGrams, let cg = userModel.carbsGrams, let fg = userModel.fatGrams {
                return (pg, cg, fg)
            }
            guard let kcals = userModel.activeCalories else { return (nil, nil, nil) }
            let p = Double(userModel.proteinPercent) * kcals / 100.0 / 4.0
            let c = Double(userModel.carbsPercent)   * kcals / 100.0 / 4.0
            let f = Double(userModel.fatPercent)     * kcals / 100.0 / 9.0
            return (p, c, f)
        }()

        // Defaults for non‑macro goals
        let goalFiberG   = goalCalories.map { max(0, ($0 / 1000.0) * 14.0) } // 14 g per 1000 kcal
        let goalSugarsG  = goalCalories.map { max(0, ($0 * 0.10) / 4.0) }     // 10% of kcal to sugar grams
        let goalSodiumMg = 2300.0

        return StatsSnapshot(
            window: window,
            startDate: start,
            endDate: end,
            daysInWindow: days,
            loggedDays: loggedDays,
            avgCalories: avg(\.kcal),
            avgProteinG: avg(\.p),
            avgCarbsG:   avg(\.c),
            avgFatG:     avg(\.f),
            avgFiberG:   avg(\.fi),
            avgSugarsG:  avg(\.su),
            avgSodiumMg: avg(\.na),
            goalCalories: goalCalories,
            goalProteinG: macroGoalsG.p,
            goalCarbsG:   macroGoalsG.c,
            goalFatG:     macroGoalsG.f,
            goalFiberG:   goalFiberG,
            goalSugarsG:  goalSugarsG,
            goalSodiumMg: goalSodiumMg
        )
    }
}
