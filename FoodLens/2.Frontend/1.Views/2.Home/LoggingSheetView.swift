//
//  LoggingSheetView.swift
//  FoodLens
//
//  Created by Melanie & Muna on 11/7/25.
//

import SwiftUI

struct LoggingSheetView: View {
    enum Action {
        case search
        case scanFood
        case scanBarcode
        case changeWeight
    }

    // Let the parent (HomeView) decide what to present full-screen
    var onSelected: (Action) -> Void = { _ in }

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
                
                LazyVGrid(columns: columns, spacing: 20) {
                    // Search Food (notify parent to push)
                    Button {
                        onSelected(.search)
                    } label: {
                        TileComponent(icon: "magnifyingglass", title: "Search Food", tint: .fblack)
                    }

                    // Scan Food (notify parent to present full screen)
                    Button {
                        onSelected(.scanFood)
                    } label: {
                        TileComponent(icon: "camera.viewfinder", title: "Scan Food", tint: .fblack)
                    }

                    // Scan Barcode (notify parent to present full screen)
                    Button {
                        onSelected(.scanBarcode)
                    } label: {
                        TileComponent(icon: "barcode.viewfinder", title: "Scan Barcode", tint: .fblack)
                    }
                    
                    // Weight (sheet stays here)
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
