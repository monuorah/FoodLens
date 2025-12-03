//
//  SetGoalWeightView.swift
//  FoodLens
//
//  Created by Melanie Escobar on 11/9/25.
//

import SwiftUI

struct SetGoalWeightView: View {
    @EnvironmentObject var model: UserModel
    
    @State private var isShowingTip = false
    
    var body: some View {
        ZStack {
            Color.fwhite.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Title
                TitleComponent(title: "Set Weight Goals")
                
                // Fields
                VStack(spacing: 20) {
                    // Activity Levels
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Activity Levels")
                                .foregroundStyle(.fblack)
                                .font(.system(.title3, design: .rounded))
                            
                            Button {
                                isShowingTip.toggle()
                            } label: {
                                Image(systemName: "info.circle")
                                    .foregroundStyle(.fblue)
                                    .font(.title3)
                            }
                            .popover(isPresented: $isShowingTip, arrowEdge: .top) {
                                VStack(alignment: .leading, spacing: 20) {
                                    
                                    VStack(alignment: .leading, spacing: 10) {
                                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                                            Text("\(level.label):")
                                                .bold()
                                            Text("\(level.description)")
                                        }
                                    }


                                    Button("Got it") {
                                        isShowingTip = false
                                    }
                                    .font(.callout)
                                    .foregroundStyle(.fblue)
                                    .frame(maxWidth: .infinity)
                                    .padding(6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.fblue.opacity(0.2), lineWidth: 1)
                                    )
                                }
                                .padding(30)
                                .cornerRadius(12)
                                .presentationCompactAdaptation(.popover)
                            }
                        }
                        
