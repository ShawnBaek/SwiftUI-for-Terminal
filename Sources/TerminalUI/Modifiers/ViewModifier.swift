/// A modifier that you apply to a view to produce a different version of the original value.
public protocol ViewModifier {
    associatedtype Body: View
    @ViewBuilder func body(content: Content) -> Body
    typealias Content = _ViewModifierContent<Self>
}

/// A placeholder view representing the content a modifier is applied to.
public struct _ViewModifierContent<Modifier: ViewModifier>: View {
    public var body: Never { fatalError() }
}

/// A view with a modifier applied.
public struct ModifiedContent<Content: View, Modifier: ViewModifier>: View {
    public var body: Never { fatalError() }

    public let content: Content
    public let modifier: Modifier

    public init(content: Content, modifier: Modifier) {
        self.content = content
        self.modifier = modifier
    }
}

// Extension on View for .modifier()
extension View {
    /// Applies a modifier to a view.
    public func modifier<T: ViewModifier>(_ modifier: T) -> ModifiedContent<Self, T> {
        ModifiedContent(content: self, modifier: modifier)
    }
}
