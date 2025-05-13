//
//  Budget.swift
//  BudgetXP
//
//  Created by Gavin Woodgate on 4/15/25.
//

import Foundation
import SwiftData

@Model
class Budget: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var limit: Double
    var startDate: Date
    var endDate: Date

    var xp: Int = 0
    var emergencyFundGoal: Double = 0
    var emergencyFundProgress: Double = 0

    @Relationship(deleteRule: .cascade) var transactions: [Transaction] = []
    @Relationship(deleteRule: .cascade) var categories: [BudgetCategory] = []
    @Relationship(deleteRule: .cascade) var badges: [Badge] = []

    init(name: String, limit: Double, startDate: Date, endDate: Date) {
        self.name = name
        self.limit = limit
        self.startDate = startDate
        self.endDate = endDate
    }

    var level: Int {
        xp / 500 + 1
    }

    var streakCount: Int {
        0
    }
}

