//
//  Achievements.swift
//  BudgetXP
//
//  Created by Gavin Woodgate on 5/12/25.
//

import Foundation
import SwiftData

@Model
class AchievementsStore: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var xp: Int = 0
    var emergencyFundGoal: Double = 0
    var emergencyFundProgress: Double = 0
    @Relationship(deleteRule: .cascade) var badges: [Badge] = []

    init() {}

    var level: Int { xp / 500 + 1 }
}
