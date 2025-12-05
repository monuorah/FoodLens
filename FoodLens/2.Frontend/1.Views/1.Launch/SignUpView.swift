//
//  SignUpView.swift
//  FoodLens
//
//  Created by Melanie & Muna on 11/7/25.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        AuthComponent(
            title: "Get Started",
            buttonLabel: "Sign Up",
            errorMessage: authVM.authError
        ) { email, password in
            Task {
                await authVM.signUp(email: email, password: password)
                // after sign up succeeds, NavigationLink already pushes OnboardingPagerView
                // (LaunchView's link still goes to SignUpView -> OnboardingPagerView)
            }
        }
        .onAppear {
            authVM.authError = nil      // clear old error when user arrives here
        }
    }
}
