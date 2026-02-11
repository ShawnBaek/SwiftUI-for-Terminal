/// A type-erased view.
public struct AnyView: View {
    public var body: Never { fatalError() }

    internal let _storage: Any
    internal let _viewType: Any.Type

    /// Creates a type-erased view.
    public init<V: View>(_ view: V) {
        self._storage = view
        self._viewType = type(of: view)
    }
}
