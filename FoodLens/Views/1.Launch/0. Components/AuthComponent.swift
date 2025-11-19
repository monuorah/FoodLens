//
//  AuthComponent.swift
//  FoodLens
//
//  Created by Melanie & Muna on 10/29/25.
//

import SwiftUI

struct AuthComponent: View {
    var title: String            // "Welcome Back" / "Get Started"
    var buttonLabel: String      // "Sign In" / "Sign Up"
    var destination: AnyView     // navigation
    
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.fwhite.ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    // Title
                    TitleComponent(title: title)
                    
                    // Fields
                    VStack(spacing: 30) {
                        EmailPasswordComponent(email: $email, password: $password, titleStyle: .title)
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 30)
                    
                    Spacer()
                    
                    // FIXME: component?
                    // Continue button
                    NavigationLink {
                        destination
                    } label: {
                        Text(buttonLabel)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color.forange)
                            .cornerRadius(10)
                            .foregroundStyle(.fwhite)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 30)
                    }
                    
                    Spacer()
                    
                } // VSTACK
                .padding()
            } // ZSTACK
        } // NAV
    }
}

#Preview {
    AuthComponent(title: "Welcome Back", buttonLabel: "Sign In", destination: AnyView(HomeView()))
}
