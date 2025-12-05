//
//  EmailPasswordComponent.swift
//  FoodLens
//
//  Created by Melanie & Muna on 11/7/25.
//

import SwiftUI

struct EmailPasswordComponent: View {
    @Binding var email: String
    @Binding var password: String
    
    let titleStyle: Font.TextStyle
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading) {
                Text("email")
                    .foregroundStyle(.fblack)
                    .font(.system(titleStyle, design: .rounded))
                
                TextField("example＠email.com", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.secondary.opacity(0.2), lineWidth: 1)
                    )
            }
            
            VStack(alignment: .leading) {
                Text("password")
                    .foregroundStyle(.fblack)
                    .font(.system(titleStyle, design: .rounded))
                
                SecureField("******", text: $password)
                    .textContentType(.password) // FIXME: use .newPassword for sign-up flows if desired
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.secondary.opacity(0.2), lineWidth: 1)
                    )
            }
        }
    }
}

private struct PreviewWrapper: View {
    @State private var email: String = ""
    @State private var password: String = ""
    var titleStyle: Font.TextStyle = .title3
    
    var body: some View {
        EmailPasswordComponent(email: $email, password: $password, titleStyle: titleStyle)
    }
}

#Preview {
    PreviewWrapper(titleStyle: .title2)
}
