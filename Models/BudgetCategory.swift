//
//  BudgetCategory.swift
//  BudgetXP
//
//  Created by Gavin Woodgate on 4/16/25.
//

import Foundation
import SwiftData

@Model
class BudgetCategory: Identifiable {
    @Attribute(.unique) var id = UUID()
    var name: String
    var amount: Double

    init(name: String, amount: Double) {
        self.name = name
        self.amount = amount
    }
}
