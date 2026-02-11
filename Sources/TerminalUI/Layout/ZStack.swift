/// A view that overlays its children, aligning them in both axes.
public struct ZStack<Content: View>: View {
    public var body: Never { fatalError() }

    internal let alignment: Alignment
    internal let content: Content

    /// Creates a ZStack with the given alignment.
    public init(
        alignment: Alignment = .center,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.content = content()
    }
}
