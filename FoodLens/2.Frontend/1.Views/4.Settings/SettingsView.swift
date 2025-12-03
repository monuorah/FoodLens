//
//  SettingsView.swift
//  FoodLens
//
//  Created by Melanie & Muna on 10/29/25.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var authVM: AuthViewModel

    // Re-auth sheet state (for delete)
    @State private var showReauthSheet = false
    @State private var reauthPassword: String = ""
    @State private var isProcessingReauth = false
    @State private var reauthLocalError: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fwhite.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 20) {
                    // Title
                    TitleComponent(title: "Settings")
                        .padding(.bottom, 20)

                    // Items
                    VStack(spacing: 20) {
                        LinkComponent(
                            title: "Account",
                            icon: "person.fill",
                            destination: AnyView(AccountSettingsView())
                        )
                        LinkComponent(
                            title: "Demographics",
                            icon: "person.text.rectangle",
                            destination: AnyView(DemographicsSettingsView())
                        )
                        LinkComponent(
                            title: "Preferences",
                            icon: "slider.horizontal.3",
                            destination: AnyView(PreferencesSettingsView())
                        )
                        LinkComponent(
                            title: "Goals",
                            icon: "target",
                            destination: AnyView(UpdateGoalsSettingsView())
                        )
                    }

                    Spacer()

                    // BUTTONS
                    VStack(spacing: 20) {

                        // SIGN OUT
                        Button {
                            authVM.signOut()          // RootRouterView will see user == nil and show LaunchView
                        } label: {
                            Label("Sign Out",
                                  systemImage: "rectangle.portrait.and.arrow.right")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color.fgray)
                                .cornerRadius(10)
                                .foregroundStyle(.fblack)
                        }

                        // DELETE ACCOUNT (always ask for password)
                        Button(role: .destructive) {
                            // Always show the password confirmation sheet first
                            reauthPassword = ""
                            reauthLocalError = nil
                            showReauthSheet = true
                        } label: {
                            Label("Delete Account", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color.fred)
                                .cornerRadius(10)
                                .foregroundStyle(.fwhite)
                                .fontWeight(.semibold)
                        }

                        // Show any auth error visibly
                        if let error = authVM.authError, !error.isEmpty {
                            Text(error)
                                .font(.footnote)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .padding(35)
            }
        }
        // Re-authentication sheet for delete
        .sheet(isPresented: $showReauthSheet) {
            DeleteReauthSheet(
                email: authVM.user?.email ?? "",
                password: $reauthPassword,
                isProcessing: $isProcessingReauth,
                localError: $reauthLocalError,
                onCancel: {
                    // reset local state
                    reauthPassword = ""
                    reauthLocalError = nil
                    showReauthSheet = false
                },
                onConfirm: {
                    Task { await reauthenticateAndDelete() }
                }
            )
            .presentationDetents([.height(280)])
        }
    }

    // MARK: - Delete account helpers

    private func reauthenticateAndDelete() async {
        guard let user = Auth.auth().currentUser else {
            await MainActor.run {
                reauthLocalError = "No authenticated user."
            }
            return
        }
        let currentEmail = user.email ?? ""
        let uid = user.uid

        await MainActor.run {
            isProcessingReauth = true
            reauthLocalError = nil
            authVM.authError = nil
        }

        do {
            // Reauthenticate with current credentials
            let credential = EmailAuthProvider.credential(withEmail: currentEmail, password: reauthPassword)
            try await user.reauthenticate(with: credential)

            // Best-effort Firestore cleanup FIRST (while still authenticated)
            await deleteFirestoreUser(uid: uid)

            // Then delete the Firebase Auth user
            try await user.delete()

            await MainActor.run {
                // cleanup UI state
                reauthPassword = ""
                showReauthSheet = false
                isProcessingReauth = false
                // Clear local listeners/state and route to Launch
                authVM.signOut()
            }
        } catch {
            await MainActor.run {
                isProcessingReauth = false
                let msg = (error as NSError).localizedDescription
                reauthLocalError = msg
                authVM.authError = msg
            }
        }
    }

    // Best-effort Firestore cleanup for user's document
    private func deleteFirestoreUser(uid: String) async {
        let userService = UserService()
        await withCheckedContinuation { continuation in
            userService.deleteUser(uid: uid) { _ in
                continuation.resume()
            }
        }
    }
}

private struct DeleteReauthSheet: View {
    let email: String
    @Binding var password: String
    @Binding var isProcessing: Bool
    @Binding var localError: String?

    var onCancel: () -> Void
    var onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Confirm Your Password")
                .font(.headline)

            Text("For security, please re-enter your password to delete your account.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(email)
                    .font(.body)
                    .foregroundStyle(.fblack)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.secondary.opacity(0.2), lineWidth: 1)
                    )
            }

            SecureField("Password", text: $password)
                .textContentType(.password)
                .disabled(isProcessing)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.secondary.opacity(0.2), lineWidth: 1)
                )

            if let err = localError, !err.isEmpty {
                Text(err)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            HStack {
                Button("Cancel") { onCancel() }
                    .disabled(isProcessing)

                Spacer()

                Button {
                    onConfirm()
                } label: {
                    if isProcessing {
                        ProgressView()
                            .tint(.fwhite)
                            .frame(width: 20, height: 20)
                    } else {
                        Text("Continue")
                            .fontWeight(.semibold)
                    }
                }
                .disabled(password.isEmpty || isProcessing)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background((password.isEmpty || isProcessing) ? Color.fgray : Color.fred)
                .foregroundStyle(.fwhite)
                .cornerRadius(8)
            }
            .padding(.top, 4)
        }
        .padding(20)
    }
}
