//
//  TitleComponent.swift
//  FoodLens
//
//  Created by Melanie & Muna on 11/7/25.
//
// used globally

import SwiftUI

struct TitleComponent: View {
    var title: String
    
    var body: some View {
        Text(title)
            .foregroundStyle(.fblack)
            .font(.system(.largeTitle, design: .rounded))
            .fontWeight(.black)
    }
}
