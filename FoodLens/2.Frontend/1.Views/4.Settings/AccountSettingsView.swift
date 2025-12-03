//
//  AccountSettingsView.swift
//  FoodLens
//
//  Created by Melanie Escobar on 11/7/25.
//

import SwiftUI
import FirebaseAuth

struct AccountSettingsView: View {
    @EnvironmentObject var authVM: AuthViewModel

    // Snapshots
    @State private var email: String = ""

    // Editable fields
    @State private var newEmail: String = ""
    @State private var newPassword: String = ""

    // Re-auth sheet for saving changes
    @State private var showReauthSheet = false
    @State private var reauthPassword: String = ""
    @State private var isProcessingReauth = false
    @State private var reauthLocalError: String?

    private var hasChanges: Bool {
        let trimmedEmail = newEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = newPassword.trimmingCharacters(in: .whitespacesAndNewlines)

        let emailChanged = !trimmedEmail.isEmpty && trimmedEmail != email
        let passwordChanged = !trimmedPassword.isEmpty   // any non-empty means "change"

        return emailChanged || passwordChanged
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fwhite.ignoresSafeArea()

                VStack(spacing: 25) {
                    TitleComponent(title: "Account")

                    EmailPasswordComponent(
                        email: $newEmail,
                        password: $newPassword,
                        titleStyle: .title3
                    )

                    if let error = authVM.authError, !error.isEmpty {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }

                    Spacer()

                    Button {
                        // Always require password confirmation before saving changes
                        reauthPassword = ""
                        reauthLocalError = nil
                        showReauthSheet = true
                    } label: {
                        Label("Save", systemImage: hasChanges ? "checkmark.icloud" : "xmark.icloud")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(hasChanges ? Color.fgreen : Color.fgray)
                            .cornerRadius(10)
                            .foregroundStyle(hasChanges ? .fwhite : .fblack)
                    }
                    .disabled(!hasChanges)
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, 35)
                .onAppear {
                    let currentEmail = authVM.user?.email ?? ""
                    email = currentEmail
                    newEmail = currentEmail
                    newPassword = ""
                    authVM.authError = nil
                }
            }
        }
        .sheet(isPresented: $showReauthSheet) {
            ConfirmPasswordSheet(
                email: authVM.user?.email ?? "",
                password: $reauthPassword,
                isProcessing: $isProcessingReauth,
                localError: $reauthLocalError,
                onCancel: {
                    reauthPassword = ""
                    reauthLocalError = nil
                    showReauthSheet = false
                },
                onConfirm: {
                    Task { await reauthenticateAndSaveChanges() }
                }
            )
            .presentationDetents([.height(280)])
        }
    }

    // MARK: - Save helpers

    private func reauthenticateAndSaveChanges() async {
        guard let user = Auth.auth().currentUser else {
            await MainActor.run {
                reauthLocalError = "No authenticated user."
            }
            return
        }

        let currentEmail = user.email ?? ""
        let trimmedEmail = newEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = newPassword.trimmingCharacters(in: .whitespacesAndNewlines)

        let emailChanged = !trimmedEmail.isEmpty && trimmedEmail != email
        let passwordChanged = !trimmedPassword.isEmpty

        await MainActor.run {
            isProcessingReauth = true
            reauthLocalError = nil
            authVM.authError = nil
        }

        do {
            // Reauthenticate with CURRENT email and the password they just entered
            let credential = EmailAuthProvider.credential(withEmail: currentEmail, password: reauthPassword)
            try await user.reauthenticate(with: credential)

            // Apply pending changes
            if emailChanged {
                await authVM.updateEmail(trimmedEmail)
                // If updateEmail set an error, stop and show it
                if let err = authVM.authError, !err.isEmpty {
                    throw NSError(domain: "FoodLens.Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: err])
                }
            }

            if passwordChanged {
                await authVM.updatePassword(trimmedPassword)
                if let err = authVM.authError, !err.isEmpty {
                    throw NSError(domain: "FoodLens.Auth", code: -2, userInfo: [NSLocalizedDescriptionKey: err])
                }
            }

            await MainActor.run {
                // Update local state and close the sheet
                if emailChanged {
                    email = trimmedEmail
                    newEmail = trimmedEmail
                }
                if passwordChanged {
                    newPassword = ""
                }
                reauthPassword = ""
                isProcessingReauth = false
                showReauthSheet = false
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
}

private struct ConfirmPasswordSheet: View {
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

            Text("For security, please re-enter your password to save changes.")
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
                .background((password.isEmpty || isProcessing) ? Color.fgray : Color.fgreen)
                .foregroundStyle(.fwhite)
                .cornerRadius(8)
            }
            .padding(.top, 4)
        }
        .padding(20)
    }
}
