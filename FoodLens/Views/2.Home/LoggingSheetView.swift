//
//  LoggingSheetView.swift
//  FoodLens
//
//  Created by Melanie Escobar on 11/7/25.
//

import SwiftUI

struct LoggingSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var showWeightSheet = false
    @State private var currentWeight: Double = 170
    @State private var weightUnit: String = "imperial" // "imperial" (lbs) or "metric"
    
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.fwhite.ignoresSafeArea()
                
                // NAVLINKS
                LazyVGrid(columns: columns, spacing: 20) {
                    // Search Food
                    TileComponent(
                        icon: "magnifyingglass",
                        title: "Search Food",
                        tint: .fblack,
                        destination: AnyView(SearchView())
                    )
                    
                    // Scan Food
                    TileComponent(
                        icon: "camera.viewfinder",
                        title: "Scan Food",
                        tint: .fblack,
                        destination: AnyView(ScanFoodView())
                    )
                    
                    // Scan Barcode
                    TileComponent(
                        icon: "barcode.viewfinder",
                        title: "Scan Barcode",
                        tint: .fblack,
                        destination: AnyView(ScanBarcodeView())
                    )
                    
                    // Weight (sheet)
                    Button {
                        showWeightSheet = true
                    } label: {
                        TileComponent(icon: "scale.3d", title: "Change Weight", tint: .fblack)
                    }
                    .sheet(isPresented: $showWeightSheet) {
                        WeightSheetView()
                            .ignoresSafeArea()
                            .presentationDetents([.fraction(0.4), .medium])
                    }
                }
                .padding(30)
            }
        }
    }
}
