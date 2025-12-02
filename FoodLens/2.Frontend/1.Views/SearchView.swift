//
//  SearchView.swift
//  FoodLens
//
//  Created by Melanie & Muna on 10/29/25.
//

import SwiftUI

struct SearchView: View {
    @State private var query: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.fwhite.ignoresSafeArea()
                VStack(spacing: 16) {
                    // Search
                    TextField("Search foods...", text: $query)
                        .overlay(
                            HStack {
                                Spacer()
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(.secondary)
                                    .frame(width: 20, height: 20)
                                    .padding(.trailing, 10)
                            }
                        )
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.secondary.opacity(0.2), lineWidth: 1)
                        )
                    
                    // Conditional content
                    if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        // Carrot icon when empty
                        VStack {
                            Spacer()
                            Image(systemName: "carrot")
                                .font(.system(size: 90, weight: .regular))
                                .foregroundStyle(.fgray)
                                .accessibilityLabel("Carrot")
                            Spacer()
                        }
                    } else {
                        // Navigable list to two FoodViews with a chevron
                        List {
                            NavigationLink {
                                FoodView(title: "Result 1")
                            } label: {
                                Text("Result 1")
                                    .foregroundStyle(.fblack)
                                    .font(.system(.body, design: .rounded))
                            }
                            
                            NavigationLink {
                                FoodView(title: "Result 2")
                            } label: {
                                Text("Result 2")
                                    .foregroundStyle(.fblack)
                                    .font(.system(.body, design: .rounded))
                            }
                        }
                        .listStyle(.insetGrouped)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                    }
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Search")
            }
        }
    }
}

#Preview {
    SearchView()
}
