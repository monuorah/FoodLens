//
//  WeightStorage.swift
//  FoodLens
//
//  Created by Muna on 12/2/24.
//

import Foundation
import FirebaseAuth

struct WeightEntry: Codable, Identifiable {
    let id: UUID
    let weight: Double
    let unit: String // "lbs" or "kg"
    let date: Date

    init(weight: Double, unit: String, date: Date = Date()) {
        self.id = UUID()
        self.weight = weight
        self.unit = unit
        self.date = date
    }
}

class WeightStorage {
    static let shared = WeightStorage()

    private var userKey: String {
        guard let userId = Auth.auth().currentUser?.uid else {
            return "savedWeights_guest" // Fallback for signed-out state
        }
        return "savedWeights_\(userId)"
    }

    func saveWeight(_ entry: WeightEntry) {
        var weights = loadWeights()
        weights.append(entry)

        if let data = try? JSONEncoder().encode(weights) {
            UserDefaults.standard.set(data, forKey: userKey)
        }
    }

    func loadWeights() -> [WeightEntry] {
        guard let data = UserDefaults.standard.data(forKey: userKey),
              let weights = try? JSONDecoder().decode([WeightEntry].self, from: data) else {
            return []
        }
        return weights.sorted(by: { $0.date < $1.date })
    }

    func mostRecentWeight() -> WeightEntry? {
        return loadWeights().last
    }

    func oldestWeight() -> WeightEntry? {
        return loadWeights().first
    }

    func weightsForLastDays(_ days: Int) -> [WeightEntry] {
        let calendar = Calendar.current
        let now = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: now) else {
            return []
        }

        return loadWeights().filter { entry in
            entry.date >= startDate && entry.date <= now
        }
    }
}
