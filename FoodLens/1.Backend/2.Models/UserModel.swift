//
//  UserModel.swift
//  FoodLens
//
//  Created by Melanie & Muna on 11/7/25.
//

import SwiftUI                  // ?
import Combine                  // ObservableObject, @Published
import Foundation               // Date, Locale, Codable, Calendar

// MARK: - Demographics
enum UnitSystem: String, CaseIterable, Codable { case imperial, metric }    // (MENU)
enum EnergyUnit: String, CaseIterable, Codable { case kcal, kJ }            // (MENU)

enum Sex: String, CaseIterable, Codable {                                   // (WHEEL)
    case male, female, other
    var label: String {
        switch self {
            case .male:     return "Male"
            case .female:   return "Female"
            case .other:    return "Other"
        }
    }
}

// MARK: - Weight Goals
enum ActivityLevel: String, CaseIterable, Codable {                                             // (WHEEL)
    case sedentary, lightlyActive, moderatelyActive, veryActive, extraActive
    // Display name
    var label: String {
        switch self {
            case .sedentary:        return "Sedentary"
            case .lightlyActive:    return "Lightly Active"
            case .moderatelyActive: return "Moderately Active"
            case .veryActive:       return "Very Active"
            case .extraActive:      return "Extra Active"
        }
    }
    // Short description
    var description: String {
        switch self {
            case .sedentary:        return "Little/no exercise"
            case .lightlyActive:    return "Light exercise 1–3 days/week"
            case .moderatelyActive: return "Moderate exercise 3–5 days/week"
            case .veryActive:       return "Hard exercise 6–7 days/week"
            case .extraActive:      return "Physical job or twice-daily training"
        }
    }
    // Activity multiplier used for calorie calculation
    var multiplier: Double {
        switch self {
            case .sedentary:        return 1.2
            case .lightlyActive:    return 1.375
            case .moderatelyActive: return 1.55
            case .veryActive:       return 1.725
            case .extraActive:      return 1.9
        }
    }
}
enum Target: String, CaseIterable, Codable {                                               // (SEGMENTED)
    case lose, gain, maintain
    var label: String {
        switch self {
            case .lose:     return "lose"
            case .gain:     return "gain"
            case .maintain: return "maintain"
        }
    }
}
enum GoalTimeframeMode: String, CaseIterable, Codable {                                         // (SEGMENTED)
    case rate, duration
    var label: String {
        switch self {
            case .rate:     return "rate"
            case .duration: return "duration"
        }
    }
}
enum GoalRateUnit: String, CaseIterable, Codable {                                              // (WHEEL)
    case week, month
    var label: String {
        switch self {
            case .week:     return "per week"
            case .month:    return "per month"
        }
    }
}                                                                                               // (WHEEL)
enum GoalDurationUnit: String, CaseIterable, Codable {
    case weeks, months
    var label: String {
        switch self {
            case .weeks:    return "weeks"
            case .months:   return "months"
        }
    }
}

final class UserModel: ObservableObject {
    // MARK: - Helpers
    private func round1(_ x: Double) -> Double {
        (x * 10).rounded() / 10.0
    }
    
    // MARK: - Demographics
    @Published var name: String = ""    // Note: Only need first name
    
    // Regional defaults
    static var region: String {
        Locale.current.region?.identifier ?? "US"
    }
    
    static func localUnitSystem() -> UnitSystem {
        return ["US", "LR", "MM"].contains(region) ? .imperial : .metric
    }

    static func localEnergyUnit() -> EnergyUnit {
        // Default kJ for GB/EU/AU/NZ/IE; kcal elsewhere
        return ["GB", "IE", "AU", "NZ"].contains(region) ? .kJ : .kcal
    }
    
    // Choose System
    @Published var selectedWeightUnit: UnitSystem = UserModel.localUnitSystem() {
        didSet { convertWeight(from: oldValue, to: selectedWeightUnit) }
    }
    @Published var selectedHeightUnit: UnitSystem = UserModel.localUnitSystem() {
        didSet { convertHeight(to: selectedHeightUnit) }
    }
    @Published var selectedEnergyUnit: EnergyUnit = UserModel.localEnergyUnit()
    
