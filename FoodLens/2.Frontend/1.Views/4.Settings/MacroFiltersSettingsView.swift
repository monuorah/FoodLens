//
//  MacroFiltersSettingsView.swift
//  FoodLens
//
//  Created by Melanie Escobar on 11/7/25.
//

import SwiftUI

struct MacroFiltersSettingsView: View {
    // saved
    @State private var saved_selectedAchievement: String = "lose"
    
    @State private var saved_selectedWeightUnit: String = "imperial"
    @State private var saved_goalWeight = ""
    
    @State private var saved_cal = ""
    
    @State private var saved_carbsgrams = ""
    @State private var saved_proteingrams = ""
    @State private var saved_fatgrams = ""
    @State private var saved_selectedCarbs: Int = 30
    @State private var saved_selectedProtein: Int = 45
    @State private var saved_selectedFat: Int = 25
    
    // new
    @State private var selectedAchievement: String = "lose"
    
    @State private var selectedWeightUnit: String = "imperial"
    @State private var goalWeight = ""
    
    @State private var cal = ""
    
    @State private var carbsgrams = ""
    @State private var proteingrams = ""
    @State private var fatgrams = ""
    @State private var selectedCarbs: Int = 30
    @State private var selectedProtein: Int = 45
    @State private var selectedFat: Int = 25
    
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
                    TitleComponent(title: "Change Macros")
                    
