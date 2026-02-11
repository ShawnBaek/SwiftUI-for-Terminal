/// Internal modifier for frame constraints.
internal struct FrameModifier: ViewModifier {
    let width: CGFloat?
    let height: CGFloat?
    let alignment: Alignment

    func body(content: Content) -> some View {
        content
    }
}

extension View {
    /// Positions this view within an invisible frame with the specified size.
    public func frame(
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        alignment: Alignment = .center
    ) -> some View {
        modifier(FrameModifier(width: width, height: height, alignment: alignment))
    }
}
