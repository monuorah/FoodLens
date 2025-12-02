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

    @State private var showingDeleteConfirmation = false

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
                            title: "Macro Filters",
                            icon: "line.horizontal.3.decrease.circle",
                            destination: AnyView(MacroFiltersSettingsView())
                        )
                    }

                    Spacer()

                    // BUTTONS
                    VStack(spacing: 20) {

                        // SIGN OUT
                        Button {
                            authVM.signOut()          // <- this is enough
                            // ContentView will see user == nil and show LaunchView
                        } label: {
                            Label("Sign Out",
                                  systemImage: "rectangle.portrait.and.arrow.right")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color.fgray)
                                .cornerRadius(10)
                                .foregroundStyle(.fblack)
                        }

                        // DELETE ACCOUNT
                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            Label("Delete Account", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color.fred)
                                .cornerRadius(10)
                                .foregroundStyle(.fwhite)
                                .fontWeight(.semibold)
                        }
                    }
                    .confirmationDialog(
                        "Delete Account?",
                        isPresented: $showingDeleteConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button("Delete Account", role: .destructive) {
                            Task { await deleteAccount() }
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("This action cannot be undone.")
                    }
                }
                .padding(35)
            }
        }
    }

    // MARK: - Delete account helper

    private func deleteAccount() async {
        guard let user = Auth.auth().currentUser else { return }

        do {
            try await user.delete()     // deletes from Firebase Auth
            authVM.signOut()            // clear local state -> back to LaunchView
        } catch {
            print("Delete account error:", error.localizedDescription)
            authVM.authError = error.localizedDescription
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
}