                    ScrollView {
                        VStack {
                            // Fields
                            VStack(spacing: 25) {
                                // GOAL WEIGHT
                                HStack(spacing: 8) {
                                    Text("Goal weight")
                                        .foregroundStyle(.fblack)
                                        .font(.system(.title, design: .rounded))
                                    
                                    Spacer()

                                    HStack(spacing: 10) {
                                        // number field
                                        TextField(selectedWeightUnit == "imperial" ? "170" : "75", text: $goalWeight)
                                            .keyboardType(.numberPad)
                                            .frame(width: 50)
                                            .padding(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(.secondary.opacity(0.2), lineWidth: 1)
                                            )

                                        // unit picker
                                        Picker("Unit", selection: $selectedWeightUnit) {
                                            Text("lbs").tag("imperial")
                                            Text("kg").tag("metric")
                                        }
                                        .pickerStyle(.menu)
                                        .padding(2)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(.secondary.opacity(0.2), lineWidth: 1)
                                        )
                                        .tint(.fgreen)
                                    }
                                }
                                
                                // TARGET
                                VStack(alignment: .leading) {
                                    Text("Target")
                                        .foregroundStyle(.fblack)
                                        .font(.system(.title, design: .rounded))
                                    Text("What are you aiming to achieve?")
                                        .foregroundStyle(.forange)
                                        .font(.system(.subheadline, design: .rounded))
                                    
                                    Picker("Achievement", selection: $selectedAchievement) {
                                        Text("lose weight").tag("lose")
                                        Text("gain weight").tag("gain")
                                        Text("maintain weight").tag("maintain")
                                    }
                                    .pickerStyle(.menu)
                                    .frame(maxWidth: .infinity)
                                    .padding(2)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.secondary.opacity(0.2), lineWidth: 1)
                                    )
                                    .tint(.fgreen)
                                    
                                    
                                }
                            } // VSTACK
                            .padding(.horizontal, 10)
                            
                            Spacer()
                                
                            // WILL LOAD TO WHAT IT NEEDS
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.forange)
                                    .frame(height: 380)
                                
                                VStack(spacing: 20) {
                                    // DAILY CALORIE TARGET
                                    VStack(alignment: .leading) {
                                        Text("Daily Calorie Target")
                                            .foregroundStyle(.fwhite)
                                            .font(.system(.title, design: .rounded))
                                        
                                        HStack(spacing: 10) {
                                            Text("Recommended")
                                                .foregroundStyle(.fwhite)
                                            
                                            Spacer()
                                            
                                            TextField("2000", text: $cal)
                                                .keyboardType(.numberPad)
                                                .frame(width: 60)
                                                .padding(8)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(.fwhite, lineWidth: 1)
                                                )
                                            
                                            Text("cal")
                                                .foregroundStyle(.fwhite)
                                        }
                                    }
                                    .padding(.horizontal, 30)
                                    
                                    // DAILY MACRO TARGET
                                    VStack(alignment: .leading) {
                                        Text("Daily Macro Target")
                                            .foregroundStyle(.fwhite)
                                            .font(.system(.title, design: .rounded))
                                        
                                        Text("Macro nutrients must equal 100%")
                                            .foregroundStyle(.fblack)
                                            .font(.system(.subheadline, design: .rounded))
                                            .padding(.top, 3)
                                        
                                        Text("Recommended")
                                            .foregroundStyle(.fwhite)
                                            .padding(.bottom, 3)
                                        
                                        HStack(spacing: 24) {
                                            
                                            // carbs
                                            VStack {
                                                Text("Carbs")
                                                    .foregroundStyle(.fwhite)
                                                
                                                HStack {
                                                    TextField("143.0", text: $carbsgrams)
                                                        .keyboardType(.numberPad)
                                                    Text("g")
                                                        .foregroundStyle(.fwhite)
                                                }
                                                .frame(width: 60)
                                                .padding(8)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(.fwhite, lineWidth: 1)
                                                )
                                                
                                                Picker("Carbs", selection: $selectedCarbs) {
                                                    ForEach([20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70], id: \.self) { percent in
                                                        Text("\(percent)%").tag(percent)
                                                    }
                                                }
                                                .pickerStyle(.menu)
                                                .padding(2)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(.fwhite, lineWidth: 1)
                                                )
                                                .tint(.fwhite)
                                                
                                            }
                                            
                                            // protein
                                            VStack {
                                                Text("Protein")
                                                    .foregroundStyle(.fwhite)
                                                
                                                HStack {
                                                    TextField("214.0", text: $proteingrams)
                                                        .keyboardType(.numberPad)
                                                    Text("g")
                                                        .foregroundStyle(.fwhite)
                                                }
                                                .frame(width: 60)
                                                .padding(8)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(.fwhite, lineWidth: 1)
                                                )
                                                
                                                Picker("Protein", selection: $selectedProtein) {
                                                    ForEach([20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70], id: \.self) { percent in
                                                        Text("\(percent)%").tag(percent)
                                                    }
                                                }
                                                .pickerStyle(.menu)
                                                .padding(2)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(.fwhite, lineWidth: 1)
                                                )
                                                .tint(.fwhite)
                                                
                                            }
                                            
                                            // fat
                                            VStack {
                                                Text("Fat")
                                                    .foregroundStyle(.fwhite)
                                                
                                                HStack {
                                                    TextField("53.0", text: $fatgrams)
                                                        .keyboardType(.numberPad)
                                                    Text("g")
                                                        .foregroundStyle(.fwhite)
                                                }
                                                .frame(width: 60)
                                                .padding(8)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(.fwhite, lineWidth: 1)
                                                )
                                                
                                                Picker("Fat", selection: $selectedFat) {
                                                    ForEach([10, 15, 20, 25, 30, 35, 40, 45], id: \.self) { percent in
                                                        Text("\(percent)%").tag(percent)
                                                    }
                                                }
                                                .pickerStyle(.menu)
                                                .padding(2)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(.fwhite, lineWidth: 1)
                                                )
                                                .tint(.fwhite)
                                                
                                            }
                                        }
                                    }
                                }
                                
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            
                        } // VSTACK
                        
                    } // scroll view
                    
                    // Save button
                    Button {
                        // Perform save, then reset snapshots so button disables again
                        saved_selectedAchievement = selectedAchievement
                        
                        saved_selectedWeightUnit = selectedWeightUnit
                        saved_goalWeight = goalWeight
                        
                        saved_cal = cal
                        
                        saved_carbsgrams = carbsgrams
                        saved_proteingrams = proteingrams
                        saved_fatgrams = fatgrams
                        saved_selectedCarbs = selectedCarbs
                        saved_selectedProtein = selectedProtein
                        saved_selectedFat = selectedFat
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
                    
                } // VSTACk
                .padding(.horizontal, 35)

            } // ZSTACK
        } // NAV
    }
}
