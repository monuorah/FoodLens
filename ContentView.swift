//
//  ContentView.swift
//  FoodLens
//
//  Created by Melanie & Muna on 10/29/25.
//
// we will use this view to dictate where the user will go when they open the app (launch/tabs)

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        Group {
            if authVM.user == nil { // Not logged in
                LaunchView()
            } else if authVM.userProfile?.onboardingCompleted == true { // logged in
                TabsView() // + onboarding done
            } else {
                OnboardingPagerView() // + onboarding NOT done
            }
        }
    }
}
