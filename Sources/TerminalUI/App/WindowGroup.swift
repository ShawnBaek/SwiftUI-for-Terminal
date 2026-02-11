/// A scene that presents a group of identically structured windows.
public struct WindowGroup<Content: View>: Scene {
    public var body: Never { fatalError() }

    internal let content: Content

    /// Creates a window group with a view builder.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
}

// Never conforms to Scene as a terminal type.
extension Never: Scene {
    // Body is already Never from the View conformance
}
