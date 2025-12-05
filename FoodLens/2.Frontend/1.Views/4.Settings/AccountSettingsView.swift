//
//  AccountSettingsView.swift
//  FoodLens
//
//  Created by Melanie & Muna on 11/7/25.
//

import SwiftUI
import FirebaseAuth

struct AccountSettingsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.scenePhase) private var scenePhase

    // Derive email directly from source of truth to avoid stale state
    private var displayedEmail: String {
        authVM.user?.email ?? authVM.userProfile?.email ?? ""
    }

    // Info banner on the Account screen
    @State private var topInfo: String?

    // Sheet toggles
    @State private var showChangeEmailSheet = false
    @State private var showChangePasswordSheet = false

    // Change Email state
    @State private var newEmail: String = ""
    @State private var reauthPasswordForEmail: String = ""
    @State private var isProcessingEmail = false
    @State private var emailLocalError: String?

    // Change Password state
    @State private var reauthPasswordForPassword: String = ""
    @State private var newPassword1: String = ""
    @State private var newPassword2: String = ""
    @State private var isProcessingPassword = false
    @State private var passwordLocalError: String?

    // “I Verified” button spinner
    @State private var isCheckingVerification = false

    // Inline reauth fallback for finishing email change (avoid full sign-in screen)
    @State private var showReauthInline = false
    @State private var reauthPasswordInline = ""
    @State private var isReauthingInline = false
    @State private var reauthInlineError: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fwhite.ignoresSafeArea()

                VStack(spacing: 24) {
                    TitleComponent(title: "Account")

                    // Current email card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.system(.title3, design: .rounded))
                            .foregroundStyle(.fblack)

                        Text(displayedEmail.isEmpty ? "—" : displayedEmail)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.secondary.opacity(0.2), lineWidth: 1)
                            )
                    }

                    // If a verification is pending, show a dedicated block
                    if let pending = authVM.pendingNewEmail {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Verification pending")
                                .font(.headline)
                                .foregroundStyle(.fgreen)

                            Text("We sent a verification link to \(pending). Tap the link and return here. If you already tapped it, press “I Verified” to refresh.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            HStack {
                                Spacer()
                                Button {
                                    Task { await confirmEmailChangeTapped(pending: pending) }
                                } label: {
                                    if isCheckingVerification {
                                        ProgressView()
                                            .tint(.fwhite)
                                            .frame(width: 20, height: 20)
                                    } else {
                                        Text("I Verified")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .disabled(isCheckingVerification || isReauthingInline)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background((isCheckingVerification || isReauthingInline) ? Color.fgray : Color.fgreen)
                                .foregroundStyle(.fwhite)
                                .cornerRadius(8)
                            }

                            // Inline reauth fallback to refresh credentials without a full sign-in screen
                            if showReauthInline {
                                VStack(alignment: .leading, spacing: 8) {
                                    SecureField("Password (to refresh session)", text: $reauthPasswordInline)
                                        .textContentType(.password)
                                        .disabled(isReauthingInline)
                                        .padding(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(.secondary.opacity(0.2), lineWidth: 1)
                                        )

                                    if let err = reauthInlineError, !err.isEmpty {
                                        Text(err)
                                            .font(.footnote)
                                            .foregroundColor(.red)
                                            .multilineTextAlignment(.leading)
                                    }

                                    HStack {
                                        Spacer()
                                        Button {
                                            Task { await reauthenticateAfterVerify() }
                                        } label: {
                                            if isReauthingInline {
                                                ProgressView()
                                                    .tint(.fwhite)
                                                    .frame(width: 20, height: 20)
                                            } else {
                                                Text("Fix & Refresh")
                                                    .fontWeight(.semibold)
                                            }
                                        }
                                        .disabled(reauthPasswordInline.isEmpty || isReauthingInline)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background((reauthPasswordInline.isEmpty || isReauthingInline) ? Color.fgray : Color.fgreen)
                                        .foregroundStyle(.fwhite)
                                        .cornerRadius(8)
                                    }
                                }
                                .transition(.opacity)
                            } else {
                                Button("Having trouble? Re-enter password") {
                                    withAnimation { showReauthInline = true }
                                }
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .padding(.top, 4)
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.fwhite)
                                .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
                        )
                    }

                    // Actions
                    VStack(spacing: 14) {
                        Button {
                            // Prepare defaults and open sheet
                            newEmail = ""                    // empty field as requested
                            reauthPasswordForEmail = ""
                            emailLocalError = nil
                            authVM.authError = nil      // clear any global banner before presenting sheet
                            topInfo = nil
                            showChangeEmailSheet = true
                        } label: {
                            Label("Change Email", systemImage: "envelope")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.fgreen)
                                .foregroundStyle(.fwhite)
                                .cornerRadius(10)
                        }

                        Button {
                            // Reset and open sheet
                            reauthPasswordForPassword = ""
                            newPassword1 = ""
                            newPassword2 = ""
                            passwordLocalError = nil
                            authVM.authError = nil
                            topInfo = nil
                            showChangePasswordSheet = true
                        } label: {
                            Label("Change Password", systemImage: "lock")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.fblue)
                                .foregroundStyle(.fwhite)
                                .cornerRadius(10)
                        }
                    }

                    // Info banner (e.g., “verification email sent” / “updated”)
                    if let info = topInfo, !showChangeEmailSheet, !showChangePasswordSheet {
                        Text(info)
                            .font(.footnote)
                            .foregroundStyle(.fgreen)
                            .multilineTextAlignment(.center)
                            .padding(.top, 6)
                    }

                    // Show global error only when no sheet is presented (avoid duplicate banner behind sheet)
                    if let error = authVM.authError,
                       !error.isEmpty,
                       !showChangeEmailSheet,
                       !showChangePasswordSheet {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.top, 6)
                    }

                    Spacer()
                }
                .padding(.horizontal, 35)
                .onChange(of: scenePhase) { newPhase in
                    // If the app becomes active, re-check whether the verification completed
                    if newPhase == .active {
                        Task { await authVM.completePendingEmailChangeIfVerified() }
                    }
                }
            }
        }
        // MARK: Change Email Sheet
        .sheet(isPresented: $showChangeEmailSheet) {
            ChangeEmailSheet(
                currentEmail: displayedEmail,
                newEmail: $newEmail,
                password: $reauthPasswordForEmail,
                isProcessing: $isProcessingEmail,
                localError: $emailLocalError,
                onCancel: {
                    isProcessingEmail = false
                    emailLocalError = nil
                    showChangeEmailSheet = false
                },
                onConfirm: {
                    Task { await reauthenticateAndSendVerificationForEmail() }
                }
            )
            .presentationDetents([.medium])
        }
        // MARK: Change Password Sheet
        .sheet(isPresented: $showChangePasswordSheet) {
            ChangePasswordSheet(
                currentEmail: displayedEmail,
                currentPassword: $reauthPasswordForPassword,
                newPassword: $newPassword1,
                confirmPassword: $newPassword2,
                isProcessing: $isProcessingPassword,
                localError: $passwordLocalError,
                onCancel: {
                    isProcessingPassword = false
                    passwordLocalError = nil
                    showChangePasswordSheet = false
                },
                onConfirm: {
                    Task { await reauthenticateAndChangePassword() }
                }
            )
            .presentationDetents([.medium])
        }
    }

    // MARK: - Actions

    // Verify-before-update: send link to NEW email after re-auth.
    private func reauthenticateAndSendVerificationForEmail() async {
        guard let user = Auth.auth().currentUser else {
            await MainActor.run { emailLocalError = "No authenticated user." }
            return
        }

        let trimmedNew = newEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        let changed = !trimmedNew.isEmpty && trimmedNew.caseInsensitiveCompare(displayedEmail) != .orderedSame

        guard changed else {
            await MainActor.run { emailLocalError = "Enter a different email." }
            return
        }

        await MainActor.run {
            isProcessingEmail = true
            emailLocalError = nil
        }

        do {
            // Re-auth with current credentials
            let cred = EmailAuthProvider.credential(withEmail: displayedEmail, password: reauthPasswordForEmail)
            try await user.reauthenticate(with: cred)

            // Send verification link (hosted flow)
            try await authVM.sendVerifyBeforeUpdateEmail(trimmedNew)

            await MainActor.run {
                isProcessingEmail = false
                showChangeEmailSheet = false
                // Keep reauthPasswordForEmail in memory so we can reuse it for silent reauth
                topInfo = "We sent a verification link to \(trimmedNew). Tap it, then press “I Verified”."
            }
        } catch {
            await MainActor.run {
                isProcessingEmail = false
                emailLocalError = (error as NSError).localizedDescription
            }
        }
    }

    // “I Verified” button handler
    private func confirmEmailChangeTapped(pending: String) async {
        await MainActor.run {
            isCheckingVerification = true
            topInfo = nil
        }

        // 1) Try to silently refresh credentials first (if we have a password in memory)
        var silentlyRefreshed = false
        if !reauthPasswordForEmail.isEmpty || !reauthPasswordInline.isEmpty {
            silentlyRefreshed = await silentRefreshCredentialsIfPossible()
        }

        // 2) Then try to complete the pending change
        await authVM.completePendingEmailChangeIfVerified()

        // 3) Reflect result
        await MainActor.run {
            isCheckingVerification = false

            let latest = displayedEmail
            if authVM.pendingNewEmail == nil,
               latest.caseInsensitiveCompare(pending) == .orderedSame {
                topInfo = "Email updated to \(latest)."
                // Collapse inline reauth UI if it was open
                showReauthInline = false
                reauthPasswordInline = ""
                reauthInlineError = nil
                // Clear stored password now that we are done
                reauthPasswordForEmail = ""
            } else {
                if !silentlyRefreshed && reauthPasswordForEmail.isEmpty {
                    topInfo = "Still waiting for verification. If you already tapped the link, wait a few seconds and try again, or re-enter your password below."
                    showReauthInline = true
                } else {
                    topInfo = "Still waiting for verification. If you already tapped the link, wait a few seconds and try again."
                }
            }
        }
    }

    // Try to refresh credentials without showing UI, using either the stored sheet password
    // or the inline one (if already entered). Attempts both old and pending emails.
    private func silentRefreshCredentialsIfPossible() async -> Bool {
        let password = !reauthPasswordForEmail.isEmpty ? reauthPasswordForEmail : reauthPasswordInline
        guard !password.isEmpty else { return false }

        let emails = candidateEmails()

        // If we still have a current user, try reauthenticate; if not, sign in.
        if let user = Auth.auth().currentUser {
            for email in emails {
                do {
                    let cred = EmailAuthProvider.credential(withEmail: email, password: password)
                    try await user.reauthenticate(with: cred)
                    return true
                } catch { /* try next */ }
            }
            return false
        } else {
            for email in emails {
                do {
                    try await Auth.auth().signIn(withEmail: email, password: password)
                    return true
                } catch { /* try next */ }
            }
            return false
        }
    }

    // Inline/silent reauthentication to refresh credentials (called by the "Fix & Refresh" button).
    private func reauthenticateAfterVerify() async {
        await MainActor.run {
            isReauthingInline = true
            reauthInlineError = nil
        }

        let ok = await silentRefreshCredentialsIfPossible()

        if ok {
            await authVM.completePendingEmailChangeIfVerified()
            await MainActor.run {
                isReauthingInline = false
                // Clear both password buffers now that we are done
                reauthPasswordInline = ""
                reauthPasswordForEmail = ""
                reauthInlineError = nil
                showReauthInline = false
            }
        } else {
            await MainActor.run {
                isReauthingInline = false
                reauthInlineError = "Reauthentication failed. Please check your password and try again."
                showReauthInline = true
            }
        }
    }

    private func candidateEmails() -> [String] {
        var list: [String] = []
        let old = displayedEmail
        let pending = authVM.pendingNewEmail ?? ""
        if !old.isEmpty { list.append(old) }
        if !pending.isEmpty && !list.contains(where: { $0.caseInsensitiveCompare(pending) == .orderedSame }) {
            list.append(pending)
        }
        return list
    }

    private func reauthenticateAndChangePassword() async {
        guard let user = Auth.auth().currentUser else {
            await MainActor.run { passwordLocalError = "No authenticated user." }
            return
        }

        let newPwd = newPassword1.trimmingCharacters(in: .whitespacesAndNewlines)
        let confirm = newPassword2.trimmingCharacters(in: .whitespacesAndNewlines)

        guard newPwd.count >= 6 else {
            await MainActor.run { passwordLocalError = "Password must be at least 6 characters." }
            return
        }
        guard newPwd == confirm else {
            await MainActor.run { passwordLocalError = "Passwords do not match." }
            return
        }

        await MainActor.run {
            isProcessingPassword = true
            passwordLocalError = nil
        }

        do {
            // Re-auth with current credentials
            let cred = EmailAuthProvider.credential(withEmail: displayedEmail, password: reauthPasswordForPassword)
            try await user.reauthenticate(with: cred)

            // Update password
            try await authVM.updatePassword(newPwd)

            await MainActor.run {
                isProcessingPassword = false
                showChangePasswordSheet = false
                reauthPasswordForPassword = ""
                newPassword1 = ""
                newPassword2 = ""
                topInfo = "Password updated."
            }
        } catch {
            await MainActor.run {
                isProcessingPassword = false
                passwordLocalError = (error as NSError).localizedDescription
            }
        }
    }
}

