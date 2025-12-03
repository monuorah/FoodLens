//
//  PreferencesSettingsView.swift
//  FoodLens
//
//  Created by Melanie Escobar on 11/7/25.
//

import SwiftUI

struct PreferencesSettingsView: View {
    @EnvironmentObject var model: UserModel
    @EnvironmentObject var authVM: AuthViewModel

    private var hasChanges: Bool { true } // Save just syncs current model

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fwhite.ignoresSafeArea()

                VStack(spacing: 25) {
                    TitleComponent(title: "Preferences")

                    VStack(spacing: 25) {
                        // Units
                        HStack(spacing: 40) {
                            // Weight
                            Picker("weightUnit", selection: $model.selectedWeightUnit) {
                                Text("lbs").tag(UnitSystem.imperial)
                                Text("kg").tag(UnitSystem.metric)
                            }
                            .pickerStyle(.menu)

                            // Height
                            Picker("heightUnit", selection: $model.selectedHeightUnit) {
                                Text("ft/in").tag(UnitSystem.imperial)
                                Text("cm").tag(UnitSystem.metric)
                            }
                            .pickerStyle(.menu)

                            // Energy
                            Picker("foodUnit", selection: $model.selectedEnergyUnit) {
                                Text("kcal").tag(EnergyUnit.kcal)
                                Text("kJ").tag(EnergyUnit.kJ)
                            }
                            .pickerStyle(.menu)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.secondary.opacity(0.2), lineWidth: 1)
                        )
                        .tint(.fblack)

                        // Access toggles
                        HStack {
                            Text("Camera")
                                .foregroundStyle(.fblack)
                                .font(.system(.title3, design: .rounded))

                            Spacer()

                            Toggle("", isOn: $model.cameraEnabled)
                                .labelsHidden()
                        }

                        HStack {
                            Text("HealthKit App")
                                .foregroundStyle(.fblack)
                                .font(.system(.title3, design: .rounded))

                            Spacer()

                            Toggle("", isOn: $model.healthEnabled)
                                .labelsHidden()
                        }
                    }

                    Spacer()

                    Button {
                        authVM.saveCurrentUserModel()
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
            }
        }
    }
}
