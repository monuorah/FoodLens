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

    // Navigation state (all pushed so they get a back button)
    @State private var pushToSearch = false
    @State private var pushToScanFood = false
    @State private var pushToScanBarcode = false

    // Edit navigation
    @State private var editingMeal: LoggedMeal?

    // Data for today
    @State private var todaysMeals: [LoggedMeal] = []
    
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
                        .padding(.bottom)
                        .foregroundStyle(.fblack)
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.black)
                    
                    ScrollView {
                        VStack(spacing: 18) {
                            MealSectionCard(
                                title: "Breakfast",
                                tint: .yellow,
                                items: itemsForMeal("Breakfast"),
                                onDelete: handleDelete,
                                onEdit: handleEdit,
                                onTapAdd: { showLoggingSheet = true }
                            )
                            
                            MealSectionCard(
                                title: "Lunch",
                                tint: .blue,
                                items: itemsForMeal("Lunch"),
                                onDelete: handleDelete,
                                onEdit: handleEdit,
                                onTapAdd: { showLoggingSheet = true }
                            )
                            
                            MealSectionCard(
                                title: "Dinner",
                                tint: .brown,
                                items: itemsForMeal("Dinner"),
                                onDelete: handleDelete,
                                onEdit: handleEdit,
                                onTapAdd: { showLoggingSheet = true }
                            )
                            
                            MealSectionCard(
                                title: "Snacks",
                                tint: .fred,
                                items: itemsForMeal("Snacks"),
                                onDelete: handleDelete,
                                onEdit: handleEdit,
                                onTapAdd: { showLoggingSheet = true }
                            )
                            
                            Spacer(minLength: 10)
                        }
                        .padding(.bottom, 36)
                    }
                    
                    Button {
                        showLoggingSheet = true
                    } label: {
                        Label("Log Food", systemImage: "plus")
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.fblack)
                            .font(.system(.title2, design: .rounded))
                            .bold()
                            .padding(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.fblack.opacity(0.25), lineWidth: 1))
                            .background(Color.fblack.opacity(0.05))
                            .cornerRadius(12)
                    }
                    .sheet(isPresented: $showLoggingSheet) {
                        LoggingSheetView { action in
                            // Dismiss the sheet first, then navigate
                            showLoggingSheet = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                switch action {
                                case .search:
                                    pushToSearch = true
                                case .scanFood:
                                    pushToScanFood = true
                                case .scanBarcode:
                                    pushToScanBarcode = true
                                case .changeWeight:
                                    // handled inside the sheet
                                    break
                                }
                            }
                        }
                        .ignoresSafeArea()
                        .presentationDetents([.fraction(0.4), .medium])
                    }
                }
                .padding(35)
            }
            // Navigation destinations (all push so they get a back chevron)
            .navigationDestination(isPresented: $pushToSearch) {
                SearchView()
                    .navigationTitle("Search Food")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .navigationDestination(isPresented: $pushToScanFood) {
                ScanFoodView()
                    .navigationTitle("Scan Food")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .navigationDestination(isPresented: $pushToScanBarcode) {
                ScanBarcodeView()
                    .navigationTitle("Scan Barcode")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .navigationDestination(item: $editingMeal) { meal in
                EditMealView(meal: meal)
            }
            .onAppear {
                loadMeals()
            }
            // Refresh when returning from pushed flows
            .onChange(of: pushToSearch) { _, new in if !new { loadMeals() } }
            .onChange(of: pushToScanFood) { _, new in if !new { loadMeals() } }
            .onChange(of: pushToScanBarcode) { _, new in if !new { loadMeals() } }
            .onChange(of: editingMeal) { _, new in
                // when edit view pops (editingMeal becomes nil), reload
                if new == nil { loadMeals() }
            }
        }
    }

    // MARK: - Data helpers

    private func loadMeals() {
        todaysMeals = MealStorage.shared.mealsForToday()
    }

    private func normalizedMealType(_ raw: String) -> String {
        let s = raw.lowercased()
        if s.hasPrefix("break") { return "Breakfast" }
        if s.hasPrefix("lunch") { return "Lunch" }
        if s.hasPrefix("dinner") { return "Dinner" }
        if s.hasPrefix("snack") { return "Snacks" } // treat singular/plural the same
        return raw
    }

    private func itemsForMeal(_ title: String) -> [MealItem] {
        let meals = todaysMeals
            .filter { normalizedMealType($0.mealType) == title }
            .sorted { $0.date < $1.date }

        guard !meals.isEmpty else {
            return [] // show an empty-state card instead of a placeholder row
        }

        return meals.map { m in
            let servingsText: String = {
                let isInt = m.servings.rounded() == m.servings
                let amount = isInt ? String(Int(m.servings)) : String(format: "%.1f", m.servings)
                return "\(amount) " + (m.servings == 1 ? "serving" : "servings")
            }()
            return MealItem(
                left: m.foodItem.name,
                right: servingsText,
                foodItem: m.foodItem,
                loggedMealId: m.id,
                loggedMeal: m
            )
        }
    }

    private func handleDelete(_ id: UUID) {
        MealStorage.shared.deleteMeal(id: id)
        loadMeals()
    }

    private func handleEdit(_ meal: LoggedMeal) {
        editingMeal = meal
    }
}

