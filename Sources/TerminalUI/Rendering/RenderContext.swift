import NotcursesSwift

/// Walks the Control tree and issues draw commands to the TerminalCanvas.
internal class RenderContext {
    let canvas: TerminalCanvas

    init(canvas: TerminalCanvas) {
        self.canvas = canvas
    }

    /// Render a control tree to the canvas.
    func render(control: Control, offset: Position = .zero) {
        let absX = offset.x + control.position.x
        let absY = offset.y + control.position.y
        let absPosition = Position(x: absX, y: absY)

        switch control.kind {
        case .text(let content, let foreground, let isBold, let isItalic):
            canvas.drawText(content, at: absPosition, foreground: foreground, bold: isBold, italic: isItalic)

        case .button(let label, _):
            // Render button as "[ label ]" with highlight
            let buttonText = "[ \(label) ]"
            canvas.drawText(buttonText, at: absPosition, foreground: .cyan, bold: true, italic: false)

        case .container, .vstack, .hstack, .zstack, .padding, .frame, .spacer:
            // Layout containers just recurse into children
            break
        }

        // Render children
        for child in control.children {
            render(control: child, offset: absPosition)
        }
    }
}
