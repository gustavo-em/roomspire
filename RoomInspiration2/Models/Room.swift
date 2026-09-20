import Foundation

struct Room: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let price: Int
}
