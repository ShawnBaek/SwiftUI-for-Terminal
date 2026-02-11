/// A view that arranges its children in a horizontal line.
public struct HStack<Content: View>: View {
    public var body: Never { fatalError() }

    internal let alignment: VerticalAlignment
    internal let spacing: CGFloat?
    internal let content: Content

    /// Creates a horizontal stack with the given spacing and vertical alignment.
    public init(
        alignment: VerticalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }
}
