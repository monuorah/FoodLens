//
//  SignInView.swift
//  FoodLens
//
//  Created by Melanie Escobar on 11/7/25.
//

import SwiftUI

struct SignInView: View {
    var body: some View {
        AuthComponent(
            title: "Welcome Back",
            buttonLabel: "Sign In",
            destination: AnyView(TabsView())
        )
    }
}
