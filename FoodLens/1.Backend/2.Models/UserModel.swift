//
//  UserModel.swift
//  FoodLens
//
//  Created by Melanie & Muna on 11/7/25.
//

import Combine                  // ObservableObject, @Published
import Foundation               // Date, Locale, Codable, Calendar

// MARK: - Demographics

enum UnitSystem: String, CaseIterable, Codable { case imperial, metric }
enum EnergyUnit: String, CaseIterable, Codable { case kcal, kJ }

enum Sex: String, CaseIterable, Codable {
    case male, female, other
    var label: String {
        switch self {
        case .male:   return "Male"
        case .female: return "Female"
        case .other:  return "Other"
        }
    }
}

// MARK: - Weight Goals

enum ActivityLevel: String, CaseIterable, Codable {
    case sedentary, lightlyActive, moderatelyActive, veryActive, extraActive

    var label: String {
        switch self {
        case .sedentary:        return "Sedentary"
        case .lightlyActive:    return "Lightly Active"
        case .moderatelyActive: return "Moderately Active"
        case .veryActive:       return "Very Active"
        case .extraActive:      return "Extra Active"
        }
    }

    var description: String {
        switch self {
        case .sedentary:        return "Little/no exercise"
        case .lightlyActive:    return "Light exercise 1–3 days/week"
        case .moderatelyActive: return "Moderate exercise 3–5 days/week"
        case .veryActive:       return "Hard exercise 6–7 days/week"
        case .extraActive:      return "Physical job or twice-daily training"
        }
    }

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

enum Target: String, CaseIterable, Codable {
    case lose, gain, maintain
    var label: String {
        switch self {
        case .lose:     return "lose"
        case .gain:     return "gain"
        case .maintain: return "maintain"
        }
    }
}

enum GoalTimeframeMode: String, CaseIterable, Codable {
    case rate, duration
    var label: String {
        switch self {
        case .rate:     return "rate"
        case .duration: return "duration"
        }
    }
}

enum GoalRateUnit: String, CaseIterable, Codable {
    case week, month
    var label: String {
        switch self {
        case .week:  return "per week"
        case .month: return "per month"
        }
    }
}

enum GoalDurationUnit: String, CaseIterable, Codable {
    case weeks, months
    var label: String {
        switch self {
        case .weeks:  return "weeks"
        case .months: return "months"
        }
    }
}

// MARK: - UserModel

final class UserModel: ObservableObject {

    // MARK: Helpers

    private func round1(_ x: Double) -> Double {
        (x * 10).rounded() / 10.0
    }

    // MARK: Demographics

    @Published var name: String = ""

    static var region: String {
        Locale.current.region?.identifier ?? "US"
    }

    static func localUnitSystem() -> UnitSystem {
        ["US", "LR", "MM"].contains(region) ? .imperial : .metric
    }

    static func localEnergyUnit() -> EnergyUnit {
        ["GB", "IE", "AU", "NZ"].contains(region) ? .kJ : .kcal
    }

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
        if unit == .metric {
            let totalInches = Double(feet) * 12.0 + Double(inches)
            cm = round(totalInches * 2.54)
        } else {
            let totalInches = cm / 2.54
            let ft = Int(totalInches / 12.0)
            let inch = Int(round(totalInches - Double(ft) * 12.0))
            feet = ft
            inches = min(inch, 11)
        }
    }

    var heightCm: Double {
        switch selectedHeightUnit {
        case .metric:   return cm
        case .imperial: return (Double(feet) * 12.0 + Double(inches)) * 2.54
        }
    }

    @Published var birthDate: Date?

    var maxBirthDate: Date {
        Calendar.current.date(byAdding: .year, value: -13, to: Date()) ?? Date()
    }

    var age: Int? {
        guard let bDate = birthDate else { return nil }
        return Calendar.current.dateComponents([.year], from: bDate, to: Date()).year
    }

    var isEligible: Bool { (age ?? 0) >= 13 }

    @Published var sex: Sex = .male      // .other uses male formula
    
