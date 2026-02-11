/// A view that displays nothing.
public struct EmptyView: View {
    public var body: Never { fatalError() }
    public init() {}
}
