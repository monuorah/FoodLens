//
//  SettingsView.swift
//  FoodLens
//
//  Created by Melanie & Muna on 10/29/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var goToLaunch: String = "no"
    @State private var showingConfirmation = false
    @State private var navigateToLaunchAfterAction = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.fwhite.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 20) {
                    // Title
                    TitleComponent(title: "Settings")
                        .padding(.bottom, 20)
                    
                    //  items
                    VStack(spacing: 20) {
                        LinkComponent(
                            title: "Account",
                            icon: "person.fill",
                            destination: AnyView(AccountSettingsView())
                        )
                        LinkComponent(
                            title: "Demographics",
                            icon: "person.text.rectangle",
                            destination: AnyView(DemographicsSettingsView())
                        )
                        LinkComponent(
                            title: "Preferences",
                            icon: "slider.horizontal.3",
                            destination: AnyView(PreferencesSettingsView())
                        )
                        LinkComponent(
                            title: "Macro Filters",
                            icon: "line.horizontal.3.decrease.circle",
                            destination: AnyView(MacroFiltersSettingsView())
                        )
                    } // VSTACK
                    
                    Spacer()

                    
                    // BUTTONS
                    VStack(spacing: 20) {
                        Button {
                            navigateToLaunchAfterAction = true
                        } label: {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color.fgray)
                                .cornerRadius(10)
                                .foregroundStyle(.fblack)
                        }
                        
                        Button(role: .destructive) {
                            showingConfirmation = true
                        } label: {
                            Label("Delete Account", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color.fred)
                                .cornerRadius(10)
                                .foregroundStyle(.fwhite)
                                .fontWeight(.semibold)
                        }
                    }
                    .confirmationDialog(
                        "Delete Account?",
                        isPresented: $showingConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button("Delete Account", role: .destructive) {
                            // FIXME: Perform delete logic here
                            navigateToLaunchAfterAction = true
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("This action cannot be undone.")
                    }
                    .navigationDestination(isPresented: $navigateToLaunchAfterAction) {
                        LaunchView()
                    }
                } // VStack
                .padding(35)
            } // ZStack
        } // NavigationStack
    }
}









#Preview {
    SettingsView()
}
