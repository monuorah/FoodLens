//
//  AuthComponent.swift
//  FoodLens
//
//  Created by Melanie & Muna on 10/29/25.
//

import SwiftUI

struct AuthComponent: View {
    var title: String
    var buttonLabel: String
    var errorMessage: String?
    var onPrimaryTap: (String, String) -> Void   // email, password

    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fwhite.ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    TitleComponent(title: title)
                    
                    VStack(spacing: 30) {
                        EmailPasswordComponent(
                            email: $email,
                            password: $password,
                            titleStyle: .title
                        )
                        
                        if let error = errorMessage {
                            Text(error)
                                .font(.footnote)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 30)
                    
                    Spacer()
                    
                    Button {
                        onPrimaryTap(email, password)
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
                }
                .padding()
            }
        }
    }
}
