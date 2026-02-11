/// Internal modifier for background.
internal struct BackgroundModifier: ViewModifier {
    let color: Color

    func body(content: Content) -> some View {
        content
    }
}

extension View {
    /// Layers the given color behind this view.
    public func background(_ color: Color) -> some View {
        modifier(BackgroundModifier(color: color))
    }
}
