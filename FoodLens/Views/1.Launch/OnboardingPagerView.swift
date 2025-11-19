//
//  OnboardingPagerView.swift
//  FoodLens
//
//  Created by Melanie Escobar on 11/7/25.
//

import SwiftUI

struct OnboardingPagerView: View {
    @State private var currentPage: Int = 0
    @StateObject private var model = UserModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fwhite.ignoresSafeArea()
                VStack {
                    TabView(selection: $currentPage) {
                        DemographicsView()
                            .tag(0)
                            .environmentObject(model)
                        
                        SetGoalWeightView()
                            .tag(1)
                            .environmentObject(model)
                        
                        SetGoalCaloriesView()
                            .tag(2)
                            .environmentObject(model)
                        
                        SetGoalMacrosView()
                            .tag(3)
                            .environmentObject(model)
                        
                        GrantAccessView()
                            .tag(4)
                            .environmentObject(model)
                        
                        CreatedAccountView()
                            .tag(5)
                    } // tab
                    // don't show pager bc we will do custom pager
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    // Disable user swiping between pages; pages only change programmatically
                    .highPriorityGesture(DragGesture())
                    
                    if (currentPage != 5) { // don't show pager on all set page
                        HStack(spacing: 12) {
                            ForEach(0..<5, id: \.self) { index in
                                Circle()
                                    .fill(currentPage == index ? Color.fgreen : Color.fgray)
                                    .frame(
                                        width: currentPage == index ? 12 : 8,
                                        height: currentPage == index ? 12 : 8
                                    )
                                    .animation(.spring(), value: currentPage)
                            }
                        }
                    }
                    
                    // next & back button
                    if currentPage == 0 {
                        Button {
                            withAnimation(.spring()) {
                                //if model.validateDemographics() {
                                    currentPage = 1
                                //}
                            }
                        } label: {
                            Text("Continue")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color.forange)
                                .cornerRadius(10)
                                .foregroundStyle(.fwhite)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 30)
                                .padding(.top, 20)
                                .padding(.bottom, 10)
                        }
                    }
                    else if (currentPage == 1 || currentPage == 2) {
                        HStack(spacing: 15) {
                            Button {
                                withAnimation(.spring()) {
                                    switch currentPage {
                                        case 1:
                                            currentPage = 0
                                        case 2:
                                            currentPage = 1
                                        default:
                                            break
                                    }
                                }
                            } label: {
                                Text("Go Back")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 15)
                                    .background(Color.forange)
                                    .cornerRadius(10)
                                    .foregroundStyle(.fwhite)
                                    .fontWeight(.semibold)
                                    .padding(.top, 20)
                                    .padding(.bottom, 10)
                            }
                            
                            Button {
                                withAnimation(.spring()) {
                                    switch currentPage {
                                        case 1:
                                            //if model.validateGoals() {
                                                currentPage = 2
                                            //}
                                        case 2:
                                            //if model.validateAccess() {
                                                currentPage = 3
                                            //}
                                        default:
                                            break
                                    }
                                }
                            } label: {
                                Text("Continue")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 15)
                                    .background(Color.forange)
                                    .cornerRadius(10)
                                    .foregroundStyle(.fwhite)
                                    .fontWeight(.semibold)
                                    .padding(.top, 20)
                                    .padding(.bottom, 10)
                            }
                        }
                        .padding(.horizontal, 30)
                    }
                    else { // current page == 5
                        NavigationLink {
                            TabsView()
                        } label: {
                            Text("Go Home")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color.forange)
                                .cornerRadius(10)
                                .foregroundStyle(.fwhite)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 30)
                                .padding(.top, 20)
                                .padding(.bottom, 10)
                        }
                    }
                    
                } // vstack
            }// zstack
            .tint(.fblack)
        } // nav stack
    }
}

#Preview {
    OnboardingPagerView()
}
