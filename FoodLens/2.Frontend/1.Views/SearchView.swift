//
//  SearchView.swift
//  FoodLens
//
//  Created by Melanie & Muna on 10/29/25.
//

import SwiftUI

struct SearchView: View {
    @State private var query: String = ""
    @State private var searchResults: [FoodItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.fwhite.ignoresSafeArea()
                VStack(spacing: 16) {
                    // Search
                    HStack {
                        TextField("Search foods...", text: $query)
                            .padding(10)
                            .onSubmit {
                                Task {
                                    await performSearch()
                                }
                            }
                        
                        if isLoading {
                            ProgressView()
                                .padding(.trailing, 10)
                        } else {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.secondary)
                                .padding(.trailing, 10)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.secondary.opacity(0.2), lineWidth: 1)
                    )
                    
                    // Error message
                    if let error = errorMessage {
                        Text(error)
                            .foregroundStyle(.fred)
                            .font(.caption)
                    }
                    
                    // Results
                    if searchResults.isEmpty && !query.isEmpty && !isLoading {
                        VStack {
                            Spacer()
                            Text("No results found")
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                    } else if searchResults.isEmpty {
                        VStack {
                            Spacer()
                            Image(systemName: "carrot")
                                .font(.system(size: 90, weight: .regular))
                                .foregroundStyle(.fgray)
                            Spacer()
                        }
                    } else {
                        List(searchResults) { food in
                            NavigationLink {
                                FoodView(foodItem: food)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(food.name)
                                        .foregroundStyle(.fblack)
                                        .font(.system(.body, design: .rounded))
                                    Text("\(Int(food.calories)) cal · \(food.servingSize)")
                                        .foregroundStyle(.secondary)
                                        .font(.system(.caption, design: .rounded))
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                        .scrollContentBackground(.hidden)
                    }
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Search")
            }
        }
    }
    
    private func performSearch() async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            searchResults = try await USDAFoodService.shared.searchFoods(query: query)
        } catch {
            errorMessage = "Search failed. Try again."
            searchResults = []
        }
        
        isLoading = false
    }
}

#Preview {
    SearchView()
}
