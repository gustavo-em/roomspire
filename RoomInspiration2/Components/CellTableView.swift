import SwiftUI

struct CellTableView: View {
    var room: Room
    var body: some View {
        HStack {
            Text(room.name)
            Spacer()
            Text("\(room.price)")
        }
        .padding(.horizontal)
    }
}
