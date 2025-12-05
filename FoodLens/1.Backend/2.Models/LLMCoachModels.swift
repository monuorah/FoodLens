//
//  LLMCoachModels.swift
//  FoodLens
//

import Foundation
import FirebaseAuth
import FirebaseAI

// Advice returned by the coach (used by TrendsView)
struct LLMAdvice: Codable {
    var summary: String?
    var insights: [Insight]     // Insight is defined in InsightsEngine.swift
    var actions: [String]
}

// Protocol the coach service conforms to
protocol LLMCoach {
    func fetchAdvice(for snapshot: StatsSnapshot) async throws -> LLMAdvice
}

enum LLMCoachError: LocalizedError {
    case invalidResponse
    case decodingFailed
    case transport(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Invalid response from model."
        case .decodingFailed:  return "Failed to decode advice JSON."
        case .transport(let e): return e.localizedDescription
        }
    }
}

struct LLMCoachService: LLMCoach {
    // The template ID from the Firebase console (Prompt templates tab).
    private let templateID = "nutritioncoach"

    func fetchAdvice(for snapshot: StatsSnapshot) async throws -> LLMAdvice {
        // 1) Get the Firebase AI (Gemini Dev API) client
        let ai = FirebaseAI.firebaseAI(backend: .googleAI())
        let model = ai.templateGenerativeModel()

        // 2) Build variables for the template
        let vars: [String: Any] = [
            "snapshot": snapshotPayload(from: snapshot)
        ]

        // 3) Call the template
        let response: GenerateContentResponse
        do {
            response = try await model.generateContent(
                templateID: templateID,
                inputs: vars
            )
        } catch {
            throw LLMCoachError.transport(error)
        }

        // 4) Extract the model text
        guard var text = response.text, !text.isEmpty else {
            throw LLMCoachError.invalidResponse
        }

        // Strip ```json ... ``` or ``` ... ``` fences if the model added them
        text = stripJSONCodeFences(from: text)

        // 5) Decode JSON into LLMAdvice
        let data = Data(text.utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        do {
            let advice = try decoder.decode(LLMAdvice.self, from: data)
            return advice
        } catch {
            print("LLM JSON decode failed. Cleaned text:\n\(text)")
            throw LLMCoachError.decodingFailed
        }
    }

    // Map StatsSnapshot -> payload your template expects
    private func snapshotPayload(from s: StatsSnapshot) -> [String: Any] {
        var payload: [String: Any] = [
            "calories": s.avgCalories,
            "protein":  s.avgProteinG,
            "carbs":    s.avgCarbsG,
            "fat":      s.avgFatG,
            "fiber":    s.avgFiberG
        ]
        return payload
    }

    private func stripJSONCodeFences(from text: String) -> String {
        var t = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // Remove leading ```json or ``` fence
        if t.hasPrefix("```json") {
            t = String(t.dropFirst("```json".count))
        } else if t.hasPrefix("```") {
            t = String(t.dropFirst("```".count))
        }

        // Remove trailing ``` if present
        if t.hasSuffix("```") {
            t = String(t.dropLast("```".count))
        }

        return t.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
