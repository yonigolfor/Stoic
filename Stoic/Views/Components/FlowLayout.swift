import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map(\.maxHeight).reduce(0, +) + max(0, CGFloat(rows.count - 1)) * spacing
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for item in row.items {
                let size = item.sizeThatFits(.unspecified)
                item.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                x += size.width + spacing
            }
            y += row.maxHeight + spacing
        }
    }

    private struct Row {
        var items: [LayoutSubview]
        var maxHeight: CGFloat
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [Row] = []
        var currentItems: [LayoutSubview] = []
        var currentWidth: CGFloat = 0
        var currentHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let neededWidth = currentItems.isEmpty ? size.width : currentWidth + spacing + size.width
            if neededWidth > maxWidth && !currentItems.isEmpty {
                rows.append(Row(items: currentItems, maxHeight: currentHeight))
                currentItems = [subview]
                currentWidth = size.width
                currentHeight = size.height
            } else {
                currentItems.append(subview)
                currentWidth = neededWidth
                currentHeight = max(currentHeight, size.height)
            }
        }
        if !currentItems.isEmpty {
            rows.append(Row(items: currentItems, maxHeight: currentHeight))
        }
        return rows
    }
}
