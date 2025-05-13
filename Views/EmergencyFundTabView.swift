//
//  EmergencyFundTabView.swift
//  BudgetXP
//
//  Created by Gavin Woodgate on 05/10/2025
//

import SwiftUI
import SwiftData

struct EmergencyFundTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var stores: [AchievementsStore]
    @State private var store: AchievementsStore?

    // Dynamic bindings once store is loaded
    private var goalBinding: Binding<Double> {
        Binding(
            get: { store?.emergencyFundGoal ?? 0 },
            set: { if let s = store { s.emergencyFundGoal = $0 } }
        )
    }

    private var progressBinding: Binding<Double> {
        Binding(
            get: { store?.emergencyFundProgress ?? 0 },
            set: { if let s = store { s.emergencyFundProgress = $0 } }
        )
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("🛟 Emergency Fund")) {
                    // Progress bar (avoid zero total)
                    ProgressView(
                        value: store?.emergencyFundProgress ?? 0,
                        total: max(store?.emergencyFundGoal ?? 1, 1)
                    ) {
                        Text(
                            store != nil
                            ? String(
                                format: "$%.0f / $%.0f",
                                store!.emergencyFundProgress,
                                store!.emergencyFundGoal
                              )
                            : "$0 / $0"
                        )
                    }
                    .padding(.vertical, 8)

                    // Goal input
                    HStack {
                        Text("Goal")
                        Spacer()
                        TextField(
                            "Amount",
                            value: goalBinding,
                            format: .currency(code: Locale.current.currencyCode ?? "USD")
                        )
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    }

                    // Progress input
                    HStack {
                        Text("Saved")
                        Spacer()
                        TextField(
                            "Amount",
                            value: progressBinding,
                            format: .currency(code: Locale.current.currencyCode ?? "USD")
                        )
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("Emergency Fund")
            .onAppear {
                // Initialize store once
                if store == nil {
                    if let existing = stores.first {
                        store = existing
                    } else {
                        let newStore = AchievementsStore()
                        modelContext.insert(newStore)
                        store = newStore
                    }
                }
            }
        }
    }
}

struct EmergencyFundTabView_Previews: PreviewProvider {
    static var previews: some View {
        EmergencyFundTabView()
            .modelContainer(
                for: [AchievementsStore.self, Badge.self],
                inMemory: true
            )
    }
}
