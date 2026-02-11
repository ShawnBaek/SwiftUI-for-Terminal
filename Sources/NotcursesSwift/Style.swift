import Cnotcurses

/// An RGB color with 8-bit components.
public struct RGBColor: Equatable, Sendable {
    public let r: UInt8
    public let g: UInt8
    public let b: UInt8

    public init(r: UInt8, g: UInt8, b: UInt8) {
        self.r = r
        self.g = g
        self.b = b
    }

    /// The combined 24-bit RGB value.
    public var rgb: UInt32 {
        UInt32(r) << 16 | UInt32(g) << 8 | UInt32(b)
    }
}

// MARK: - Named Colors

extension RGBColor {
    public static let black   = RGBColor(r: 0, g: 0, b: 0)
    public static let white   = RGBColor(r: 255, g: 255, b: 255)
    public static let red     = RGBColor(r: 255, g: 59, b: 48)
    public static let green   = RGBColor(r: 52, g: 199, b: 89)
    public static let blue    = RGBColor(r: 0, g: 122, b: 255)
    public static let yellow  = RGBColor(r: 255, g: 204, b: 0)
    public static let orange  = RGBColor(r: 255, g: 149, b: 0)
    public static let purple  = RGBColor(r: 175, g: 82, b: 222)
    public static let pink    = RGBColor(r: 255, g: 45, b: 85)
    public static let cyan    = RGBColor(r: 50, g: 173, b: 230)
    public static let gray    = RGBColor(r: 142, g: 142, b: 147)
}

// MARK: - Text Attributes

/// Notcurses text style constants.
public struct TextAttribute: OptionSet, Sendable {
    public let rawValue: UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }

    public static let bold      = TextAttribute(rawValue: UInt32(NCSTYLE_BOLD))
    public static let italic    = TextAttribute(rawValue: UInt32(NCSTYLE_ITALIC))
    public static let underline = TextAttribute(rawValue: UInt32(NCSTYLE_UNDERLINE))
    public static let struck    = TextAttribute(rawValue: UInt32(NCSTYLE_STRUCK))
}
