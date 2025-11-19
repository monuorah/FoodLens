//
//  ScanBarcodeView.swift
//  FoodLens
//
//  Created by Melanie & Muna on 10/29/25.
//

import SwiftUI

struct ScanBarcodeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.fwhite.ignoresSafeArea()
                VStack(spacing: 16) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.system(size: 48, weight: .regular))
                        .foregroundStyle(.forange)
                    Text("Scan Barcode")
                        .font(.system(.title2, design: .rounded))
                        .foregroundStyle(.fblack)
                    Text("Barcode goes here.")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding()
                .navigationTitle("Scan Barcode")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    ScanBarcodeView()
}
