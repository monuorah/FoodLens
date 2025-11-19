//
//  LaunchView.swift
//  FoodLens
//
//  Created by Melanie & Muna on 10/29/25.
//

import SwiftUI

struct LaunchView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.fgreen.ignoresSafeArea()
                VStack {
                    Spacer()
                    
                    VStack(spacing: 85) {
                        // SF Compact Rounded
                        Text("FoodLens")
                            .foregroundStyle(.fwhite)
                            .fontWeight(.black)
                            .font(.system(.largeTitle, design: .rounded)).fontWeight(.black).dynamicTypeSize(.xxxLarge)
                        
                        Image("logosvg")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 310)
                    } // vstack

                    Spacer()
                    
                    VStack(spacing: 25) {
                        NavigationLink {
                            SignUpView()
                        } label: {
                            Text("Get Started")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(
                                    LinearGradient(
                                        colors: [Color.fred, Color.forange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    .opacity(0.9)
                                )
                                .cornerRadius(14)
                                .foregroundStyle(.fwhite)
                                .bold()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.forange, lineWidth: 2)
                                    )
                        }

                        NavigationLink {
                            SignInView()
                        } label: {
                            Text("Sign In")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color.fwhite,
                                            Color.fblue,
                                            Color.fdarkblue.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    .opacity(0.3)
                                )
                                .cornerRadius(14)
                                .foregroundColor(Color.fwhite)
                                .bold()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.fwhite, lineWidth: 2)
                                    )
                        }
                    } // VSTACK
                    .padding(.horizontal, 30)
                    .padding(.vertical)

                    
                } // VSTACK
                .padding()
                
            } // ZSTACK
        } // NAV

    }
}

#Preview {
    LaunchView()
}
