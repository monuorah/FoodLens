//
//  NameComponent.swift
//  FoodLens
//
//  Created by Melanie Escobar on 11/7/25.
//

import SwiftUI

struct NameComponent: View {
    @Binding var name: String
    
    let titleStyle: Font.TextStyle
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("First Name")
                .foregroundStyle(.fblack)
                .font(.system(titleStyle, design: .rounded))
            
            TextField("John", text: $name)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.secondary.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

private struct PreviewWrapper: View {
    @State private var name: String = ""
    var titleStyle: Font.TextStyle = .title3
    
    var body: some View {
        NameComponent(name: $name, titleStyle: titleStyle)
    }
}

#Preview {
    PreviewWrapper(titleStyle: .title3)
}
