//
//  AuthViewModel.swift
//  FoodLens
//
//  Created by Melanie & Muna on 12/1/25.
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

    // If the user chose a new email and we sent a verification link,
    // keep it here (and in UserDefaults) until it is verified.
    @Published var pendingNewEmail: String?

    // While we are finishing a pending email change, we may ignore transient nil user events.
    @Published var isCompletingPendingEmailChange: Bool = false

    // For UI fallback while finishing a sensitive op if user is momentarily nil
    private(set) var lastKnownUID: String?

    private let authService = AuthService()
    private let userService = UserService()

    private let pendingEmailKey = "AuthVM.pendingNewEmail"
    private let pendingEmailUIDKey = "AuthVM.pendingNewEmailUID"
    private var pendingEmailUID: String?
    
    // Per-session wiring
    private weak var attachedModel: UserModel?
    private var profileListener: ListenerRegistration?
    private var modelListener: ListenerRegistration?
    
    init() {
        // Load any pending email (from a prior run)
        self.pendingNewEmail = UserDefaults.standard.string(forKey: pendingEmailKey)
        self.pendingEmailUID = UserDefaults.standard.string(forKey: pendingEmailUIDKey)

        _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            Task { @MainActor in
                // If Firebase briefly reports nil during a reload/verification completion,
                // don't tear down the session UI.
                if user == nil, self.isCompletingPendingEmailChange {
                    // Ignore this transient callback.
                    return
                }

                // Update user reference
                self.user = user

                // Tear down previous listeners whenever the auth state changes
                self.removeListeners()
                
                guard let uid = user?.uid else {
                    self.userProfile = nil
                    return
                }

                // Scope any pending email intent to the signed-in user.
                // If we have a stale pending value from a different account (or legacy value with no UID),
                // clear it so the UI doesn't show "Verification pending" incorrectly.
                if let savedUID = self.pendingEmailUID {
                    if savedUID != uid {
                        self.clearPendingEmailTracking()
                    }
                } else if self.pendingNewEmail != nil {
                    // Legacy pending (no associated UID) — safest is to clear to avoid false positives.
                    self.clearPendingEmailTracking()
                }

                // Remember last known uid for UI fallback
                self.lastKnownUID = uid
                
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
        // Profile listener (independent of model). Ignore nil updates so we don't bounce to loader.
        self.profileListener = self.userService.listenToUser(uid: uid) { [weak self] profile in
            guard let self = self else { return }
            Task { @MainActor in
                if let profile = profile {
                    self.userProfile = profile
                } else {
                    // Ignore nil profile updates; keep showing last known profile instead of loader.
                    // This avoids a brief "Loading your profile…" flash while Firestore updates.
                }
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
            // FIX: match AuthService signature
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

        // Clear any pending email intent
        clearPendingEmailTracking()
        
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
    
    // MARK: - Account updates
    
    // Immediate update (rare: only if you want to change email without verification)
    func updateEmail(_ newEmail: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "FoodLens.Auth", code: -10, userInfo: [NSLocalizedDescriptionKey: "No authenticated user."])
        }
        authError = nil

        do {
            try await user.updateEmail(to: newEmail)
        } catch {
            authError = error.localizedDescription
            throw error
        }

        // Await Firestore write so the sheet doesn't close before it completes
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            self.userService.updateEmail(uid: user.uid, email: newEmail) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }

        // Update local profile copy
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

    // Easiest verify-before-update flow: send verification link to NEW email.
    // This does NOT change the email immediately.
    func sendVerifyBeforeUpdateEmail(_ newEmail: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "FoodLens.Auth", code: -20, userInfo: [NSLocalizedDescriptionKey: "No authenticated user."])
        }
        authError = nil

        // Hosted flow: no deep links to handle, pass nil settings.
        do {
            try await user.sendEmailVerification(beforeUpdatingEmail: newEmail, actionCodeSettings: nil)
        } catch {
            authError = error.localizedDescription
            throw error
        }

        // Remember the intent so we can finish after the user clicks the link.
        pendingNewEmail = newEmail
        pendingEmailUID = user.uid
        UserDefaults.standard.set(newEmail, forKey: pendingEmailKey)
        UserDefaults.standard.set(user.uid, forKey: pendingEmailUIDKey)
    }
    
    // Call this when app becomes active OR when user taps “I Verified”.
    func completePendingEmailChangeIfVerified() async {
        guard let pending = pendingNewEmail else { return }

        await MainActor.run { isCompletingPendingEmailChange = true }
        defer { Task { @MainActor in self.isCompletingPendingEmailChange = false } }

        guard let user = Auth.auth().currentUser else { return }
        do {
            try await user.reload()
            let current = user.email ?? ""
            // if the backend switched the email, finish Firestore + local updates
            if current.caseInsensitiveCompare(pending) == .orderedSame {
                // Update Firestore
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                    self.userService.updateEmail(uid: user.uid, email: current) { error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: ())
                        }
                    }
                }

                // Update local profile copy
                if let profile = self.userProfile {
                    self.userProfile = UserProfile(
                        id: profile.id,
                        email: current,
                        name: profile.name,
                        onboardingCompleted: profile.onboardingCompleted,
                        onboardingStep: profile.onboardingStep
                    )
                }

                // Clear pending flag (and associated UID)
                clearPendingEmailTracking()

                // Update lastKnownUID (should be same uid)
                self.lastKnownUID = user.uid

                // IMPORTANT: publish updated user so views observing authVM.user refresh their email display
                self.user = user
            }
        } catch {
            // Non-fatal; you can log if needed.
            print("completePendingEmailChangeIfVerified: \(error.localizedDescription)")
        }
    }
    
    // Update password in Firebase Auth
    func updatePassword(_ newPassword: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "FoodLens.Auth", code: -11, userInfo: [NSLocalizedDescriptionKey: "No authenticated user."])
        }
        authError = nil

        do {
            try await user.updatePassword(to: newPassword)
        } catch {
            authError = error.localizedDescription
            throw error
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

    // MARK: - Helpers

    private func clearPendingEmailTracking() {
        pendingNewEmail = nil
        pendingEmailUID = nil
        UserDefaults.standard.removeObject(forKey: pendingEmailKey)
        UserDefaults.standard.removeObject(forKey: pendingEmailUIDKey)
    }
}

