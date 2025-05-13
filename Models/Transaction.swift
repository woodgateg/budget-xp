//
//  Transaction.swift
//  BudgetXP
//
//  Created by Gavin Woodgate on 4/15/25.
//

import Foundation
import SwiftData

@Model
class Transaction: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var amount: Double
    var date: Date
    var trans_desc: String
    var category: String

    init(amount: Double, date: Date, description: String, category: String) {
        self.amount = amount
        self.date = date
        self.trans_desc = description
        self.category = category
    }
}
