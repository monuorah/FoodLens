//
//  DemographicsView.swift
//  FoodLens
//
//  Created by Melanie Escobar on 11/7/25.
//

import SwiftUI

struct DemographicsView: View {
    @EnvironmentObject var model: UserModel

    var body: some View {
        ZStack {
            Color.fwhite.ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Title
                TitleComponent(title: "About You")
                
                // Fields
                
                // NAME
                NameComponent(name: $model.name, titleStyle: .title2)
                // add error thing here
                
                // HEIGHT
                VStack(alignment: .leading) {
                    HStack {
                        Text("Height")
                            .foregroundStyle(.fblack)
                            .font(.system(.title2, design: .rounded))
                        
                        Spacer()
                        
                        // Unit toggle
                        Picker("heightUnit", selection: $model.selectedHeightUnit) {
                            Text("ft/in").tag(UnitSystem.imperial)
                            Text("cm").tag(UnitSystem.metric)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 120)
                    }
                        
                    if model.selectedHeightUnit == .imperial {
                        HStack {
                            Picker("Feet", selection: $model.feet) {
                                ForEach(3..<8) { feet in
                                    Text("\(feet)").tag(feet)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 100)
                            .padding(2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.secondary.opacity(0.2), lineWidth: 1)
                            )
                            
                            Text("ft")
                            
                            
                            Picker("Inches", selection: $model.inches) {
                                ForEach(0..<12) { inch in
                                    Text("\(inch)").tag(inch)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 100)
                            .padding(2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.secondary.opacity(0.2), lineWidth: 1)
                            )
                            
                            Text("in")
                        }
                    } else {
                        HStack {
                            Picker("Centimeters", selection: $model.cm) {
                                ForEach(100..<250) { cm in
                                    Text("\(cm)").tag(Double(cm))
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 100)
                            .padding(2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.secondary.opacity(0.2), lineWidth: 1)
                            )
                            
                            Text("cm")
                        }
                        .padding(.horizontal, 85)
                    }
                }
                .tint(.fblack)
                // add error thing here
                
                // BIRTHDATE
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Birth date")
                            .foregroundStyle(.fblack)
                            .font(.system(.title2, design: .rounded))

                        Spacer()

                        // we did this bc there was a gray pill background that we did not want
                        ZStack {
                            // Date
                            HStack {
                                Text(
                                    (model.birthDate ?? Date())
                                        .formatted(date: .abbreviated, time: .omitted)
                                )
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
                            DatePicker(
                                "",
                               selection: Binding<Date>(
                                    get: { model.birthDate ?? Date() },
                                    set: { model.birthDate = $0 }
                               ),
                                in: ...model.maxBirthDate,
                                displayedComponents: .date
                            )
                            .tint(.fblack)
                            .labelsHidden()
                            .opacity(0.02)
                            .contentShape(Rectangle())
                        }
                    }
                    Text("You must be at least 13 years old to use this app.")
                        .foregroundColor(.fblue)
                        .font(.caption)
                }
                // add error thing here
                
                // SEX
                HStack {
                    Text("Sex")
                        .foregroundStyle(.fblack)
                        .font(.system(.title2, design: .rounded))
                    
                    Spacer()

                    Picker("Sex", selection: $model.sex) {
                        Text(Sex.male.label).tag(Sex.male)
                        Text(Sex.female.label).tag(Sex.female)
                        Text(Sex.other.label).tag(Sex.other)
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 80)
                    .frame(width: 135)
                    .padding(2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.secondary.opacity(0.2), lineWidth: 1)
                    )
                    .tint(.fblack)
                }
                // add error thing here
                
                Spacer()

            }
            .padding(.horizontal, 10)
            .padding()
        }
    }
}


#Preview {
    DemographicsView()
        .environmentObject(UserModel())
}
