//
//  OnboardingPagerView.swift
//  FoodLens
//
//  Created by Melanie Escobar on 11/7/25.
//

import SwiftUI

struct OnboardingPagerView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var currentPage: Int = 0
    @StateObject private var model = UserModel()
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
                                    .environmentObject(model)
                            case 1:
                                SetGoalWeightView()
                                    .environmentObject(model)
                            case 2:
                                SetGoalCaloriesView()
                                    .environmentObject(model)
                            case 3:
                                SetGoalMacrosView()
                                    .environmentObject(model)
                            case 4:
                                GrantAccessView()
                                    .environmentObject(model)
                            case 5:
                                // FINAL SCREEN -> animation + callback
                                CreatedAccountView {
                                    // when animation finishes:
                                    authVM.completeOnboarding()     // mark as done in Firestore + local
                                    goHome = true                   // show Tabs(Home)
                                }
                            default:
                                DemographicsView()
                                    .environmentObject(model)
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
    
    // MARK: - Buttons
    
    @ViewBuilder
    private var buttonsSection: some View {
        let isFirst = currentPage == firstIndex
        let isLast  = currentPage == lastIndex
        
        if isLast {
            EmptyView() // no buttons on final animation screen
        } else {
            HStack(spacing: 15) {
                if !isFirst {
                    Button {
                        goTo(currentPage - 1)
                    } label: {
                        primaryButtonLabel("Go Back")
                    }
                }
                
                Button {
                    goTo(currentPage + 1)
                } label: {
                    primaryButtonLabel("Continue")
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            .padding(.bottom, 10)
        }
    }
    
    private func primaryButtonLabel(_ text: String) -> some View {
        Text(text)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(Color.forange)
            .cornerRadius(10)
            .foregroundStyle(.fwhite)
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
