//
//  DemographicsSettingsView.swift
//  FoodLens
//
//  Created by Melanie & Muna on 11/7/25.
//

import SwiftUI

struct DemographicsSettingsView: View {
    @EnvironmentObject var model: UserModel
    @EnvironmentObject var authVM: AuthViewModel

    // Always allow Save (it just syncs current values)
    private var hasChanges: Bool { true }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fwhite.ignoresSafeArea()

                VStack(spacing: 25) {

                    // Re-use onboarding demographics UI
                    DemographicsView()
                        .environmentObject(model)

                    Spacer()

                    Button {
                        // Save name in both places
                        authVM.updateProfileName(model.name)
                        // Save full UserModel under users/{uid}/userData
                        authVM.saveCurrentUserModel()
                    } label: {
                        Label("Save", systemImage: "checkmark.icloud")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color.fgreen)
                            .cornerRadius(10)
                            .foregroundStyle(.fwhite)
                    }
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, 35)
            }
        }
    }
}
