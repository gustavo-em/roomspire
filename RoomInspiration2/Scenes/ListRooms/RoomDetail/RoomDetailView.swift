import SwiftUI
import SFSafeSymbols

struct RoomDetailView : View {
    let room : Room

    @Environment(\.dismiss) private var dismiss

    var body : some View {
        VStack{
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemSymbol: .xmarkCircleFill).symbolRenderingMode(.monochrome)
                }.padding(20)
            }
            VStack (spacing: 20){
                Text(room.name)
                    .font(.largeTitle)
                    .bold()
                Text(room.price, format: .currency(code: "BRL"))
            }

        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()

    }
}

#Preview {
    RoomDetailView(room: Room(name: "Test", price: 50))
}