    @Published var feet: Int = 5
    @Published var inches: Int = 8
    @Published var cm: Double = 172.72
    
    func convertHeight(to unit: UnitSystem) {
        // If switching to metric (cm)
        if unit == .metric {
            let totalInches = Double(feet) * 12.0 + Double(inches)
            cm = round(totalInches * 2.54)
        }
        // If switching to imperial (ft/in)
        else if unit == .imperial {
            let totalInches = cm / 2.54
            let ft = Int(totalInches / 12.0)
            let inch = Int(round(totalInches - Double(ft) * 12.0))
            feet = ft
            inches = min(inch, 11) // safety clamp
        }
    }
    
    // height in cm (preferred for calculations)
    var heightCm: Double {
        switch selectedHeightUnit {
            case .metric:       return cm
            case .imperial:     return (Double(feet) * 12.0 + Double(inches)) * 2.54
        }
    }
    
    // Note: Has to at least be 13, users under can't use the app
    @Published var birthDate: Date?
    
    var maxBirthDate: Date {
        Calendar.current.date(byAdding: .year, value: -13, to: Date()) ?? Date()
    }
    
    var age: Int? {
        guard let bDate = birthDate else { return nil }
        return Calendar.current.dateComponents([.year], from: bDate, to: Date()).year
    }
    var isEligible: Bool { (age ?? 0) >= 13 }
    
    @Published var sex: Sex = .male // Note: if other is chosen, calculations will be based on a males body
    
    
    // MARK: - Weight Goals
    @Published var currentActivityLevel: ActivityLevel = .sedentary
    
    @Published var currentWeight: Double? {
        didSet {
            guard let w = currentWeight else { return }
            let r = round1(w)
            if r != w {
                currentWeight = r
            }
        }
    }
    
    func convertWeight(from old: UnitSystem, to new: UnitSystem) {
        guard old != new else { return }
        
        func converted(_ w: Double) -> Double { // w is currentWeight/goalWeight
            if old == .imperial && new == .metric { return w * 0.45359237 }
            else if old == .metric && new == .imperial { return w / 0.45359237 }
            return w
        }
        
        if let w = currentWeight { currentWeight = round1(converted(w)) }
        if let g = goalWeight { goalWeight = round1(converted(g)) }
    }
    
    @Published var bodyFatPercent: Double?
    
    var leanBodyMassKg: Double? { // for calculations
        guard let kg = weightKg else { return nil }
        guard let bf = bodyFatPercent else { return nil }
        return kg * (1 - bf / 100)
    }
    
    @Published var target: Target = .maintain
    
    @Published var goalWeight: Double? {
        didSet {
            guard let g = goalWeight else { return }
            let r = round1(g)
            if r != g {
                goalWeight = r
            }
        }
    }
    
    var weightTarget: Double { // amount to lose/gain (in selected unit)
        guard let w = currentWeight, let g = goalWeight else { return 0 }
        switch target {
            case .lose:     return round1(w - g)
            case .gain:     return round1(g - w)
            case .maintain: return 0
        }
    }
    
    // Converts any weight (lb or kg) to kg based on current unit selection (have kg at calculation time)
    func toKg(_ weight: Double?) -> Double? {
        guard let w = weight else { return nil }
        switch selectedWeightUnit {
            case .metric:   return w                // assume kg
            case .imperial: return w * 0.45359237   // lb → kg
        }
    }
    
    var weightKg: Double? {
        toKg(currentWeight)
    }

    var goalWeightKg: Double? {
        toKg(goalWeight)
    }
    
    var weightTargetKg: Double? { // how much lost/gained
        toKg(weightTarget)
    }

    // Choose Mode:
    @Published var goalTimeframeMode: GoalTimeframeMode = .rate
    
