// RootRouterView.swift
import SwiftUI
import FirebaseAuth

struct RootRouterView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        Group {
            if let user = authVM.user {
                SessionRootView(uid: user.uid)
            } else {
                LaunchView()
            }
        }
        // Rebuild the tree when the uid changes to ensure a fresh session view hierarchy
        .id(authVM.user?.uid ?? "loggedOut")
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
