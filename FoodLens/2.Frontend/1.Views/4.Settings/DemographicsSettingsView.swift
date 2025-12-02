//
//  DemographicsSettingsView.swift
//  FoodLens
//
//  Created by Melanie Escobar on 11/7/25.
//

import SwiftUI

struct DemographicsSettingsView: View {
    // saved
    @State private var saved_selectedHeightUnit: String = "imperial"
    @State private var saved_selectedFeet: Int = 5
    @State private var saved_selectedInches: Int = 9
    @State private var saved_selectedCm: Int = 170
    @State private var saved_selectedWeightUnit: String = "imperial"
    @State private var saved_currentWeight = ""
    
    @State private var saved_birthDate: Date = Date()
    
    @State private var saved_selectedSex: String = "Male"
    
    // new
    @State private var selectedHeightUnit: String = "imperial"
    @State private var selectedFeet: Int = 5
    @State private var selectedInches: Int = 9
    @State private var selectedCm: Int = 170
    @State private var selectedWeightUnit: String = "imperial"
    @State private var currentWeight = ""
    
    @State private var birthDate: Date = Date()
    
    @State private var selectedSex: String = "Male"
    
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
                    TitleComponent(title: "Demographics")
                    
                    // Fields
                    VStack(spacing: 25) {
                        HStack() {
                            Text("Height")
                                .foregroundStyle(.fblack)
                                .font(.system(.title3, design: .rounded))
                            
                            HStack { // so pickers are equal size
                                // Unit toggle FIXME: preferences chooses this
                                Picker("Unit", selection: $selectedHeightUnit) {
                                    Text("ft/in").tag("imperial")
                                    Text("cm").tag("metric")
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 100)
                                
                                Spacer()
                                
                                if selectedHeightUnit == "imperial" {
                                    HStack {
                                        Picker("Feet", selection: $selectedFeet) {
                                            ForEach(3..<8) { feet in
                                                Text("\(feet) ft").tag(feet)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                        .padding(2)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(.secondary.opacity(0.2), lineWidth: 1)
                                        )
                                        
                                        
                                        Picker("Inches", selection: $selectedInches) {
                                            ForEach(0..<12) { inch in
                                                Text("\(inch) in").tag(inch)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                        .padding(2)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(.secondary.opacity(0.2), lineWidth: 1)
                                        )
                                    }
                                } else {
                                    HStack {
                                        Picker("Centimeters", selection: $selectedCm) {
                                            ForEach(100..<250) { cm in
                                                Text("\(cm) cm").tag(cm)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                        .padding(2)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(.secondary.opacity(0.2), lineWidth: 1)
                                        )
                                    }
                                }
                            }

                        }
                        .tint(.fblack)
                        
                        // BIRTHDATE
                        HStack {
                            Text("Birth date")
                                .foregroundStyle(.fblack)
                                .font(.system(.title3, design: .rounded))

                            Spacer()

                            // we did this bc there was a gray pill background that we did not want
                            ZStack {
                                // Date
                                HStack {
                                    Text(birthDate.formatted(date: .abbreviated, time: .omitted))
                                        .foregroundStyle(.fblack)
                                    Image(systemName: "chevron.up.chevron.down")
                                        .foregroundStyle(.fblack)
                                }
                                .padding(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.secondary.opacity(0.2), lineWidth: 1)
                                )

                                // Invisible compact DatePicker that handles interaction
                                DatePicker("", selection: $birthDate, in: ...Date(), displayedComponents: .date)
                                    .labelsHidden()
                                    .opacity(0.02)                  // nearly invisible but still tappable
                                    .contentShape(Rectangle())      // ensures taps anywhere in the ZStack trigger it
                            }
                            
                        }
                        
                        
                        // SEX
                        HStack {
                            Text("Sex")
                                .foregroundStyle(.fblack)
                                .font(.system(.title3, design: .rounded))
                            
                            Spacer()

                            Picker("Sex", selection: $selectedSex) {
                                Text("Male").tag("Male")
                                Text("Female").tag("Female")
                                Text("Other").tag("Other")
                            }
                            .pickerStyle(.menu)
                            .padding(2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.secondary.opacity(0.2), lineWidth: 1)
                            )
                            .tint(.fblack)
                        }

                    } // VSTACK
                    .padding(.horizontal, 10)
                    
                    Spacer()
                    
                    Button {
                        // Perform save, then reset snapshots so button disables again
                        saved_selectedHeightUnit = selectedHeightUnit
                        saved_selectedFeet = selectedFeet
                        saved_selectedInches = selectedInches
                        saved_selectedCm = selectedCm
                        saved_selectedWeightUnit = selectedWeightUnit
                        saved_currentWeight = currentWeight
                        
                        saved_birthDate = birthDate
                        
                        saved_selectedSex = selectedSex
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
