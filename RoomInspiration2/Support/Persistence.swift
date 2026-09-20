import SwiftData

enum Persistence {
    static let container: ModelContainer = {
        do {
            return try ModelContainer(for: UserPhoto.self, FavoritePhoto.self)
        } catch {
            fatalError("Could not open the database: \(error)")
        }
    }()
}
