// InsightsViewModel.swift
import Foundation
import Combine

@MainActor
final class InsightsViewModel: ObservableObject {
    @Published var advice: LLMAdvice?
    @Published var isLoading = false
    @Published var error: String?

    private let coach: LLMCoach

    init(coach: LLMCoach) {
        self.coach = coach
    }

    func refresh(window: StatsWindow, userModel: UserModel) async {
        isLoading = true
        error = nil
        advice = nil
        // Build local snapshot first
        let snap = InsightsEngine.snapshot(window: window, userModel: userModel)
        do {
            let a = try await coach.fetchAdvice(for: snap)
            advice = a
        } catch {
            self.error = error.localizedDescription
            // You could fallback to rule-based insights here if desired.
        }
        isLoading = false
    }
}
