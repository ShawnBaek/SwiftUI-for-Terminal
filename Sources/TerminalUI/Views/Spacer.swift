/// A flexible space that expands along the major axis of its
/// containing stack layout.
public struct Spacer: View {
    public var body: Never { fatalError() }

    /// The minimum length this spacer can be.
    public let minLength: CGFloat?

    /// Creates a spacer with a given minimum length.
    public init(minLength: CGFloat? = nil) {
        self.minLength = minLength
    }
}
