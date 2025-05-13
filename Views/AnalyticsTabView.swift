//
//  Analytics.swift
//  BudgetXP
//
//  Created by Gavin Woodgate on 4/29/25.
//

import SwiftUI
import Charts
import SwiftData


struct CategoryProgressRow: View {
    let category: BudgetCategory
    let spent: Double
    let progressColor: Color

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(category.name)
                Spacer()
                Text(String(format: "$%.2f / $%.2f", spent, category.amount))
            }
            ProgressView(value: spent, total: category.amount)
                .tint(progressColor)
        }
        .padding(.vertical, 4)
    }
}


struct AnalyticsTabView: View {
    @Bindable var budget: Budget

    private var breakdown: [String: Double] {
        Dictionary(grouping: budget.transactions, by: \.category)
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
    }

    private var adjustedCategories: [BudgetCategory] {
        let totalAllocated = budget.categories.reduce(0) { $0 + $1.amount }
        if totalAllocated < budget.limit {
            let misc = BudgetCategory(
                name: "Miscellaneous",
                amount: budget.limit - totalAllocated
            )
            return budget.categories + [misc]
        } else {
            return budget.categories
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 1) Pie chart of allocations
                    Text("Budget Breakdown")
                        .font(.headline)

                    Chart {
                        ForEach(adjustedCategories, id: \.name) { cat in
                            SectorMark(
                                angle: .value("Allocated", cat.amount),
                                innerRadius: .ratio(0.5),
                                angularInset: 1.5
                            )
                            .foregroundStyle(by: .value("Category", cat.name))
                        }
                    }
                    .frame(height: 300)

                    // 2) Progress bars for spending
                    Text("Spending by Category")
                        .font(.headline)

                    ForEach(adjustedCategories, id: \.name) { cat in
                        CategoryProgressRow(
                            category: cat,
                            spent: breakdown[cat.name] ?? 0,
                            progressColor: color(for: cat.name)
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Analytics")
        }
    }
}

struct AnalyticsTabView_Previews: PreviewProvider {
    static let sampleBudget: Budget = {
        let b = Budget(
            name: "Demo Budget",
            limit: 800,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())!
        )
        // Sample categories & transactions
        b.categories = [
            BudgetCategory(name: "Food", amount: 200),
            BudgetCategory(name: "Rent", amount: 400)
        ]
        b.transactions = [
            Transaction(amount: 50, date: Date(), description: "Groceries", category: "Food"),
            Transaction(amount: 100, date: Date(), description: "Dining Out", category: "Food"),
            Transaction(amount: 300, date: Date(), description: "April Rent", category: "Rent")
        ]
        return b
    }()

    static var previewContainer: ModelContainer = {
        let schema = Schema([Budget.self, BudgetCategory.self, Transaction.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: [config])
    }()

    static var previews: some View {
        AnalyticsTabView(budget: sampleBudget)
            .modelContainer(previewContainer)
    }
}

private func color(for categoryName: String) -> Color {
    // Use a hash to assign consistent, visually distinct colors
    let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink, .teal, .mint, .yellow, .indigo]
    let index = abs(categoryName.hashValue) % colors.count
    return colors[index]
}