// MARK: - Models for rows/items inside a meal card

struct MealItem: Identifiable {
    let id: UUID = UUID()
    let left: String
    let right: String?
    let foodItem: FoodItem?
    let loggedMealId: UUID?
    let loggedMeal: LoggedMeal?
}

// MARK: - UI Components (Neutral style + custom swipe)

private struct MealSectionCard: View {
    let title: String
    let tint: Color   // small accent dot
    var items: [MealItem]
    var onDelete: (UUID) -> Void
    var onEdit: (LoggedMeal) -> Void
    var onTapAdd: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            // Title row with tiny accent dot
            HStack(spacing: 8) {
                Circle()
                    .fill(tint)
                    .frame(width: 8, height: 8)
                Text(title)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.fblack)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)

            VStack(spacing: 10) {
                if items.isEmpty {
                    EmptyStateCard(onTapAdd: onTapAdd)
                } else {
                    ForEach(items) { item in
                        SwipeableMealRow(
                            item: item,
                            onDelete: {
                                if let id = item.loggedMealId { onDelete(id) }
                            },
                            onEdit: {
                                if let m = item.loggedMeal { onEdit(m) }
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 14)
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.fwhite)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.secondary.opacity(0.12), lineWidth: 1)
        )
        .padding(.horizontal, 6)
    }
}

private struct SwipeableMealRow: View {
    let item: MealItem
    var onDelete: () -> Void
    var onEdit: () -> Void

    @State private var offsetX: CGFloat = 0
    private let threshold: CGFloat = 80
    private let maxSwipe: CGFloat = 120

    private var isInteractive: Bool {
        item.foodItem != nil
    }

    var body: some View {
        if isInteractive {
            interactiveRow
        } else {
            staticRow
        }
    }

    // Row with gestures (right swipe = delete, left swipe = edit)
    private var interactiveRow: some View {
        ZStack {
            // Background actions
            HStack {
                // Right-swipe (leading) -> Delete (left side)
                HStack(spacing: 8) {
                    Image(systemName: "trash")
                    Text("Delete")
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.red)
                .clipShape(Capsule())
                .opacity(offsetX > 0 ? min(Double(abs(offsetX) / threshold), 1.0) : 0)
                .padding(.leading, 16)

                Spacer()

                // Left-swipe (trailing) -> Edit (right side)
                HStack(spacing: 8) {
                    Text("Edit")
                        .fontWeight(.semibold)
                    Image(systemName: "pencil")
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.fgreen)
                .clipShape(Capsule())
                .opacity(offsetX < 0 ? min(Double(abs(offsetX) / threshold), 1.0) : 0)
                .padding(.trailing, 16)
            }

            // Foreground row content
            rowContent(showHints: true)
                .offset(x: offsetX)
                .animation(.interactiveSpring(), value: offsetX)
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 10, coordinateSpace: .local)
                .onChanged { value in
                    var x = value.translation.width
                    x = min(max(x, -maxSwipe), maxSwipe)
                    offsetX = x
                }
                .onEnded { _ in
                    let x = offsetX
                    withAnimation(.spring()) {
                        offsetX = 0
                    }
                    if x >= threshold {
                        // Right swipe -> Delete (left)
                        onDelete()
                    } else if x <= -threshold {
                        // Left swipe -> Edit (right)
                        onEdit()
                    }
                }
        )
        // No tap action (card is not clickable)
    }

    // Non-interactive (placeholder) row: no gestures, no hints
    private var staticRow: some View {
        rowContent(showHints: false)
    }

    private func rowContent(showHints: Bool) -> some View {
        HStack(spacing: 10) {
            // Left red chevron to hint "swipe right to delete"
            Image(systemName: "chevron.left")
                .foregroundStyle(.red)
                .opacity(showHints ? 0.7 : 0.0)
                .frame(width: 14)

            Text(item.left)
                .foregroundStyle(.fblack)
                .font(.system(.body, design: .rounded))
                .lineLimit(1)

            Spacer()

            if let right = item.right {
                Text(right)
                    .foregroundStyle(.secondary)
                    .font(.system(.subheadline, design: .rounded))
                    .lineLimit(1)
            }

            // Right green chevron to hint "swipe left to edit"
            Image(systemName: "chevron.right")
                .foregroundStyle(.fgreen)
                .opacity(showHints ? 0.8 : 0.0)
                .frame(width: 14)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.fwhite)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
    }
}

private struct EmptyStateCard: View {
    var onTapAdd: () -> Void

    var body: some View {
        Button {
            onTapAdd()
        } label: {
            HStack {
                Text("Nothing here yet")
                    .foregroundStyle(.secondary)
                    .font(.system(.body, design: .rounded))
                Spacer()
                Text("Tap Log Food")
                    .foregroundStyle(.secondary)
                    .font(.system(.subheadline, design: .rounded))
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.secondary.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Nothing here yet. Tap to log food.")
    }
}

#Preview {
    HomeView()
}
