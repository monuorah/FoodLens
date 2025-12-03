//
//  OnboardingPagerView.swift
//  FoodLens
//
//  Created by Melanie Escobar on 11/7/25.
//

import SwiftUI

struct OnboardingPagerView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var model: UserModel
    
    @State private var currentPage: Int = 0
    @State private var goHome = false
    
    private let firstIndex = 0
    private let lastIndex  = 5
    
    var body: some View {
        Group {
            if goHome {
                TabsView() // <- first tab is Home
            } else {
                ZStack {
                    Color.fwhite.ignoresSafeArea()
                    
                    VStack {
                        // MAIN ONBOARDING CONTENT
                        Group {
                            switch currentPage {
                            case 0:
                                DemographicsView()
                            case 1:
                                SetGoalWeightView()
                            case 2:
                                SetGoalCaloriesView()
                            case 3:
                                SetGoalMacrosView()
                            case 4:
                                GrantAccessView()
                            case 5:
                                // FINAL SCREEN -> animation + callback
                                CreatedAccountView {
                                    // when animation finishes:
                                    authVM.completeOnboarding()     // mark as done in Firestore + local
                                    authVM.saveCurrentUserModel()   // save full UserModel to Firestore
                                    goHome = true                   // show Tabs(Home)
                                }
                            default:
                                DemographicsView()
                            }
                        }
                        .animation(.easeInOut, value: currentPage)
                        
                        // DOTS
                        if currentPage != lastIndex {
                            HStack(spacing: 12) {
                                ForEach(firstIndex..<lastIndex, id: \.self) { index in
                                    Circle()
                                        .fill(currentPage == index ? Color.fgreen : Color.fgray)
                                        .frame(
                                            width: currentPage == index ? 12 : 8,
                                            height: currentPage == index ? 12 : 8
                                        )
                                        .animation(.spring(), value: currentPage)
                                }
                            }
                            .padding(.top, 16)
                        }
                        
                        buttonsSection
                    }
                    .padding(.bottom, 10)
                }
                .tint(.fblack)
            }
        }
        .onAppear {
            // Resume where they left off (clamped just in case)
            if let step = authVM.userProfile?.onboardingStep {
                currentPage = min(max(step, firstIndex), lastIndex)
            }
        }
    }
    
    // MARK: contraints on going to next page
    private var canContinueFromCurrentPage: Bool {
        switch currentPage {
        case 0: return model.isDemographicsValid
        case 1: return model.isWeightGoalsValid
        case 2: return model.isCaloriesValid
        case 3: return model.isMacrosValid
        case 4: return true      // GrantAccessView
        default: return true
        }
    }

    
    // MARK: - Buttons
    
    @ViewBuilder
    private var buttonsSection: some View {
        let isFirst = currentPage == firstIndex
        let isLast  = currentPage == lastIndex
        let canContinue = canContinueFromCurrentPage

        if isLast {
            EmptyView()
        } else {
            HStack(spacing: 15) {
                if !isFirst {
                    Button {
                        goTo(currentPage - 1)
                    } label: {
                        primaryButtonLabel("Go Back", enabled: true)
                    }
                }

                Button {
                    goTo(currentPage + 1)
                } label: {
                    primaryButtonLabel("Continue", enabled: canContinue)
                }
                .disabled(!canContinue)
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            .padding(.bottom, 10)
        }
    }
    
    private func primaryButtonLabel(_ text: String, enabled: Bool) -> some View {
        Text(text)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(enabled ? Color.forange : Color.forange.opacity(0.4))
            .cornerRadius(10)
            .foregroundStyle(.fwhite.opacity(enabled ? 1.0 : 0.7))
            .fontWeight(.semibold)
    }
    
    private func goTo(_ page: Int) {
        let clamped = min(max(page, firstIndex), lastIndex)
        
        withAnimation(.spring()) {
            currentPage = clamped
        }
        
        // persist progress so user can resume here next time
        authVM.setOnboardingStep(clamped)
    }
}

