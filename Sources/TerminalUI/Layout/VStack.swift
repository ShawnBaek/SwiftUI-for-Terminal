/// A view that arranges its children in a vertical line.
public struct VStack<Content: View>: View {
    public var body: Never { fatalError() }

    internal let alignment: HorizontalAlignment
    internal let spacing: CGFloat?
    internal let content: Content

    /// Creates a vertical stack with the given spacing and horizontal alignment.
    public init(
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }
}
