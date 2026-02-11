import NotcursesSwift

/// A drawing surface that wraps a NotcursesSwift Plane.
internal class TerminalCanvas {
    let plane: Plane

    init(plane: Plane) {
        self.plane = plane
    }

    /// Draw text at the given position.
    func drawText(_ text: String, at position: Position, foreground: Color?, bold: Bool, italic: Bool) {
        plane.moveCursor(y: position.y, x: position.x)

        // Apply styles
        var styles: UInt32 = 0
        if bold { styles |= TextAttribute.bold.rawValue }
        if italic { styles |= TextAttribute.italic.rawValue }
        if styles != 0 {
            plane.setStyles(styles)
        }

        // Apply color
        if let color = foreground {
            plane.setForeground(color.rgbColor)
        }

        plane.putString(text)

        // Reset styles
        if styles != 0 {
            plane.setStyles(0)
        }
    }

    /// Fill a rectangular region with a color.
    func fillRect(at position: Position, size: Size, color: Color) {
        plane.setBackground(color.rgbColor)
        for row in position.y..<(position.y + size.height) {
            plane.moveCursor(y: row, x: position.x)
            plane.putString(String(repeating: " ", count: size.width))
        }
        plane.setBackground(r: 0, g: 0, b: 0) // reset
    }

    /// Clear the entire canvas.
    func clear() {
        plane.erase()
    }
}
