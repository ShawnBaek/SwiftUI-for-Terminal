/// An enumeration of the edges of a rectangle.
public enum Edge: Int8, CaseIterable, Sendable {
    case top
    case leading
    case bottom
    case trailing

    /// A set of edges.
    public struct Set: OptionSet, Sendable {
        public let rawValue: Int8
        public init(rawValue: Int8) { self.rawValue = rawValue }

        public static let top      = Set(rawValue: 1 << 0)
        public static let leading  = Set(rawValue: 1 << 1)
        public static let bottom   = Set(rawValue: 1 << 2)
        public static let trailing = Set(rawValue: 1 << 3)

        public static let all: Set = [.top, .leading, .bottom, .trailing]
        public static let horizontal: Set = [.leading, .trailing]
        public static let vertical: Set = [.top, .bottom]

        /// Creates an Edge.Set from a single Edge.
        public init(_ edge: Edge) {
            switch edge {
            case .top:      self = .top
            case .leading:  self = .leading
            case .bottom:   self = .bottom
            case .trailing: self = .trailing
            }
        }
    }
}