// MARK: - Sheets (same visuals; behavior handled above)

private struct ChangeEmailSheet: View {
    let currentEmail: String
    @Binding var newEmail: String
    @Binding var password: String
    @Binding var isProcessing: Bool
    @Binding var localError: String?

    var onCancel: () -> Void
    var onConfirm: () -> Void

    private var trimmedNew: String {
        newEmail.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var emailChanged: Bool {
        !trimmedNew.isEmpty && trimmedNew.caseInsensitiveCompare(currentEmail) != .orderedSame
    }

    private var canContinue: Bool {
        emailChanged && !password.isEmpty
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Change Email")
                .font(.headline)

            Text("Enter your new email and your current password to confirm.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 8) {
                Text("Current Email")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(currentEmail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.secondary.opacity(0.2), lineWidth: 1)
                    )
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("New Email")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextField("example@email.com", text: $newEmail)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .disabled(isProcessing)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.secondary.opacity(0.2), lineWidth: 1)
                    )
            }

            SecureField("Current Password", text: $password)
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
                .disabled(!canContinue || isProcessing)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background((!canContinue || isProcessing) ? Color.fgray : Color.fgreen)
                .foregroundStyle(.fwhite)
                .cornerRadius(8)
            }
            .padding(.top, 4)
        }
        .padding(20)
    }
}