    var nameErrorText: String? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Please enter your name." : nil
    }

    var birthdateErrorText: String? {
        if birthDate == nil {
            return "Please select your birth date."
        }
        // Technically DatePicker already enforces >= 13, but we keep this in case.
        if !isEligible {
            return "You must be at least 13 years old to use FoodLens."
        }
        return nil
    }

    var heightErrorText: String? {
        guard heightCm >= 100, heightCm <= 250 else {
            return "Please enter a realistic height."
        }
        return nil
    }

    // MARK: Weight Goals

    @Published var currentActivityLevel: ActivityLevel = .sedentary

    @Published var currentWeight: Double? {
        didSet {
            guard let w = currentWeight else { return }
            let r = round1(w)
            if r != w { currentWeight = r }
        }
    }

    func convertWeight(from old: UnitSystem, to new: UnitSystem) {
        guard old != new else { return }

        func converted(_ w: Double) -> Double {
            if old == .imperial && new == .metric { return w * 0.45359237 }
            if old == .metric   && new == .imperial { return w / 0.45359237 }
            return w
        }

        if let w = currentWeight { currentWeight = round1(converted(w)) }
        if let g = goalWeight    { goalWeight    = round1(converted(g)) }
    }

    @Published var bodyFatPercent: Double?

    var leanBodyMassKg: Double? {
        guard let kg = weightKg, let bf = bodyFatPercent else { return nil }
        return kg * (1 - bf / 100)
    }

    @Published var target: Target = .maintain

    @Published var goalWeight: Double? {
        didSet {
            guard let g = goalWeight else { return }
            let r = round1(g)
            if r != g { goalWeight = r }
        }
    }

    // Amount to lose/gain in the selected weight unit
    var weightTarget: Double {
        guard let w = currentWeight, let g = goalWeight else { return 0 }
        switch target {
        case .lose:     return round1(w - g)
        case .gain:     return round1(g - w)
        case .maintain: return 0
        }
    }

    func toKg(_ weight: Double?) -> Double? {
        guard let w = weight else { return nil }
        switch selectedWeightUnit {
        case .metric:   return w
        case .imperial: return w * 0.45359237
        }
    }

    var weightKg: Double?      { toKg(currentWeight) }
    var goalWeightKg: Double?  { toKg(goalWeight) }
    var weightTargetKg: Double? { toKg(weightTarget) }

    // Timeframe

    @Published var goalTimeframeMode: GoalTimeframeMode = .rate

    @Published var goalRateAmount: Double? {
        didSet {
            guard let a = goalRateAmount else { return }
            let r = round1(a)
            if r != a { goalRateAmount = r }
        }
    }

    @Published var goalRateUnit: GoalRateUnit = .week

    @Published var goalDurationValue: Int = 12
    @Published var goalDurationUnit: GoalDurationUnit = .weeks

    var etaDateFromDuration: Date? {
        let weeks: Double = goalDurationUnit == .weeks
            ? Double(goalDurationValue)
            : Double(goalDurationValue) * 4.345
        guard weeks > 0 else { return nil }
        return Calendar.current.date(byAdding: .day, value: Int(round(weeks * 7)), to: Date())
    }

    var etaMonthYearString: String {
        guard let d = etaDateFromDuration else { return "—" }
        return d.formatted(.dateTime.month(.wide).year())
    }
    
    // Weight goal error texts

    var currentWeightErrorText: String? {
        if currentWeight == nil || (currentWeight ?? 0) <= 0 {
            return "Please enter your current weight."
        }
        return nil
    }

    /// Explains what's wrong with the goal weight (for lose/gain)
    var weightGoalErrorText: String? {
        guard let cw = currentWeight, cw > 0 else {
            return "Please enter your current weight first."
        }

        switch target {
        case .maintain:
            // no goal weight needed
            return nil

        case .lose:
            guard let gw = goalWeight else {
                return "Please enter a goal weight."
            }
            if gw >= cw {
                return "Goal weight must be lower than your current weight to lose weight."
            }
            return nil

        case .gain:
            guard let gw = goalWeight else {
                return "Please enter a goal weight."
            }
            if gw <= cw {
                return "Goal weight must be higher than your current weight to gain weight."
            }
            return nil
        }
    }

    /// Explains what's wrong with the rate/duration (for lose/gain)
    var timeframeErrorText: String? {
        guard target != .maintain else { return nil }

        switch goalTimeframeMode {
        case .rate:
            guard let amt = goalRateAmount, amt > 0 else {
                return "Please enter a positive rate (for example, 0.5–1.0 per week)."
            }
            return nil
        case .duration:
            if goalDurationValue <= 0 {
                return "Duration must be at least 1 week or month."
            }
            return nil
        }
    }


    // MARK: Calorie Goals

    // BMR/TDEE-based recommended calories (always in kcal)
    private var recommendedKcal: Double? {
        var BMR = 0.0

        if let lbm = leanBodyMassKg {
            BMR = 370 + (21.6 * lbm)          // Katch-McArdle
        } else {
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

        // Adjustment from gain/lose rate (kg/week)
        let weeklyKg = kgPerWeek() ?? 0
        let dailyAdj = (weeklyKg * 7700.0) / 7.0      // kcal/day
        return TDEE + dailyAdj
    }

    // User override of calories (in selectedEnergyUnit)
    @Published var customCalories: Double?

    // Recommended calories in the selectedEnergyUnit
    var recommendedCalories: Double? {
        guard let base = recommendedKcal else { return nil }
        switch selectedEnergyUnit {
        case .kcal: return base
        case .kJ:   return base * 4.184
        }
    }

    // Calories the app will actually use
    var activeCalories: Double? {
        if let custom = customCalories { return custom }
        return recommendedCalories
    }

    // Reset override and go back to recommended
    func resetCaloriesToRecommended() {
        customCalories = nil
    }

    // Normalized kg/week based on mode + target
    func kgPerWeek() -> Double? {
        switch goalTimeframeMode {
        case .rate:
            guard let amt = goalRateAmount, amt > 0 else { return 0 } // treat missing as maintain
            let amountKg = (selectedWeightUnit == .imperial) ? (amt * 0.45359237) : amt
            let perWeekKg = (goalRateUnit == .week) ? amountKg : (amountKg / 4.345)

            switch target {
            case .lose:     return -abs(perWeekKg)
            case .gain:     return  abs(perWeekKg)
            case .maintain: return  0
            }

        case .duration:
            // only meaningful if they are actually gaining/losing
            guard target != .maintain,
                  let cw = currentWeight,
                  let gw = goalWeight else { return 0 }

            let v = goalDurationValue
            let deltaKg = (selectedWeightUnit == .imperial)
                ? ((gw - cw) * 0.45359237)
                : (gw - cw)
            let weeks = goalDurationUnit == .weeks ? Double(v) : Double(v) * 4.345
            guard weeks > 0 else { return 0 }
            return deltaKg / weeks
        }
    }

    // MARK: Macro Goals

    @Published var carbsPercent: Int = 50
    @Published var proteinPercent: Int = 20
    @Published var fatPercent: Int = 30

    @Published var carbsGrams: Double?
    @Published var proteinGrams: Double?
    @Published var fatGrams: Double?

    func updateMacroGramsFromPercents() {
        guard let cals = activeCalories else { return }
        let total = Double(cals)

        carbsGrams   = (total * Double(carbsPercent)   / 100.0) / 4.0
        proteinGrams = (total * Double(proteinPercent) / 100.0) / 4.0
        fatGrams     = (total * Double(fatPercent)     / 100.0) / 9.0
    }

    func updateMacroPercentsFromGrams() {
        guard let cals = activeCalories,
              let c = carbsGrams,
              let p = proteinGrams,
              let f = fatGrams,
              cals > 0
        else { return }

        let total = Double(cals)
        carbsPercent   = Int(round((c * 4.0 / total) * 100))
        proteinPercent = Int(round((p * 4.0 / total) * 100))
        // fill the rest with fat so sum is exactly 100
        fatPercent     = max(0, 100 - carbsPercent - proteinPercent)
    }

    func resetMacrosToRecommended() {
        carbsPercent   = 50
        proteinPercent = 20
        fatPercent     = 30
        updateMacroGramsFromPercents()
    }
    
    

    // MARK: Access

    @Published var cameraEnabled: Bool = false
    @Published var healthEnabled: Bool = false

    // MARK: Validation for Onboarding

    // 1. Demographics: name, height, age >= 13
    var isDemographicsValid: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasName = !trimmedName.isEmpty

        let validHeight = heightCm >= 100 && heightCm <= 250
        let validBirth  = birthDate != nil && isEligible

        return hasName && validHeight && validBirth
    }

    // 2. Weight goals:
    //  - must have current weight
    //  - if maintain: OK with just current weight
    //  - if lose: goalWeight < currentWeight + valid timeframe
    //  - if gain: goalWeight > currentWeight + valid timeframe
    var isWeightGoalsValid: Bool {
        guard let cw = currentWeight, cw > 0 else { return false }

        // Always have some activity level (non-optional) so we don't check it here.

        switch target {
        case .maintain:
            // no goal weight or timeframe required
            return true

        case .lose, .gain:
            guard let gw = goalWeight, gw > 0 else { return false }

            let goalRelationOK: Bool = {
                switch target {
                case .lose: return gw < cw
                case .gain: return gw > cw
                case .maintain: return true
                }
            }()

            let timeframeOK: Bool = {
                switch goalTimeframeMode {
                case .rate:
                    guard let amt = goalRateAmount else { return false }
                    return amt > 0
                case .duration:
                    return goalDurationValue > 0
                }
            }()

            return goalRelationOK && timeframeOK
        }
    }

    // 3. Calories: must have some calorie value
    var isCaloriesValid: Bool {
        if let cals = activeCalories {
            return cals > 400   // arbitrary minimum so they don't put 50 kcal lol
        }
        return false
    }

    // 4. Macros: require percentages that sum to exactly 100
    var isMacrosValid: Bool {
        carbsPercent + proteinPercent + fatPercent == 100
    }
    
    
    
}




