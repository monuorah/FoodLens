//
//  AuthViewModel.swift
//  FoodLens
//
//  Created by Melanie Escobar on 12/1/25.
//


import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User?                // Firebase user
    @Published var userProfile: UserProfile?  // profile
    @Published var authError: String?

    private let authService = AuthService()
    private let userService = UserService()
    
    // Per-session wiring
    private weak var attachedModel: UserModel?
    private var profileListener: ListenerRegistration?
    private var modelListener: ListenerRegistration?
    
    init() {
        _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            Task { @MainActor in
                // Update user reference
                self.user = user
                
                // Tear down previous listeners whenever the auth state changes
                self.removeListeners()
                
                guard let uid = user?.uid else {
                    self.userProfile = nil
                    return
                }
                
                // Self-heal: ensure a minimal user doc exists with required fields
                let email = user?.email ?? ""
                self.userService.getUserOnce(uid: uid) { existing in
                    // If missing or missing "email", upsert minimal doc
                    if existing?["email"] as? String == nil {
                        self.userService.upsertMinimalUser(uid: uid, email: email) { error in
                            if let error {
                                print("Failed to upsert minimal user: \(error.localizedDescription)")
                            }
                            // Regardless of error, attach listeners; rules may prevent write but read could still work
                            self.attachListenersForAuthenticatedUser(uid: uid)
                        }
                    } else {
                        // Doc looks fine -> attach listeners
                        self.attachListenersForAuthenticatedUser(uid: uid)
                    }
                }
            }
        }
    }
    
    private func attachListenersForAuthenticatedUser(uid: String) {
        // Profile listener (independent of model)
        self.profileListener = self.userService.listenToUser(uid: uid) { profile in
            Task { @MainActor in
                self.userProfile = profile
            }
        }
        
        // If a model is already attached (SessionRootView), wire it up
        if let model = self.attachedModel {
            self.modelListener = self.userService.listenToUserModel(uid: uid, model: model)
        }
    }
    
    // Attach the per-session UserModel so we can stream Firestore userData into it.
    func attachUserModel(_ model: UserModel) {
        attachedModel = model
        
        // If already authenticated, start the model listener now
        if let uid = user?.uid {
            modelListener?.remove()
            modelListener = userService.listenToUserModel(uid: uid, model: model)
        }
    }
    
    // Detach the per-session model and remove its listener
    func detachUserModel() {
        attachedModel = nil
        modelListener?.remove()
        modelListener = nil
    }
    
    private func removeListeners() {
        profileListener?.remove(); profileListener = nil
        modelListener?.remove();   modelListener   = nil
    }
    
    func saveCurrentUserModel() {
        guard let uid = user?.uid, let model = attachedModel else { return }
        userService.saveUserModel(uid: uid, model: model) { error in
            if let error {
                print("Failed to save user model: \(error.localizedDescription)")
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
        authError = nil
        
        // Proactively remove listeners and clear profile
        removeListeners()
        userProfile = nil
        
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
        if let profile = userProfile {
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
    
    // Update email in Firebase Auth + Firestore + local profile
    func updateEmail(_ newEmail: String) async {
        guard let user = Auth.auth().currentUser else { return }
        authError = nil

        do {
            try await user.updateEmail(to: newEmail)

            userService.updateEmail(uid: user.uid, email: newEmail) { error in
                if let error = error {
                    Task { @MainActor in
                        self.authError = error.localizedDescription
                    }
                } else {
                    Task { @MainActor in
                        if let profile = self.userProfile {
                            self.userProfile = UserProfile(
                                id: profile.id,
                                email: newEmail,
                                name: profile.name,
                                onboardingCompleted: profile.onboardingCompleted,
                                onboardingStep: profile.onboardingStep
                            )
                        }
                    }
                }
            }
        } catch {
            authError = error.localizedDescription
        }
    }
    
    // Update password in Firebase Auth
    func updatePassword(_ newPassword: String) async {
        guard let user = Auth.auth().currentUser else { return }
        authError = nil

        do {
            try await user.updatePassword(to: newPassword)
        } catch {
            authError = error.localizedDescription
        }
    }
    
    // Update display name in Firestore + local UserProfile
    func updateProfileName(_ name: String) {
        guard let uid = user?.uid else { return }

        userService.updateName(uid: uid, name: name) { error in
            if let error = error {
                Task { @MainActor in
                    self.authError = error.localizedDescription
                }
            } else {
                Task { @MainActor in
                    if let profile = self.userProfile {
                        self.userProfile = UserProfile(
                            id: profile.id,
                            email: profile.email,
                            name: name,
                            onboardingCompleted: profile.onboardingCompleted,
                            onboardingStep: profile.onboardingStep
                        )
                    }
                }
            }
        }
    }
}

