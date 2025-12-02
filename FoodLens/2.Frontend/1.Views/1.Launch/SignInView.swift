//
//  SignInView.swift
//  FoodLens
//
//  Created by Melanie Escobar on 11/7/25.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        AuthComponent(
            title: "Welcome Back",
            buttonLabel: "Sign In",
            errorMessage: authVM.authError
        ) { email, password in
            Task {
                await authVM.signIn(email: email, password: password)
            }
        }
        .onAppear {
            authVM.authError = nil      // clear old error when user arrives here
        }
    }
}
