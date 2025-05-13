import SwiftUI
import SwiftData

@main
struct BudgetXPApp: App {
    // Helper to get the on-disk store URL
    private static var storeURL: URL = {
        let appSupport = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
        return appSupport
            .appendingPathComponent("default.store")
    }()

    private static func makeContainer() -> ModelContainer {
        // Include all @Model types here
        let schema = Schema([
            Budget.self,
            Transaction.self,
            BudgetCategory.self,
            Badge.self,
            AchievementsStore.self
        ])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            // first try
            return try ModelContainer(
                for: schema,
                configurations: [config]
            )
        } catch {
            // on failure, delete the old store and try again
            print("Migration failed, removing old store: \(error)")
            try? FileManager.default.removeItem(at: storeURL)
            return try! ModelContainer(
                for: schema,
                configurations: [config]
            )
        }
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(BudgetXPApp.makeContainer())
    }
}
