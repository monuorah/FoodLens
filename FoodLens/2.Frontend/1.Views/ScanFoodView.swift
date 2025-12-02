//
//  ScanFoodView.swift
//  FoodLens
//
//  Created by Melanie & Muna on 10/29/25.
//

import SwiftUI

struct ScanFoodView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.fwhite.ignoresSafeArea()
                VStack(spacing: 16) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 48, weight: .regular))
                        .foregroundStyle(.fgreen)
                    Text("Scan Food")
                        .font(.system(.title2, design: .rounded))
                        .foregroundStyle(.fblack)
                    Text("Camera goes here.")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding()
                .navigationTitle("Scan Food")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    ScanFoodView()
}
