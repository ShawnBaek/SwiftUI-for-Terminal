/// Internal modifier for bold text.
internal struct BoldModifier: ViewModifier {
    let isActive: Bool

    func body(content: Content) -> some View {
        content
    }
}

/// Internal modifier for font.
internal struct FontModifier: ViewModifier {
    let font: Font?

    func body(content: Content) -> some View {
        content
    }
}

extension View {
    /// Applies a bold font weight to the view.
    public func bold(_ isActive: Bool = true) -> some View {
        modifier(BoldModifier(isActive: isActive))
    }

    /// Sets the default font for text in this view.
    public func font(_ font: Font?) -> some View {
        modifier(FontModifier(font: font))
    }
}
