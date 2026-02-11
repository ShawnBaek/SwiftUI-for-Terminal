/// A control that initiates an action.
public struct Button<Label: View>: View {
    public var body: Never { fatalError() }

    internal let action: () -> Void
    internal let label: Label

    /// Creates a button that displays a custom label.
    public init(action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
    }
}

// Convenience initializer when Label is Text.
extension Button where Label == Text {
    /// Creates a button that generates its label from a string.
    public init(_ title: String, action: @escaping () -> Void) {
        self.action = action
        self.label = Text(title)
    }
}
