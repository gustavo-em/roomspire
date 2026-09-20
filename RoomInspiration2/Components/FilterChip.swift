import SwiftUI

struct FilterChip: View {
    let title: String
    var systemImage: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color(.secondarySystemFill), in: Capsule())
            .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct ColorChip: View {
    let color: PhotoColor
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color.swatch)
                .frame(width: 28, height: 28)
                .overlay(Circle().strokeBorder(Color(.separator), lineWidth: 1))
                .overlay {
                    if isSelected {
                        Circle().strokeBorder(Color.accentColor, lineWidth: 3)
                    }
                }
                .padding(2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(color.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    HStack {
        FilterChip(title: "Living room", systemImage: "sofa", isSelected: true) {}
        FilterChip(title: "Kitchen", systemImage: "refrigerator", isSelected: false) {}
        ColorChip(color: .blue, isSelected: true) {}
        ColorChip(color: .white, isSelected: false) {}
    }
    .padding()
}
