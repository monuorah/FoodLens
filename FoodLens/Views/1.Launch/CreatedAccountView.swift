//
//  CreatedAccountView.swift
//  FoodLens
//
//  Created by Melanie Escobar on 11/7/25.
//

import SwiftUI

struct CreatedAccountView: View {
    var body: some View {
        ZStack {
            Color.fwhite.ignoresSafeArea()
            VStack {
                TitleComponent(title: "All Set!")
                
                Spacer()

                VStack(spacing: 30) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 120, weight: .bold))
                        .foregroundStyle(.fgreen)
                    Text("Your account is ready")
                        .foregroundStyle(.fblack)
                        .font(.system(.title2, design: .rounded))
                        .bold()
                }

                Spacer()
                Spacer()

            }
        }
    }
}

#Preview {
    CreatedAccountView()
}
