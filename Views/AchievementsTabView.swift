//
//  AchievementsTabView.swift
//  BudgetXP
//
//  Created by Gavin Woodgate on 4/29/25.
//

import SwiftUI
import SwiftData

struct BadgeRow: View {
    let badge: Badge

    var body: some View {
        HStack {
            Image(systemName: badge.iconName)
                .font(.title2)
                .foregroundStyle(badge.achieved ? .yellow : .gray)
            VStack(alignment: .leading, spacing: 2) {
                Text(badge.name)
                    .font(.headline)
                Text(badge.desc)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: badge.achieved ? "checkmark.seal.fill" : "lock.fill")
                .foregroundStyle(badge.achieved ? .green : .gray)
        }
        .padding(.vertical, 4)
    }
}

struct AchievementsTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var stores: [AchievementsStore]

    private var store: AchievementsStore {
        if let existing = stores.first {
            return existing
        }
        let newStore = AchievementsStore()
        // seed badges if needed
        let initial: [Badge] = [
            Badge(name: "First Budget", description: "Created your first budget", iconName: "flag.fill"),
            Badge(name: "On Track", description: "Stay under budget this month", iconName: "checkmark.circle.fill"),
            Badge(name: "Budget Veteran", description: "Completed 6 full budgets", iconName: "rosette"),
            Badge(name: "Big Saver", description: "Saved over $500 in a single month", iconName: "trophy.fill"),
            Badge(name: "Transaction Tracker", description: "Log 50 transactions", iconName: "list.bullet", goal: 50),
            Badge(name: "Data Diver", description: "Log spending for 90 days", iconName: "calendar", goal: 90)
        ]
        initial.forEach {
            modelContext.insert($0)
            newStore.badges.append($0)
        }
        modelContext.insert(newStore)
        return newStore
    }

    var body: some View {
        NavigationView {
            List {
                // Level & XP
                Section(header: Text("🎓 Level & XP")) {
                    VStack(alignment: .leading) {
                        Text("Level \(store.level)")
                            .font(.title2).bold()
                        ProgressView(value: Double(store.xp % 500), total: 500) {
                            Text("\(store.xp) XP")
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Emergency Fund
                Section(header: Text("🛟 Emergency Fund")) {
                    ProgressView(value: store.emergencyFundProgress, total: store.emergencyFundGoal) {
                        Text(String(format: "$%.0f / $%.0f", store.emergencyFundProgress, store.emergencyFundGoal))
                    }
                    .padding(.vertical, 4)
                }

                // Badges
                Section(header: Text("🏅 Badges")) {
                    ForEach(store.badges) { badge in
                        BadgeRow(badge: badge)
                            .overlay(
                                Group {
                                    if badge.goal > 0 && !badge.achieved {
                                        ProgressView(value: badge.progressFraction)
                                            .padding(.top, 32)
                                    }
                                },
                                alignment: .bottomLeading
                            )
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Achievements")
        }
    }
}

struct AchievementsTabView_Previews: PreviewProvider {
    static var previews: some View {
        AchievementsTabView()
            .modelContainer(
                for: [AchievementsStore.self, Badge.self],
                inMemory: true
            )
    }
}
