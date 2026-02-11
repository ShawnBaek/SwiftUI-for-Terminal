/// A view created from a tuple of view values.
public struct TupleView<T>: View {
    public var value: T
    public var body: Never { fatalError() }

    public init(_ value: T) {
        self.value = value
    }
}
