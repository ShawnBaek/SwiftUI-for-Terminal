/// Internal modifier for padding.
internal struct PaddingModifier: ViewModifier {
    let edges: Edge.Set
    let length: CGFloat?

    func body(content: Content) -> some View {
        content
    }
}

extension View {
    /// Adds padding to specific edges.
    public func padding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
        modifier(PaddingModifier(edges: edges, length: length))
    }

    /// Adds equal padding on all edges.
    public func padding(_ length: CGFloat) -> some View {
        modifier(PaddingModifier(edges: .all, length: length))
    }
}
