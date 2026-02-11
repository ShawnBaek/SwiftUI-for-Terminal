/// A type that represents part of your app's user interface
/// and provides modifiers that you use to configure views.
public protocol View {
    /// The type of view representing the body of this view.
    associatedtype Body: View
    /// The content and behavior of the view.
    @ViewBuilder var body: Body { get }
}

// Never conforms to View as a terminal type for leaf views.
extension Never: View {
    public typealias Body = Never
    public var body: Never { fatalError() }
}
