import SwiftUI

struct FlowLayoutModel: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        return rows.size
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        
        for row in rows.rows {
            var x = bounds.minX
            
            for item in row.items {
                let subview = subviews[item.index]
                
                subview.place(
                    at: CGPoint(x: x, y: y),
                    proposal: ProposedViewSize(item.size)
                )
                
                x += item.size.width + spacing
            }
            
            y += row.maxHeight + spacing
        }
    }
    
    private func computeRows(
        proposal: ProposedViewSize,
        subviews: Subviews
    ) -> (rows: [Row], size: CGSize) {
        
        let maxWidth = proposal.width ?? .infinity
        
        var rows: [Row] = []
        var currentRow = Row()
        var totalHeight: CGFloat = 0
        var maxRowWidth: CGFloat = 0
        
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            
            if currentRow.width + size.width + spacing > maxWidth,
               !currentRow.items.isEmpty {
                
                rows.append(currentRow)
                totalHeight += currentRow.maxHeight + spacing
                maxRowWidth = max(maxRowWidth, currentRow.width)
                currentRow = Row()
            }
            
            currentRow.add(index: index, size: size, spacing: spacing)
        }
        
        if !currentRow.items.isEmpty {
            rows.append(currentRow)
            totalHeight += currentRow.maxHeight
            maxRowWidth = max(maxRowWidth, currentRow.width)
        }
        
        return (
            rows,
            CGSize(width: maxRowWidth, height: totalHeight)
        )
    }
    
    struct Row {
        var items: [Item] = []
        var width: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        mutating func add(index: Int, size: CGSize, spacing: CGFloat) {
            if !items.isEmpty {
                width += spacing
            }
            
            items.append(Item(index: index, size: size))
            width += size.width
            maxHeight = max(maxHeight, size.height)
        }
    }
    
    struct Item {
        let index: Int
        let size: CGSize
    }
}
