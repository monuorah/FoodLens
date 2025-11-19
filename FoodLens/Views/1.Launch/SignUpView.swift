//
//  SignUpView.swift
//  FoodLens
//
//  Created by Melanie Escobar on 11/7/25.
//

import SwiftUI

struct SignUpView: View {
    var body: some View {
        AuthComponent(
            title: "Get Started",
            buttonLabel: "Sign Up",
            destination: AnyView(OnboardingPagerView())
        )
    }
}
