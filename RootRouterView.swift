// RootRouterView.swift
import SwiftUI
import FirebaseAuth

struct RootRouterView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        Group {
            if let user = authVM.user {
                SessionRootView(uid: user.uid)
            } else if authVM.isCompletingPendingEmailChange, let uid = authVM.lastKnownUID {
                // Stay in the session UI while finishing verification
                SessionRootView(uid: uid)
            } else {
                LaunchView()
            }
        }
        // Keep a stable identity while finishing verification to avoid a visual bounce
        .id(authVM.user?.uid ?? authVM.lastKnownUID ?? "loggedOut")
        // When app becomes active, check if a pending email change was verified
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                Task { await authVM.completePendingEmailChangeIfVerified() }
            }
        }
        // Also check on cold launch (first render)
        .task {
            await authVM.completePendingEmailChangeIfVerified()
        }
        // If you later enable in-app action code handling / dynamic links, this will refresh immediately
        .onOpenURL { _ in
            Task { await authVM.completePendingEmailChangeIfVerified() }
        }
    }
}

private struct SessionRootView: View {
    let uid: String
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var userModel = UserModel()
    
    var body: some View {
        Group {
            // While signed in but profile not yet loaded from Firestore, show a loading view with a way to sign out
            if authVM.userProfile == nil {
                ZStack {
                    Color.fwhite.ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView("Loading your profile…")
                            .tint(.fgreen)
                        Text("If this takes too long, you can sign out and return to Launch.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        Button {
                            authVM.signOut()
                        } label: {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.fgray)
                                .cornerRadius(10)
                                .foregroundStyle(.fblack)
                                .padding(.horizontal, 40)
                        }
                    }
                }
            } else if authVM.userProfile?.onboardingCompleted == true {
                TabsView()
            } else {
                OnboardingPagerView()
            }
        }
        .environmentObject(userModel)
        .onAppear {
            authVM.attachUserModel(userModel)
        }
        .onDisappear {
            authVM.detachUserModel()
        }
    }
}