extension UserModel {
    /// Flatten the user data so it can be stored in Firestore.
    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "name": name,
            "selectedWeightUnit": selectedWeightUnit.rawValue,
            "selectedHeightUnit": selectedHeightUnit.rawValue,
            "selectedEnergyUnit": selectedEnergyUnit.rawValue,
            "feet": feet,
            "inches": inches,
            "cm": cm,
            "sex": sex.rawValue,
            "currentActivityLevel": currentActivityLevel.rawValue,
            "target": target.rawValue,
            "goalTimeframeMode": goalTimeframeMode.rawValue,
            "goalRateUnit": goalRateUnit.rawValue,
            "goalDurationUnit": goalDurationUnit.rawValue,
            "goalDurationValue": goalDurationValue,
            "carbsPercent": carbsPercent,
            "proteinPercent": proteinPercent,
            "fatPercent": fatPercent,
            "cameraEnabled": cameraEnabled,
            "healthEnabled": healthEnabled
        ]
        
        if let birthDate {
            // store as unix seconds
            data["birthDate"] = birthDate.timeIntervalSince1970
        }
        if let currentWeight {
            data["currentWeight"] = currentWeight
        }
        if let bodyFatPercent {
            data["bodyFatPercent"] = bodyFatPercent
        }
        if let goalWeight {
            data["goalWeight"] = goalWeight
        }
        if let goalRateAmount {
            data["goalRateAmount"] = goalRateAmount
        }
        if let customCalories {
            data["customCalories"] = customCalories
        }
        if let carbsGrams {
            data["carbsGrams"] = carbsGrams
        }
        if let proteinGrams {
            data["proteinGrams"] = proteinGrams
        }
        if let fatGrams {
            data["fatGrams"] = fatGrams
        }
        
        return data
    }
    
    /// Apply Firestore data onto this model (used on login / sync).
    func applyFirestoreData(_ data: [String: Any]) {
        if let name = data["name"] as? String {
            self.name = name
        }
        if let raw = data["selectedWeightUnit"] as? String,
           let unit = UnitSystem(rawValue: raw) {
            self.selectedWeightUnit = unit
        }
        if let raw = data["selectedHeightUnit"] as? String,
           let unit = UnitSystem(rawValue: raw) {
            self.selectedHeightUnit = unit
        }
        if let raw = data["selectedEnergyUnit"] as? String,
           let unit = EnergyUnit(rawValue: raw) {
            self.selectedEnergyUnit = unit
        }
        if let feet = data["feet"] as? Int {
            self.feet = feet
        }
        if let inches = data["inches"] as? Int {
            self.inches = inches
        }
        if let cm = data["cm"] as? Double {
            self.cm = cm
        }
        if let raw = data["sex"] as? String,
           let sex = Sex(rawValue: raw) {
            self.sex = sex
        }
        if let raw = data["currentActivityLevel"] as? String,
           let level = ActivityLevel(rawValue: raw) {
            self.currentActivityLevel = level
        }
        if let raw = data["target"] as? String,
           let target = Target(rawValue: raw) {
            self.target = target
        }
        if let raw = data["goalTimeframeMode"] as? String,
           let m = GoalTimeframeMode(rawValue: raw) {
            self.goalTimeframeMode = m
        }
        if let raw = data["goalRateUnit"] as? String,
           let u = GoalRateUnit(rawValue: raw) {
            self.goalRateUnit = u
        }
        if let raw = data["goalDurationUnit"] as? String,
           let u = GoalDurationUnit(rawValue: raw) {
            self.goalDurationUnit = u
        }
        if let v = data["goalDurationValue"] as? Int {
            self.goalDurationValue = v
        }
        
        if let t = data["birthDate"] as? TimeInterval {
            self.birthDate = Date(timeIntervalSince1970: t)
        }
        if let w = data["currentWeight"] as? Double {
            self.currentWeight = w
        }
        if let bf = data["bodyFatPercent"] as? Double {
            self.bodyFatPercent = bf
        }
        if let gw = data["goalWeight"] as? Double {
            self.goalWeight = gw
        }
        if let ra = data["goalRateAmount"] as? Double {
            self.goalRateAmount = ra
        }
        if let cc = data["customCalories"] as? Double {
            self.customCalories = cc
        }
        if let cg = data["carbsGrams"] as? Double {
            self.carbsGrams = cg
        }
        if let pg = data["proteinGrams"] as? Double {
            self.proteinGrams = pg
        }
        if let fg = data["fatGrams"] as? Double {
            self.fatGrams = fg
        }
        
        if let cp = data["carbsPercent"] as? Int {
            self.carbsPercent = cp
        }
        if let pp = data["proteinPercent"] as? Int {
            self.proteinPercent = pp
        }
        if let fp = data["fatPercent"] as? Int {
            self.fatPercent = fp
        }
        if let cam = data["cameraEnabled"] as? Bool {
            self.cameraEnabled = cam
        }
        if let health = data["healthEnabled"] as? Bool {
            self.healthEnabled = health
        }
    }
}
