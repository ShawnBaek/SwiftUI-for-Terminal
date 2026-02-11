import Cnotcurses

/// Safe Swift wrapper around an ncplane.
public final class Plane {
    let plane: OpaquePointer
    private let ownsPlane: Bool

    init(plane: OpaquePointer, ownsPlane: Bool) {
        self.plane = plane
        self.ownsPlane = ownsPlane
    }

    deinit {
        if ownsPlane {
            ncplane_destroy(plane)
        }
    }

    /// Create a child plane.
    public func createChild(rows: Int, cols: Int, y: Int = 0, x: Int = 0) throws -> Plane {
        var opts = ncplane_options()
        opts.y = Int32(y)
        opts.x = Int32(x)
        opts.rows = UInt32(rows)
        opts.cols = UInt32(cols)
        guard let child = ncplane_create(plane, &opts) else {
            throw TerminalError.planeFailed("Failed to create child plane")
        }
        return Plane(plane: child, ownsPlane: true)
    }

    /// Write a string at the current cursor position.
    @discardableResult
    public func putString(_ str: String, y: Int = -1, x: Int = -1) -> Int {
        if y >= 0 || x >= 0 {
            ncplane_cursor_move_yx(plane, Int32(max(y, 0)), Int32(max(x, 0)))
        }
        return Int(ncplane_putstr(plane, str))
    }

    /// Set the foreground color using RGB components.
    @discardableResult
    public func setForeground(r: UInt8, g: UInt8, b: UInt8) -> Self {
        let channel = UInt32(r) << 16 | UInt32(g) << 8 | UInt32(b)
        ncplane_set_fg_rgb(plane, channel)
        return self
    }

    /// Set the background color using RGB components.
    @discardableResult
    public func setBackground(r: UInt8, g: UInt8, b: UInt8) -> Self {
        let channel = UInt32(r) << 16 | UInt32(g) << 8 | UInt32(b)
        ncplane_set_bg_rgb(plane, channel)
        return self
    }

    /// Set foreground color using an RGBColor.
    @discardableResult
    public func setForeground(_ color: RGBColor) -> Self {
        setForeground(r: color.r, g: color.g, b: color.b)
    }

    /// Set background color using an RGBColor.
    @discardableResult
    public func setBackground(_ color: RGBColor) -> Self {
        setBackground(r: color.r, g: color.g, b: color.b)
    }

    /// Set text attributes (bold, italic, underline, etc.).
    @discardableResult
    public func setStyles(_ styles: UInt32) -> Self {
        ncplane_set_styles(plane, UInt32(styles))
        return self
    }

    /// Turn off all text attributes.
    @discardableResult
    public func stylesOff() -> Self {
        ncplane_off_styles(plane, 0xFFFF)
        return self
    }

    /// Erase the plane contents.
    public func erase() {
        ncplane_erase(plane)
    }

    /// Move cursor to the given position.
    public func moveCursor(y: Int, x: Int) {
        ncplane_cursor_move_yx(plane, Int32(y), Int32(x))
    }

    /// Plane dimensions (rows, columns).
    public var dimensions: (rows: Int, cols: Int) {
        var rows: UInt32 = 0
        var cols: UInt32 = 0
        ncplane_dim_yx(plane, &rows, &cols)
        return (Int(rows), Int(cols))
    }
}
