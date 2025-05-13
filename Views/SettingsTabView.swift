

import SwiftUI
import SwiftData

struct CategoryRow: View {
    let category: BudgetCategory

    var body: some View {
        HStack {
            Text(category.name)
            Spacer()
            Text(verbatim: String(format: "$%.2f", category.amount))
        }
    }
}

struct SettingsTabView: View {
    @Bindable var budget: Budget
    @Environment(\.modelContext) private var modelContext

    @State private var newCategoryName: String = ""
    @State private var newCategoryAmount: String = ""

    var body: some View {
        NavigationView {
            Form {
                // MARK: – Budget Info (now editable)
                Section("Budget Info") {
                    TextField("Budget Name", text: $budget.name)
                    TextField("Limit", value: $budget.limit, format: .number)
                        .keyboardType(.decimalPad)
                }

                // MARK: – Timeframe
                Section("Budget Timeframe") {
                    DatePicker("Start Date",
                               selection: $budget.startDate,
                               displayedComponents: .date)
                    DatePicker("End Date",
                               selection: $budget.endDate,
                               displayedComponents: .date)
                }

                // MARK: – Categories
                Section("Categories") {
                    ForEach(budget.categories, id: \.name) { category in
                        CategoryRow(category: category)
                    }

                    // Add a new category
                    HStack {
                        TextField("Name", text: $newCategoryName)
                        TextField("Amount", text: $newCategoryAmount)
                            .keyboardType(.decimalPad)
                        Button {
                            guard
                                let amt = Double(newCategoryAmount),
                                !newCategoryName.isEmpty
                            else { return }

                            let cat = BudgetCategory(
                                name: newCategoryName,
                                amount: amt
                            )
                            budget.categories.append(cat)
                            modelContext.insert(cat)

                            newCategoryName = ""
                            newCategoryAmount = ""
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: — Preview

struct SettingsTabView_Previews: PreviewProvider {
    static let sampleBudget: Budget = {
        let b = Budget(
            name: "Demo Budget",
            limit: 1000,
            startDate: Date(),
            endDate: Calendar.current.date(
                byAdding: .month, value: 1, to: Date()
            )!
        )
        b.categories.append(BudgetCategory(name: "Food", amount: 200))
        return b
    }()

    static var previewContainer: ModelContainer = {
        let schema = Schema([Budget.self, BudgetCategory.self, Transaction.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        return try! ModelContainer(
            for: schema,
            configurations: [config]
        )
    }()

    static var previews: some View {
        SettingsTabView(budget: sampleBudget)
            .modelContainer(previewContainer)
    }
}
