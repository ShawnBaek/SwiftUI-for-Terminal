/// An alignment in the horizontal axis.
public struct HorizontalAlignment: Equatable, Sendable {
    internal let id: String

    private init(_ id: String) { self.id = id }

    public static let leading  = HorizontalAlignment("leading")
    public static let center   = HorizontalAlignment("center")
    public static let trailing = HorizontalAlignment("trailing")
}

/// An alignment in the vertical axis.
public struct VerticalAlignment: Equatable, Sendable {
    internal let id: String

    private init(_ id: String) { self.id = id }

    public static let top            = VerticalAlignment("top")
    public static let center         = VerticalAlignment("center")
    public static let bottom         = VerticalAlignment("bottom")
    public static let firstTextBaseline  = VerticalAlignment("firstTextBaseline")
    public static let lastTextBaseline   = VerticalAlignment("lastTextBaseline")
}

/// An alignment in both axes.
public struct Alignment: Equatable, Sendable {
    public var horizontal: HorizontalAlignment
    public var vertical: VerticalAlignment

    public init(horizontal: HorizontalAlignment, vertical: VerticalAlignment) {
        self.horizontal = horizontal
        self.vertical = vertical
    }

    public static let topLeading     = Alignment(horizontal: .leading, vertical: .top)
    public static let top            = Alignment(horizontal: .center, vertical: .top)
    public static let topTrailing    = Alignment(horizontal: .trailing, vertical: .top)
    public static let leading        = Alignment(horizontal: .leading, vertical: .center)
    public static let center         = Alignment(horizontal: .center, vertical: .center)
    public static let trailing       = Alignment(horizontal: .trailing, vertical: .center)
    public static let bottomLeading  = Alignment(horizontal: .leading, vertical: .bottom)
    public static let bottom         = Alignment(horizontal: .center, vertical: .bottom)
    public static let bottomTrailing = Alignment(horizontal: .trailing, vertical: .bottom)
}