                        Picker("Achievement", selection: $model.currentActivityLevel) {
                            // currentActivityLevel is optional in the model, so tag with ActivityLevel?
                            Text(ActivityLevel.sedentary.label).tag(ActivityLevel.sedentary)
                            Text(ActivityLevel.lightlyActive.label).tag(ActivityLevel.lightlyActive)
                            Text(ActivityLevel.moderatelyActive.label).tag(ActivityLevel.moderatelyActive)
                            Text(ActivityLevel.veryActive.label).tag(ActivityLevel.veryActive)
                            Text(ActivityLevel.extraActive.label).tag(ActivityLevel.extraActive)
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)
                        .padding(2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.secondary.opacity(0.2), lineWidth: 1)
                        )
                        .tint(.fblack)
                    }
                    
                    // CURRENT WEIGHT
                    HStack(spacing: 8) {
                        Text("Current weight")
                            .foregroundStyle(.fblack)
                            .font(.system(.title3, design: .rounded))

                        Spacer()

                        HStack(spacing: 10) {
                            // number field
                            TextField(
                                model.selectedWeightUnit == UnitSystem.imperial ? "170" : "75",
                                value: $model.currentWeight,
                                format: .number.precision(.fractionLength(1))
                            )
                            .keyboardType(.decimalPad)
                            .frame(width: 60)
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.secondary.opacity(0.2), lineWidth: 1)
                            )

                            // unit picker
                            Picker("Unit", selection: $model.selectedWeightUnit) {
                                Text("lbs").tag(UnitSystem.imperial)
                                Text("kg").tag(UnitSystem.metric)
                            }
                            .pickerStyle(.menu)
                            .padding(2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.secondary.opacity(0.2), lineWidth: 1)
                            )
                            .tint(.fblack)
                        }
                    }
                    if let error = model.currentWeightErrorText {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    // bodyFatPercent
                    HStack(spacing: 8) {
                        Text("Body Fat %")
                            .foregroundStyle(.fblack)
                            .font(.system(.title3, design: .rounded))
                        
                        Text("(optional)")
                            .foregroundStyle(.fblue)

                        Spacer()

                        HStack(spacing: 10) {
                            // number field
                            TextField("30", value: $model.bodyFatPercent, format: .number.precision(.fractionLength(1)))
                            .keyboardType(.decimalPad)
                            .frame(width: 60)
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.secondary.opacity(0.2), lineWidth: 1)
                            )

                            Text("%")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // Don't show other components unless current weight has been entered
                    if model.currentWeight != nil {
                        // TARGET
                        HStack {
                            Text("Target")
                                .foregroundStyle(.fblack)
                                .font(.system(.title2, design: .rounded))
                                .bold()
                            
                            Spacer()
                            
                            Picker("Target", selection: $model.target) {
                                Text("\(Target.lose.label) weight").tag(Target.lose)
                                Text("\(Target.gain.label) weight").tag(Target.gain)
                                Text("\(Target.maintain.label) weight").tag(Target.maintain)
                            }
                            .pickerStyle(.menu)
                            .padding(2)
                            .frame(width: 220)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.secondary.opacity(0.2), lineWidth: 1)
                            )
                            .tint(.fblack)
                        }
                        
                        // GOAL WEIGHT
                        if(model.target == Target.lose || model.target == Target.gain) {
                            VStack(spacing: 15) {
                                HStack(spacing: 10) {
                                    Text("Goal Weight")
                                        .foregroundStyle(.fblack)
                                        .font(.system(.title3, design: .rounded))
                                    
                                    Spacer()
                                    
                                    // number field
                                    TextField(
                                        model.selectedWeightUnit == UnitSystem.imperial ? "170" : "75",
                                        value: $model.goalWeight,
                                        format: .number.precision(.fractionLength(1))
                                    )
                                    .keyboardType(.decimalPad)
                                    .frame(width: 60)
                                    .padding(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.secondary.opacity(0.2), lineWidth: 1)
                                    )

                                    // unit
                                    Text(model.selectedWeightUnit == UnitSystem.imperial ? "lbs" : "kg")
                                        .foregroundStyle(.fblack.opacity(0.7))
                                }
                                
                                
                                // HOW WILL USER LOSE/GAIN WEIGHT?
                                Text("How would you like to go about it?")
                                    .foregroundStyle(.fblack)
                                    .font(.system(.title3, design: .rounded))
                                
                                // Timeframe mode: Rate | Duration | Date (month-year)
                                Picker("Mode", selection: $model.goalTimeframeMode) {
                                    Text(GoalTimeframeMode.rate.label).tag(GoalTimeframeMode.rate)
                                    Text(GoalTimeframeMode.duration.label).tag(GoalTimeframeMode.duration)
                                }
                                .pickerStyle(.segmented)
                                .tint(.fblack)

                                if model.goalTimeframeMode == GoalTimeframeMode.rate {
                                    // MARK: Rate-based: amount + per week/month
                                    HStack(spacing: 15) {
                                        Text("\(model.target.label)")
                                            .foregroundStyle(.secondary)
                                        TextField("1.0", value: $model.goalRateAmount, format: .number.precision(.fractionLength(0...1)))
                                            .keyboardType(.decimalPad)
                                            .frame(width: 40)
                                            .padding(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(.secondary.opacity(0.2), lineWidth: 1)
                                            )
                                        
                                        Text(model.selectedWeightUnit == .imperial ? "lbs" : "kg")
                                            .foregroundStyle(.secondary)
                                        
                                        Picker("Unit", selection: $model.goalRateUnit) {
                                            Text(GoalRateUnit.week.label).tag(GoalRateUnit.week)
                                            Text(GoalRateUnit.month.label).tag(GoalRateUnit.month)
                                        }
                                        .pickerStyle(.menu)
                                        .frame(width: 140)
                                        .padding(2)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(.secondary.opacity(0.2), lineWidth: 1)
                                        )
                                        .tint(.fblack)
                                    }
                                    
                                } else if model.goalTimeframeMode == GoalTimeframeMode.duration {
                                    // MARK: Duration-based: value + weeks/months
                                    VStack {
                                        HStack(spacing: 10) {
                                            Text("\(model.target.label) \((model.weightTarget).formatted(.number.precision(.fractionLength(1)))) " +
                                                 (model.selectedWeightUnit == UnitSystem.imperial ? "lbs" : "kg") +
                                                 " in \(model.goalDurationValue)")
                                                .foregroundStyle(.secondary)

                                            
                                            Picker("Unit", selection: $model.goalDurationUnit) {
                                                Text(GoalDurationUnit.weeks.label).tag(GoalDurationUnit.weeks)
                                                Text(GoalDurationUnit.months.label).tag(GoalDurationUnit.months)
                                            }
                                            .pickerStyle(.menu)
                                            .padding(2)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(.secondary.opacity(0.2), lineWidth: 1)
                                            )
                                            .tint(.fblack)
                                        }
                                        
                                        Stepper(
                                            value: $model.goalDurationValue,
                                            in: 1...(model.goalDurationUnit == GoalDurationUnit.weeks ? 104 : 24)
                                        ) {}
                                        .labelsHidden()
                                        
                                        Text("Around \(model.etaMonthYearString)")
                                            .foregroundStyle(.secondary)
                                    }

                                }
                                
                                if let error = model.weightGoalErrorText {
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }

                                if let error = model.timeframeErrorText {
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    


                }
                .padding(.horizontal, 10)
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    SetGoalWeightView()
        .environmentObject(UserModel())
}
