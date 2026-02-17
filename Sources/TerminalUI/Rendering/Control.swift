import NotcursesSwift

/// A layout and drawing primitive that bridges the view tree to terminal rendering.
/// Each Control corresponds to a Node and holds absolute position/size information.
internal class Control {
    var position: Position = .zero
    var size: Size = .zero
    var children: [Control] = []
    weak var node: Node?

    /// The kind of drawing this control performs.
    var kind: ControlKind = .container

    func addChild(_ child: Control) {
        children.append(child)
    }

    /// Compute the size this control needs, given a proposal.
    func sizeThatFits(_ proposed: ProposedSize) -> Size {
        switch kind {
        case .container:
            // Propagate layout to children so their positions get computed
            for child in children {
                let childSize = child.sizeThatFits(proposed)
                child.size = childSize
            }
            return Size(width: proposed.width ?? 0, height: proposed.height ?? 0)
        case .text(let content, _, _, _):
            return Size(width: content.count, height: 1)
        case .spacer(let minLength):
            // Spacers report their minimum length; actual expansion handled by stack
            let min = Int(minLength ?? 0)
            return Size(width: min, height: min)
        case .vstack(let alignment, let spacing):
            return layoutVStack(alignment: alignment, spacing: spacing, proposed: proposed)
        case .hstack(let alignment, let spacing):
            return layoutHStack(alignment: alignment, spacing: spacing, proposed: proposed)
        case .zstack:
            return layoutZStack(proposed: proposed)
        case .padding(let edges, let length):
            return layoutPadding(edges: edges, length: length, proposed: proposed)
        case .frame(let width, let height, _):
            let w = width.map { Int($0) } ?? (proposed.width ?? 0)
            let h = height.map { Int($0) } ?? (proposed.height ?? 0)
            return Size(width: w, height: h)
        case .button(let label, _):
            // Button renders as "[ label ]"
            return Size(width: label.count + 4, height: 1)
        }
    }

    // MARK: - Stack Layout Algorithms

    private func layoutVStack(alignment: HorizontalAlignment, spacing: CGFloat?, proposed: ProposedSize) -> Size {
        let gap = Int(spacing ?? 1)
        var totalHeight = 0
        var maxWidth = 0
        for (i, child) in children.enumerated() {
            let childSize = child.sizeThatFits(proposed)
            child.size = childSize
            child.position = Position(x: 0, y: totalHeight)
            totalHeight += childSize.height
            if i < children.count - 1 { totalHeight += gap }
            maxWidth = max(maxWidth, childSize.width)
        }
        // Apply horizontal alignment
        for child in children {
            switch alignment {
            case .center:
                child.position.x = (maxWidth - child.size.width) / 2
            case .trailing:
                child.position.x = maxWidth - child.size.width
            default: // .leading
                break
            }
        }
        return Size(width: maxWidth, height: totalHeight)
    }

    private func layoutHStack(alignment: VerticalAlignment, spacing: CGFloat?, proposed: ProposedSize) -> Size {
        let gap = Int(spacing ?? 1)
        var totalWidth = 0
        var maxHeight = 0

        // First pass: measure non-spacer children
        var spacerIndices: [Int] = []
        var fixedWidth = 0
        for (i, child) in children.enumerated() {
            if case .spacer = child.kind {
                spacerIndices.append(i)
            } else {
                let childSize = child.sizeThatFits(proposed)
                child.size = childSize
                fixedWidth += childSize.width
                maxHeight = max(maxHeight, childSize.height)
            }
        }

        // Distribute remaining space to spacers
        let totalGaps = max(0, children.count - 1) * gap
        let remainingWidth = max(0, (proposed.width ?? 80) - fixedWidth - totalGaps)
        let spacerWidth = spacerIndices.isEmpty ? 0 : remainingWidth / spacerIndices.count
        for i in spacerIndices {
            children[i].size = Size(width: spacerWidth, height: maxHeight)
        }

        // Second pass: assign positions
        for (i, child) in children.enumerated() {
            child.position = Position(x: totalWidth, y: 0)
            totalWidth += child.size.width
            if i < children.count - 1 { totalWidth += gap }
        }

        // Apply vertical alignment
        for child in children {
            switch alignment {
            case .center:
                child.position.y = (maxHeight - child.size.height) / 2
            case .bottom:
                child.position.y = maxHeight - child.size.height
            default: // .top
                break
            }
        }
        return Size(width: totalWidth, height: maxHeight)
    }

    private func layoutZStack(proposed: ProposedSize) -> Size {
        var maxWidth = 0
        var maxHeight = 0
        for child in children {
            let childSize = child.sizeThatFits(proposed)
            child.size = childSize
            child.position = .zero
            maxWidth = max(maxWidth, childSize.width)
            maxHeight = max(maxHeight, childSize.height)
        }
        return Size(width: maxWidth, height: maxHeight)
    }

    private func layoutPadding(edges: Edge.Set, length: CGFloat?, proposed: ProposedSize) -> Size {
        let pad = Int(length ?? 1)
        let topPad = edges.contains(.top) ? pad : 0
        let bottomPad = edges.contains(.bottom) ? pad : 0
        let leadingPad = edges.contains(.leading) ? pad : 0
        let trailingPad = edges.contains(.trailing) ? pad : 0

        let innerProposed = ProposedSize(
            width: proposed.width.map { $0 - leadingPad - trailingPad },
            height: proposed.height.map { $0 - topPad - bottomPad }
        )

        guard let child = children.first else {
            return Size(width: leadingPad + trailingPad, height: topPad + bottomPad)
        }

        let childSize = child.sizeThatFits(innerProposed)
        child.size = childSize
        child.position = Position(x: leadingPad, y: topPad)

        return Size(
            width: childSize.width + leadingPad + trailingPad,
            height: childSize.height + topPad + bottomPad
        )
    }
}

/// The kind of rendering a control performs.
internal enum ControlKind {
    case container
    case text(content: String, foregroundColor: Color?, isBold: Bool, isItalic: Bool)
    case spacer(minLength: CGFloat?)
    case vstack(alignment: HorizontalAlignment, spacing: CGFloat?)
    case hstack(alignment: VerticalAlignment, spacing: CGFloat?)
    case zstack(alignment: Alignment)
    case padding(edges: Edge.Set, length: CGFloat?)
    case frame(width: CGFloat?, height: CGFloat?, alignment: Alignment)
    case button(label: String, action: () -> Void)
}
