//
//  PreferencesSettingsView.swift
//  FoodLens
//
//  Created by Melanie Escobar on 11/7/25.
//

import SwiftUI

struct PreferencesSettingsView: View {
    // saved
    @State private var saved_selectedSettingsWeightUnit: String = "lbs"
    @State private var saved_selectedSettingsHeightUnit: String = "ft"
    @State private var saved_selectedSettingsFoodUnit: String = "cal"
    
    
    @State private var saved_isCameraEnabled = false
    @State private var saved_isHealthKitAppEnabled = false
    
    // new
    @State private var selectedSettingsWeightUnit: String = "lbs"
    @State private var selectedSettingsHeightUnit: String = "ft"
    @State private var selectedSettingsFoodUnit: String = "cal"
    
    
    @State private var isCameraEnabled = false
    @State private var isHealthKitAppEnabled = false
    
    // Derived flags
    private var hasChanges: Bool {
        return true
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.fwhite.ignoresSafeArea()
                
                VStack(spacing: 25) {
                    // Title
                    TitleComponent(title: "Preferences")
                    
                    // Fields
                    VStack(spacing: 25) {
                        // metrics
                        HStack(spacing: 40) {
                            Picker("weightUnit", selection: $selectedSettingsWeightUnit) {
                                Text("lbs").tag("lbs")
                                Text("kg").tag("kg")
                            }
                            .pickerStyle(.menu)
                            
                            Picker("heightUnit", selection: $selectedSettingsHeightUnit) {
                                Text("ft/in").tag("ft")
                                Text("cm").tag("cm")
                            }
                            .pickerStyle(.menu)
                            
                            Picker("foodUnit", selection: $selectedSettingsFoodUnit) {
                                Text("cal").tag("cal")
                                Text("J").tag("joule")
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
                        
                        // grant access
                        HStack {
                            Text("Camera")
                                .foregroundStyle(.fblack)
                                .font(.system(.title3, design: .rounded))
                            
                            Spacer()
                            
                            Toggle("", isOn: $isCameraEnabled)
                                .labelsHidden()
                        }
                        
                        HStack {
                            Text("HealthKit App")
                                .foregroundStyle(.fblack)
                                .font(.system(.title3, design: .rounded))
                            
                            Spacer()
                            
                            Toggle("", isOn: $isHealthKitAppEnabled)
                                .labelsHidden()
                        }
                    } // VSTACK
                    
                    Spacer()
                    
                    Button {
                        // Perform save, then reset snapshots so button disables again
                        saved_selectedSettingsWeightUnit = selectedSettingsWeightUnit
                        saved_selectedSettingsHeightUnit = selectedSettingsHeightUnit
                        saved_selectedSettingsFoodUnit = selectedSettingsFoodUnit
                        
                        saved_isCameraEnabled = isCameraEnabled
                        saved_isHealthKitAppEnabled = isHealthKitAppEnabled
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
                        
                    
                } // VSTACK
                .padding(.horizontal, 35)
            } // ZSTACK
        } // NAV
    }
}
