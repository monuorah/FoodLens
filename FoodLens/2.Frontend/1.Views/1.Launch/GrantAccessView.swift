//
//  GrantAccessView.swift
//  FoodLens
//
//  Created by Melanie & Muna on 11/7/25.
//

import SwiftUI

struct GrantAccessView: View {
    @EnvironmentObject var model: UserModel
    
    var body: some View {
        ZStack {
            Color.fwhite.ignoresSafeArea()
            
            VStack {
                // Title
                TitleComponent(title: "Grant Access")
                
                Spacer()
                
                // Fields
                VStack(spacing: 30) {
                    HStack {
                        Text("Camera")
                            .foregroundStyle(.fblack)
                            .font(.system(.title, design: .rounded))
                        
                        Spacer()
                        
                        Toggle("", isOn: $model.cameraEnabled)
                            .labelsHidden()
                    }
                    
                    HStack {
                        Text("HealthKit App")
                            .foregroundStyle(.fblack)
                            .font(.system(.title, design: .rounded))
                        
                        Spacer()
                        
                        Toggle("", isOn: $model.healthEnabled)
                            .labelsHidden()
                    }
                }
                .tint(.fblack)
                .padding(.horizontal, 30)
                
                Spacer()
                Spacer()
                
                // No button here; final Save is in CreatedAccountView
            }
            .padding()
        }
    }
}