private struct ChangePasswordSheet: View {
    let currentEmail: String
    @Binding var currentPassword: String
    @Binding var newPassword: String
    @Binding var confirmPassword: String
    @Binding var isProcessing: Bool
    @Binding var localError: String?

    var onCancel: () -> Void
    var onConfirm: () -> Void

    private var canContinue: Bool {
        !currentPassword.isEmpty &&
        newPassword.count >= 6 &&
        newPassword == confirmPassword
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Change Password")
                .font(.headline)

            Text("Re-enter your current password, then choose a new one.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 8) {
                Text("Account")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(currentEmail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.secondary.opacity(0.2), lineWidth: 1)
                    )
            }

            SecureField("Current Password", text: $currentPassword)
                .textContentType(.password)
                .disabled(isProcessing)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.secondary.opacity(0.2), lineWidth: 1)
                )

            SecureField("New Password (min 6 characters)", text: $newPassword)
                .textContentType(.newPassword)
                .disabled(isProcessing)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.secondary.opacity(0.2), lineWidth: 1)
                )

            SecureField("Confirm New Password", text: $confirmPassword)
                .textContentType(.newPassword)
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
                .disabled(!canContinue || isProcessing)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background((!canContinue || isProcessing) ? Color.fgray : Color.fgreen)
                .foregroundStyle(.fwhite)
                .cornerRadius(8)
            }
            .padding(.top, 4)
        }
        .padding(20)
    }
}
