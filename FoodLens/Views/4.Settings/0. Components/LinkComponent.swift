//
//  LinkComponent.swift
//  FoodLens
//
//  Created by Melanie Escobar on 11/7/25.
//

import SwiftUI

// For Settings
struct LinkComponent: View {
    var title: String
    var icon: String
    var destination: AnyView
    
    var body: some View {
        NavigationLink {
            destination
        } label: {
            HStack {
                Label(title, systemImage: icon)
                    .foregroundStyle(.fblack)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.fblack)
            }
            .padding(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.fgray.opacity(0.5), lineWidth: 1)
            )
        }
    }
}



#Preview {
    LinkComponent(title: "Home", icon: "house", destination: AnyView(HomeView()))
}
