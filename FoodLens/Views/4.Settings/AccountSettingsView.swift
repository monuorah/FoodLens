//
//  AccountSettingsView.swift
//  FoodLens
//
//  Created by Melanie Escobar on 11/7/25.
//

import SwiftUI

struct AccountSettingsView: View {
    // Snapshots of initial values for change detection
    @State private var name = "John"
    @State private var email = "johndoe@gmail.com"
    @State private var password = "JohnDoe21"
    
    // Editable fields
    @State private var newName = ""
    @State private var newEmail = ""
    @State private var newPassword = ""

    // Derived flags
    private var hasChanges: Bool {
        // Disallow empty or whitespace-only in any field
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = newEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = newPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return (
            (name != trimmedName || email != trimmedEmail || password != trimmedPassword)
            &&
            (!trimmedName.isEmpty && !trimmedEmail.isEmpty && !trimmedPassword.isEmpty)
        )
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.fwhite.ignoresSafeArea()
                
                VStack(spacing: 25) {
                    // Title
                    TitleComponent(title: "Account")
                        
                    VStack(alignment: .leading) {
                        Text("First Name")
                            .foregroundStyle(.fblack)
                            .font(.system(.title3, design: .rounded))
                        
                        TextField("John", text: $newName)
                            .padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.secondary.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    EmailPasswordComponent(email: $newEmail, password: $newPassword, titleStyle: .title3)
                    
                    Spacer()
                    
                    Button {
                        // Perform save, then reset snapshots so button disables again
                        name = newName
                        email = newEmail
                        password = newPassword
                    } label: {
                        Label("Save", systemImage: hasChanges ? "checkmark.icloud" : "xmark.icloud")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(hasChanges ? Color.fgreen : Color.fgray)
                            .cornerRadius(10)
                            .foregroundStyle(hasChanges ? .fwhite : .fblack)
                    }
                    .disabled(!hasChanges)
                    .padding(.bottom, 30)
                    
                } // VSTACK
                .padding(.horizontal, 35)
                .onAppear { // Capture initial values on first appearance
                    newName = name
                    newEmail = email
                    newPassword = password
                }
            } // ZSTACK
        } // NAV
    }
}
