/// A size proposal for layout computation.
/// nil width/height means "use ideal size".
internal struct ProposedSize {
    var width: Int?
    var height: Int?

    static let unspecified = ProposedSize(width: nil, height: nil)

    static func fixed(width: Int, height: Int) -> ProposedSize {
        ProposedSize(width: width, height: height)
    }
}

/// A concrete size in terminal cells (rows x columns).
public struct Size: Equatable {
    public var width: Int
    public var height: Int

    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }

    public static let zero = Size(width: 0, height: 0)
}

/// A position in terminal cells.
public struct Position: Equatable {
    public var x: Int
    public var y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    public static let zero = Position(x: 0, y: 0)
}
