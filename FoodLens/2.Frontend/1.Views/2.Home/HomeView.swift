//
//  HomeView.swift
//  FoodLens
//
//  Created by Melanie & Muna on 10/29/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var model: UserModel
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var showLoggingSheet = false
    
    private var greetingName: String {
        if !model.name.isEmpty {
            return model.name
        } else if let name = authVM.userProfile?.name, !name.isEmpty {
            return name
        } else {
            return "there"
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.fwhite.ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    // Title
                    TitleComponent(title: "Hi, \(greetingName) 👋")
                    
                    Text("Today at a glance")
                        .foregroundStyle(.fblack)
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.black)
                    
                    ScrollView {
                        // Today food tracked
                        VStack(spacing: 24) {
                            // Breakfast
                            MealCardTile(
                                title: "Breakfast",
                                tint: .yellow,
                                items: [
                                    MealItem(left: "egg", right: "2 servings", isPlaceholder: false, foodItem: nil)
                                ]
                            )
                            .padding(.horizontal, 6)
                            
                            // Lunch
                            MealCardTile(
                                title: "Lunch",
                                tint: .blue,
                                items: [
                                    MealItem(left: "egg", right: "2 servings", isPlaceholder: false, foodItem: nil),
                                    MealItem(left: "toast", right: "2 servings", isPlaceholder: false, foodItem: nil)
                                ]
                            )
                            .padding(.horizontal, 6)
                            
                            // Dinner
                            MealCardTile(
                                title: "Dinner",
                                tint: .brown,
                                items: [
                                    MealItem(left: "empty..", right: nil, isPlaceholder: true, foodItem: nil)
                                ]
                            )
                            .padding(.horizontal, 6)
                            
                            // Snacks (gray like screenshot)
                            MealCardTile(
                                title: "Snacks",
                                tint: .fred,
                                items: [
                                    MealItem(left: "empty..", right: nil, isPlaceholder: true, foodItem: nil)
                                ]
                            )
                            .padding(.horizontal, 6)
                            .padding(.bottom, 40) // so ofset doesnt cut off bottom
                        }
                    } // ScrollView
                    .padding(.bottom, 20)
                    
                    Button {
                        showLoggingSheet = true
                    } label: {
                        Label("Log Food", systemImage: "plus")
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.fblack)
                            .font(.system(.title2, design: .rounded))
                            .bold()
                            .padding(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.fblack, lineWidth: 1))
                            .background(Color.fblack.opacity(0.3))
                            .cornerRadius(10)
                    }
                    .sheet(isPresented: $showLoggingSheet) {
                        LoggingSheetView()
                            .ignoresSafeArea()
                            .presentationDetents([.fraction(0.4), .medium])
                    }
                    
                } // VStack
                .padding(35)
            } // ZStack
        } // NavigationStack
    }
}

// data model for rows/items inside a meal card
struct MealItem: Identifiable {
    let id: UUID = UUID()
    let left: String
    let right: String?
    var isPlaceholder: Bool = false
    let foodItem: FoodItem?
}

struct MealCardTile: View {
    let title: String
    let tint: Color
    var items: [MealItem] = []
    
    var body: some View {
        ZStack {
            // Semicircle tab with title
            Circle()
                .fill(tint)
                .frame(height: 200)
                .shadow(color: tint.opacity(0.12), radius: 6, y: 2)
            
            Text(title)
                .foregroundStyle(tint == .fgray ? .fblack : .fwhite)
                .font(.system(.title3, design: .rounded))
                .bold()
                .offset(y: -60)
            
            // items
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(tint)
                    .offset(y: 60)
                
                // food items
                VStack(spacing: 10) {
                    ForEach(items) { item in
                        MealRow(left: item.left, right: item.right, isPlaceholder: item.isPlaceholder, tint: tint, foodItem: item.foodItem)
                    }
                }
                .offset(y: 40)
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
            }
            
        }
        .padding(.top, 6)
        .padding(.vertical, 30)
    }
}

struct MealRow: View {
    let left: String
    let right: String?
    var isPlaceholder: Bool = false
    let tint: Color
    let foodItem: FoodItem?
    
    var body: some View {
        // Decide if this row should navigate
        let shouldNavigate = !isPlaceholder && foodItem != nil
        
        if shouldNavigate, let foodItem = foodItem {
            NavigationLink {
                FoodView(foodItem: foodItem)
            } label: {
                rowContent
            }
        } else {
            rowContent
        }
    }
    
    @ViewBuilder
    private var rowContent: some View {
        HStack {
            Text(left)
                .foregroundStyle(tint == .fgray ? .fblack : (isPlaceholder ? .fwhite : .fblack))
                .font(.system(.body, design: .rounded))
            
            Spacer()
            
            if let right {
                Text(right)
                    .foregroundStyle(tint == .fgray ? .fblack : (isPlaceholder ? .fwhite : .fblack))
                    .font(.system(.body, design: .rounded))
                
                if !isPlaceholder && foodItem != nil {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(tint == .fgray ? .fblack : (isPlaceholder ? .fwhite : .fblack))
                        .font(.system(size: 14, weight: .semibold))
                }
            }
        }
        .padding(12)
        .background(.fwhite.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.fwhite, lineWidth: 1)
        )
    }
}

#Preview {
    HomeView()
}
