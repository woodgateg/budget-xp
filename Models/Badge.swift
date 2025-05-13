//
//  Badge.swift
//  BudgetXP
//
//  Created by Gavin Woodgate on 4/30/25.
//
//

import Foundation
import SwiftData

@Model
class Badge: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var desc: String
    var iconName: String
    var achieved: Bool = false
    var achievedDate: Date?

    // — new for progress badges
    var progress: Double = 0
    var goal: Double = 0

    init(name: String,
         description: String,
         iconName: String,
         goal: Double = 0)
    {
        self.name = name
        self.desc = description
        self.iconName = iconName
        self.goal = goal
    }

    /// 0…1 fraction
    var progressFraction: Double {
        guard goal > 0 else { return 0 }
        return min(progress / goal, 1)
    }
}

