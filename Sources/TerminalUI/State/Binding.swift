/// A property wrapper type that can read and write a value owned by a source of truth.
@propertyWrapper
@dynamicMemberLookup
public struct Binding<Value> {
    /// The getter for the bound value.
    public var get: () -> Value
    /// The setter for the bound value.
    public var set: (Value) -> Void

    /// Creates a binding with closures.
    public init(get: @escaping () -> Value, set: @escaping (Value) -> Void) {
        self.get = get
        self.set = set
    }

    /// The current value of the binding.
    public var wrappedValue: Value {
        get { get() }
        nonmutating set { set(newValue) }
    }

    /// The binding itself (for `$binding` syntax).
    public var projectedValue: Binding<Value> {
        self
    }

    /// Creates a binding with an immutable value.
    public static func constant(_ value: Value) -> Binding<Value> {
        Binding(get: { value }, set: { _ in })
    }

    /// Allows accessing member bindings.
    public subscript<Subject>(
        dynamicMember keyPath: WritableKeyPath<Value, Subject>
    ) -> Binding<Subject> {
        Binding<Subject>(
            get: { self.wrappedValue[keyPath: keyPath] },
            set: { self.wrappedValue[keyPath: keyPath] = $0 }
        )
    }
}