    // if rate:
    @Published var goalRateAmount: Double? {
        didSet {
            guard let a = goalRateAmount else { return }
            let r = round1(a)
            if r != a {
                goalRateAmount = r
            }
        }
    }                      // Note: positive (lbs/kg) amount to lose/gain
    @Published var goalRateUnit: GoalRateUnit = .week

    // if duration:
    @Published var goalDurationValue: Int = 12                  // Note: 1 to 104 weeks or 1 to 24 months
    @Published var goalDurationUnit: GoalDurationUnit = .weeks
    
    var etaDateFromDuration: Date? {
        let weeks: Double = goalDurationUnit == .weeks ? Double(goalDurationValue) : Double(goalDurationValue) * 4.345
        guard weeks > 0 else { return nil }
        return Calendar.current.date(byAdding: .day, value: Int(round(weeks * 7)), to: Date())
    }

    var etaMonthYearString: String {
        guard let d = etaDateFromDuration else { return "—" }
        return d.formatted(.dateTime.month(.wide).year())
    }

    // MARK: - Calorie Goals (Calculated based off Demographics & Weight Goals)
    var calories: Double? {
        var BMR = 0.0
        
        // If body mass provided (kg), use Katch–McArdle Formula
        if let lbm = leanBodyMassKg {
            BMR = 370 + (21.6 * lbm)                     // BMR = 370 + (21.6 * lean body mass (kg))
        } else {
            // use Mifflin–St Jeor Formula to calculate Basal Metabolic Rate (BMR)
            guard let kg = weightKg, let age = age else { return nil }
            let cm = heightCm
        
            switch sex {
                case .female:
                    BMR = 10 * kg + 6.25 * cm - 5 * Double(age) - 161
                case .male, .other:
                    BMR = 10 * kg + 6.25 * cm - 5 * Double(age) + 5
            }
        }
        
        let TDEE = BMR * currentActivityLevel.multiplier
        
        // Daily adjustment from weekly rate (if nil/missing, treat as 0 = maintenance)
        let weeklyKg = kgPerWeek() ?? 0
        let dailyAdj = (weeklyKg * 7700.0) / 7.0  // kcal/day
        let targetKcal = TDEE + dailyAdj
        
        switch selectedEnergyUnit {
            case .kcal:
                return targetKcal
            case .kJ:
                return targetKcal * 4.184
        }
    }
    
    // Normalize to kg/week based on mode
    func kgPerWeek() -> Double? {
        switch goalTimeframeMode {
            case .rate:
                guard let amt = goalRateAmount else { return 0 } // treat missing as maintain
                // Convert amount to kg
                let amountKg = (selectedWeightUnit == .imperial) ? (amt * 0.45359237) : amt
                // If per month, convert to per week
                let perWeekKg = (goalRateUnit == .week) ? amountKg : (amountKg / 4.345)
                // Sign by Target
                switch target {
                    case .lose:     return -abs(perWeekKg)
                    case .gain:     return  abs(perWeekKg)
                    case .maintain: return  0
                }

            case .duration:
                // Need current and goal weight and duration
                guard let cw = currentWeight, let gw = goalWeight else { return 0 }
                let v = goalDurationValue
                // weight delta in kg (goal - current)
                let deltaKg = (selectedWeightUnit == .imperial) ? ((gw - cw) * 0.45359237) : (gw - cw)
                let weeks = goalDurationUnit == .weeks ? Double(v) : Double(v) * 4.345
                guard weeks > 0 else { return 0 }
                return deltaKg / weeks   // sign comes from goal vs current
            }
    }

    
    // MARK: - Macro Goals
    @Published var carbsGrams: Double?
    @Published var proteinGrams: Double?
    @Published var fatGrams: Double?
    @Published var carbsPercent: Int?
    @Published var proteinPercent: Int?
    @Published var fatPercent: Int?

    
    // MARK: - Access
    @Published var cameraEnabled: Bool = false
    @Published var healthEnabled: Bool = false
}
