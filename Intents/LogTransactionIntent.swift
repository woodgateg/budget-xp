//import AppIntents
//import SwiftData
//
//struct LogTransactionIntent: AppIntent {
//    static var title: LocalizedStringResource = "Log Transaction"
//
//    @Parameter(title: "Amount")
//    var amount: Double
//
//    @Parameter(title: "Description")
//    var description: String
//
//    @Parameter(title: "Category")
//    var category: String
//
//    // Inject the shared ModelContainer
//    @Dependency(key: "ModelContainer")
//    private var container: ModelContainer
//
//    func perform() async throws -> some IntentResult {
//        // Create a ModelContext from the injected container
//        let context = ModelContext(container)
//
//        // Create & save the new transaction
//        let tx = Transaction(
//            amount: amount,
//            date: Date(),
//            description: description,
//            category: category
//        )
//        context.insert(tx)
//        try context.save()
//
//        // Build the dialog string with formatted amount
//        let formattedAmount = String(format: "%.2f", amount)
//        let message = "Logged $\(formattedAmount) in \(category)."
//        return .result(dialog: message)
//    }
//}
