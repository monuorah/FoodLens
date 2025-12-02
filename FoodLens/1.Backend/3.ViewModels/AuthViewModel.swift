//
//  AuthViewModel.swift
//  FoodLens
//
//  Created by Melanie Escobar on 12/1/25.
//


import SwiftUI
import Combine
import FirebaseAuth

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User?                // Firebase user
    @Published var userProfile: UserProfile?  // profile
    @Published var authError: String?

    private let authService = AuthService()
    private let userService = UserService()
    
    init() {
        _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            self.user = user
            
            if let uid = user?.uid {
                self.userService.listenToUser(uid: uid) { profile in
                    Task { @MainActor in
                        self.userProfile = profile
                    }
                }
            } else {
                self.userProfile = nil
            }
        }
    }

    func signIn(email: String, password: String) async {
        authError = nil
        do {
            try await authService.signIn(email: email, password: password)
        } catch {
            authError = error.localizedDescription
        }
    }

    func signUp(email: String, password: String) async {
        authError = nil
        do {
            let uid = try await authService.signUp(email: email, password: password)
            
            // new user doc with onboarding defaults
            let profile = UserProfile(
                id: uid,
                email: email,
                name: nil,
                onboardingCompleted: false,
                onboardingStep: 0
            )
            try userService.createUserDocument(profile)
        } catch {
            authError = error.localizedDescription
        }
    }

    func signOut() {
        do {
            try authService.signOut()
        } catch {
            authError = error.localizedDescription
        }
    }
    
    // MARK: - Onboarding helpers
    
    func setOnboardingStep(_ step: Int) {
        guard let uid = user?.uid else { return }
        userService.updateOnboardingStep(uid: uid, step: step)
        
        // Keep local copy in sync so UI updates instantly
        if var profile = userProfile {
            userProfile = UserProfile(
                id: profile.id,
                email: profile.email,
                name: profile.name,
                onboardingCompleted: profile.onboardingCompleted,
                onboardingStep: step
            )
        }
    }
    
    func completeOnboarding() {
        guard let uid = user?.uid else { return }
        userService.markOnboardingCompleted(uid: uid)
        
        if let profile = userProfile {
            userProfile = UserProfile(
                id: profile.id,
                email: profile.email,
                name: profile.name,
                onboardingCompleted: true,
                onboardingStep: profile.onboardingStep
            )
        }
    }
}
