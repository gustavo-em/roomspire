import Foundation

final class ListRoomsViewModel {

    private(set) var rooms: [Room] = [] {
        didSet { onChange?() }
    }

    var onChange: (() -> Void)?

    func load() {
        rooms = [
            Room(name: "Photo 1", price: 30),
            Room(name: "Photo 2", price: 10),
        ]
    }

    var numberOfRooms: Int {
        rooms.count
    }

    func room(at index: Int) -> Room {
        rooms[index]
    }
}
