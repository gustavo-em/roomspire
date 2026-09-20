import SwiftUI

struct EqualizedMasonryLayout: Layout {
    let aspectRatios: [CGFloat]
    var columns: Int = 2
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard let width = proposal.width, width.isFinite, width > 0 else { return .zero }
        let plan = makePlan(width: width, count: subviews.count)
        return CGSize(width: width, height: plan.height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let plan = makePlan(width: bounds.width, count: subviews.count)
        for (index, subview) in subviews.enumerated() {
            let frame = plan.frames[index].offsetBy(dx: bounds.minX, dy: bounds.minY)
            subview.place(at: frame.origin, proposal: ProposedViewSize(frame.size))
        }
    }

    func makePlan(width: CGFloat, count: Int) -> (frames: [CGRect], height: CGFloat) {
        let columnWidth = (width - spacing * CGFloat(columns - 1)) / CGFloat(columns)
        let capacity = Int((Double(count) / Double(columns)).rounded(.up))

        var columnItems = Array(repeating: [Int](), count: columns)
        var columnHeights = Array(repeating: CGFloat.zero, count: columns)
        for index in 0..<count {
            let open = columnHeights.indices.filter { columnItems[$0].count < capacity }
            let shortest = open.min { columnHeights[$0] < columnHeights[$1] } ?? 0
            let gap = columnItems[shortest].isEmpty ? 0 : spacing
            columnItems[shortest].append(index)
            columnHeights[shortest] += naturalHeight(of: index, columnWidth: columnWidth) + gap
        }

        let target = columnHeights.max() ?? 0
        let balanced = Set(columnItems.map(\.count)).count == 1
        var frames = Array(repeating: CGRect.zero, count: count)
        for (column, indices) in columnItems.enumerated() where !indices.isEmpty {
            let gaps = spacing * CGFloat(indices.count - 1)
            let photosHeight = columnHeights[column] - gaps
            let factor = balanced && photosHeight > 0 ? (target - gaps) / photosHeight : 1
            let x = CGFloat(column) * (columnWidth + spacing)
            var y: CGFloat = 0
            for index in indices {
                let height = naturalHeight(of: index, columnWidth: columnWidth) * factor
                frames[index] = CGRect(x: x, y: y, width: columnWidth, height: height)
                y += height + spacing
            }
        }
        return (frames, target)
    }

    private func naturalHeight(of index: Int, columnWidth: CGFloat) -> CGFloat {
        let ratio = aspectRatios.indices.contains(index) ? aspectRatios[index] : 1
        return columnWidth / max(ratio, 0.01)
    }
}
