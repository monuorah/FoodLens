//
//  TileComponent.swift
//  FoodLens
//
//  Created by Melanie & Muna on 11/7/25.
//

import SwiftUI

struct TileComponent: View {
    var icon: String
    var title: String
    var tint: Color
    var destination: AnyView?
    
    var body: some View {
        NavigationLink {
            destination
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(tint.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(tint.opacity(0.25), lineWidth: 1)
                    )
                VStack(spacing: 10) {
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(tint)
                    Text(title)
                        .foregroundStyle(tint)
                        .font(.system(.headline, design: .rounded))
                }
                .padding(20)
            }
        }
        .disabled(destination == nil) // disable navigation when its weight
    }
}
