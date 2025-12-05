//
//  MacroFiltersSettingsView.swift
//  FoodLens
//
//  Created by Melanie & Muna on 11/7/25.
//

import SwiftUI

struct UpdateGoalsSettingsView: View {
    @EnvironmentObject var model: UserModel
    @EnvironmentObject var authVM: AuthViewModel

    // Same constraints as onboarding — only let them save if all 3 sections are valid
    private var canSave: Bool {
        model.isWeightGoalsValid && model.isCaloriesValid && model.isMacrosValid
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fwhite.ignoresSafeArea()

                VStack(spacing: 20) {
                    TitleComponent(title: "Update Goals")

                    ScrollView {
                        VStack(spacing: 30) {

                            // 1) Weight goals (full onboarding view)
                            SetGoalWeightView()
                                .environmentObject(model)

                            // 2) Only show calories/macros once the weight goals are valid
                            if model.isWeightGoalsValid {
                                Divider()
                                    .padding(.horizontal, 10)

                                SetGoalCaloriesView()
                                    .environmentObject(model)

                                Divider()
                                    .padding(.horizontal, 10)

                                SetGoalMacrosView()
                                    .environmentObject(model)
                            } else {
                                Text("Finish setting your weight goals above to see updated calories and macros.")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                            }
                        }
                        .padding(.vertical, 10)
                    }

                    // SAVE BUTTON
                    Button {
                        // Persist updated goals to Firestore
                        authVM.saveCurrentUserModel()
                    } label: {
                        Label("Save", systemImage: canSave ? "checkmark.icloud" : "xmark.icloud")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(canSave ? Color.fgreen : Color.fgray)
                            .cornerRadius(10)
                            .foregroundStyle(canSave ? .fwhite : .fblack)
                    }
                    .disabled(!canSave)
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
