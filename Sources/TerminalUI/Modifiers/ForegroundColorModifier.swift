/// Internal modifier for foreground color.
internal struct ForegroundColorModifier: ViewModifier {
    let color: Color?

    func body(content: Content) -> some View {
        content
    }
}

/// Internal modifier for foreground style.
internal struct ForegroundStyleModifier: ViewModifier {
    let style: Color

    func body(content: Content) -> some View {
        content
    }
}

extension View {
    /// Sets the color of the foreground elements displayed by this view.
    @available(*, deprecated, message: "Use foregroundStyle(_:) instead.")
    public func foregroundColor(_ color: Color?) -> some View {
        modifier(ForegroundColorModifier(color: color))
    }

    /// Sets the style of the foreground elements displayed by this view.
    public func foregroundStyle(_ style: Color) -> some View {
        modifier(ForegroundStyleModifier(style: style))
    }
}
