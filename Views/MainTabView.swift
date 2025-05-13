//
//  MainTabView.swift
//  BudgetXP
//
//  Created by Gavin Woodgate on 05/10/2025
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    // MARK: — Tabs
    enum Tab: Hashable { case budgets, transactions, analytics, settings, achievements, emergencyFund }

    @Environment(\.modelContext) private var modelContext
    @Query private var budgets: [Budget]
    @State private var selectedBudgetID: UUID?
    @State private var selectedTab: Tab = .budgets

    private var selectedBudget: Budget? {
        budgets.first { $0.id == selectedBudgetID }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Budget selector on relevant tabs
            if [.transactions, .analytics, .settings, .emergencyFund].contains(selectedTab) {
                if budgets.isEmpty {
                    Text("No Budgets Available")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    Picker("Select Budget", selection: $selectedBudgetID) {
                        ForEach(budgets) { b in
                            Text(b.name).tag(Optional(b.id))
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding([.horizontal, .top])
                    .background(Color(UIColor.systemGroupedBackground))
                }
            }

            // Main Tabs
            TabView(selection: $selectedTab) {
                budgetsTab
                    .tag(Tab.budgets)
                    .tabItem { Label("Budgets", systemImage: "list.bullet.rectangle") }

                transactionsTab
                    .tag(Tab.transactions)
                    .tabItem { Label("Transactions", systemImage: "square.and.pencil") }

                analyticsTab
                    .tag(Tab.analytics)
                    .tabItem { Label("Analytics", systemImage: "chart.pie.fill") }

                settingsTab
                    .tag(Tab.settings)
                    .tabItem { Label("Settings", systemImage: "gearshape.fill") }

                achievementsTab
                    .tag(Tab.achievements)
                    .tabItem { Label("Achievements", systemImage: "star.circle.fill") }

                emergencyFundTab
                    .tag(Tab.emergencyFund)
                    .tabItem { Label("Emergency Fund", systemImage: "lifepreserver") }
            }
        }
        .onAppear {
            if selectedBudgetID == nil {
                selectedBudgetID = budgets.first?.id
            }
        }
        .onChange(of: budgets) { new in
            if selectedBudgetID == nil {
                selectedBudgetID = new.first?.id
            }
        }
    }

    // MARK: — Budgets Tab
    private var budgetsTab: some View {
        NavigationView {
            List {
                ForEach(budgets) { budget in
                    let isSelected = budget.id == selectedBudgetID
                    HStack {
                        // Accent stripe
                        Rectangle()
                            .fill(isSelected ? Color.accentColor : .clear)
                            .frame(width: 4)

                        VStack(alignment: .leading) {
                            Text(budget.name)
                                .font(.headline)
                                .foregroundColor(isSelected ? .accentColor : .primary)
                            Text("Limit: \(budget.limit, specifier: "%.2f")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .listRowBackground(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
                    .onTapGesture {
                        withAnimation {
                            selectedBudgetID = budget.id
                            selectedTab = .transactions
                        }
                    }
                }
                .onDelete { idx in
                    withAnimation {
                        idx.map { budgets[$0] }.forEach(modelContext.delete)
                        if let first = idx.first,
                           budgets[first].id == selectedBudgetID {
                            selectedBudgetID = nil
                            selectedTab = .budgets
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Budgets")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // 1) Create new budget
                        let newBudget = Budget(
                            name: "New Budget",
                            limit: 500,
                            startDate: Date(),
                            endDate: Calendar.current.date(
                                byAdding: .month, value: 1, to: Date()
                            )!
                        )
                        // 2) Seed starter badges
                        let b1 = Badge(name: "First Budget", description: "Created your first budget", iconName: "flag.fill")
                        let b2 = Badge(name: "On Track", description: "Stay under budget this month", iconName: "checkmark.circle.fill")
                        let b3 = Badge(name: "Budget Veteran", description: "Completed 6 full budgets", iconName: "rosette")
                        let b4 = Badge(name: "Big Saver", description: "Saved over $500 in a single month", iconName: "trophy.fill")
                        let b5 = Badge(name: "Transaction Tracker", description: "Log 50 transactions", iconName: "list.bullet", goal: 50)
                        let b6 = Badge(name: "Data Diver", description: "Log spending for 90 days", iconName: "calendar", goal: 90)
                        newBudget.badges.append(contentsOf: [b1, b2, b3, b4, b5, b6])

                        // 3) Persist
                        modelContext.insert(newBudget)
                        [b1, b2, b3, b4, b5, b6].forEach { modelContext.insert($0) }

                        // 4) Select the new budget
                        selectedBudgetID = newBudget.id
                        selectedTab = .transactions
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
        }
    }

    // Transactions Tab
    @ViewBuilder private var transactionsTab: some View {
        if let budget = selectedBudget {
            TransactionsTabView(budget: budget)
                .navigationTitle("\(budget.name): Transactions")
        } else {
            noBudgetSelectedView
        }
    }

    // Analytics Tab
    @ViewBuilder private var analyticsTab: some View {
        if let budget = selectedBudget {
            AnalyticsTabView(budget: budget)
                .navigationTitle("\(budget.name): Analytics")
        } else {
            noBudgetSelectedView
        }
    }

    // Settings Tab
    @ViewBuilder private var settingsTab: some View {
        if let budget = selectedBudget {
            SettingsTabView(budget: budget)
                .navigationTitle("\(budget.name): Settings")
        } else {
            noBudgetSelectedView
        }
    }

    // Achievements Tab
    private var achievementsTab: some View {
        AchievementsTabView()
    }

    // Emergency Fund Tab
    private var emergencyFundTab: some View {
        EmergencyFundTabView()
    }

    // Placeholder when no budget
    private var noBudgetSelectedView: some View {
        Text("Please select a budget")
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Preview
#Preview {
    MainTabView()
        .modelContainer(
            for: [Budget.self, Transaction.self, BudgetCategory.self, Badge.self, AchievementsStore.self],
            inMemory: true
        )
}

