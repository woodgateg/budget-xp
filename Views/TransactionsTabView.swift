//
//  TransactionsTabView.swift
//  BudgetXP
//
//  Created by Gavin Woodgate on 4/29/25.
//

import SwiftUICore
import SwiftUI

struct TransactionsTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var budget: Budget

    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var selectedCategory: String = ""
    @State private var date: Date = Date()

    var body: some View {
        NavigationView {
            Form {
                Section("Recent Transactions") {
                    ForEach(
                        budget.transactions
                            .sorted { $0.date > $1.date }
                            .prefix(5),
                        id: \.id
                    ) { t in
                        VStack(alignment: .leading) {
                            Text(t.trans_desc)
                            Text("$\(t.amount, specifier: "%.2f") · \(t.category)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }

                Section("Add Transaction") {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)

                    TextField("Description", text: $description)

                    Picker("Category", selection: $selectedCategory) {
                        ForEach(budget.categories.map(\.name), id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())

                    DatePicker("Date", selection: $date, displayedComponents: .date)

                    Button("Add") {
                        guard let amt = Double(amount),
                              !selectedCategory.isEmpty
                        else { return }

                        let tx = Transaction(
                            amount: amt,
                            date: date,
                            description: description,
                            category: selectedCategory
                        )
                        budget.transactions.append(tx)
                        modelContext.insert(tx)
                        amount = ""
                        description = ""
                        selectedCategory = ""
                        date = Date()
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    EmptyView()
                }
            }
        }
    }
}
