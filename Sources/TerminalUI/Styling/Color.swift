import NotcursesSwift

/// A representation of a color suitable for use in UI.
public struct Color: View, ShapeStyle, Equatable, Sendable {
    public var body: Never { fatalError() }

    /// The underlying RGB color for terminal rendering.
    public let rgbColor: RGBColor

    /// Creates a color from RGB components (0.0–1.0).
    public init(red: Double, green: Double, blue: Double, opacity: Double = 1.0) {
        self.rgbColor = RGBColor(
            r: UInt8(clamping: Int(red * 255)),
            g: UInt8(clamping: Int(green * 255)),
            b: UInt8(clamping: Int(blue * 255))
        )
    }

    /// Creates a color from an RGBColor.
    public init(_ rgbColor: RGBColor) {
        self.rgbColor = rgbColor
    }

    // MARK: - Standard Colors (17 named colors matching Apple's API)

    public static let black     = Color(RGBColor(r: 0, g: 0, b: 0))
    public static let white     = Color(RGBColor(r: 255, g: 255, b: 255))
    public static let gray      = Color(RGBColor(r: 142, g: 142, b: 147))
    public static let red       = Color(RGBColor(r: 255, g: 59, b: 48))
    public static let orange    = Color(RGBColor(r: 255, g: 149, b: 0))
    public static let yellow    = Color(RGBColor(r: 255, g: 204, b: 0))
    public static let green     = Color(RGBColor(r: 52, g: 199, b: 89))
    public static let mint      = Color(RGBColor(r: 0, g: 199, b: 190))
    public static let teal      = Color(RGBColor(r: 48, g: 176, b: 199))
    public static let cyan      = Color(RGBColor(r: 50, g: 173, b: 230))
    public static let blue      = Color(RGBColor(r: 0, g: 122, b: 255))
    public static let indigo    = Color(RGBColor(r: 88, g: 86, b: 214))
    public static let purple    = Color(RGBColor(r: 175, g: 82, b: 222))
    public static let pink      = Color(RGBColor(r: 255, g: 45, b: 85))
    public static let brown     = Color(RGBColor(r: 162, g: 132, b: 94))
    public static let clear     = Color(RGBColor(r: 0, g: 0, b: 0))  // Transparent (no-op in terminal)
    public static let primary   = Color(RGBColor(r: 255, g: 255, b: 255))
    public static let secondary = Color(RGBColor(r: 142, g: 142, b: 147))

    public static func == (lhs: Color, rhs: Color) -> Bool {
        lhs.rgbColor == rhs.rgbColor
    }
}
