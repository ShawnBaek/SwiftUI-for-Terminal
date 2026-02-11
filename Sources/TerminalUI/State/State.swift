/// A property wrapper type that can read and write a value managed by the framework.
@propertyWrapper
public struct State<Value>: DynamicProperty {
    // Internal storage — actual state lives on the Node.
    // This class box allows the property wrapper to be mutated in a struct context.
    private final class Storage {
        var value: Value
        var node: Node?

        init(value: Value) {
            self.value = value
        }
    }

    private let storage: Storage

    /// Creates a state property with an initial value.
    public init(wrappedValue: Value) {
        self.storage = Storage(value: wrappedValue)
    }

    /// The current value of the state.
    public var wrappedValue: Value {
        get { storage.value }
        nonmutating set {
            storage.value = newValue
            storage.node?.setNeedsUpdate()
        }
    }

    /// A binding to the state value.
    public var projectedValue: Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 }
        )
    }

    /// Install this state on a node.
    internal func install(on node: Node) {
        storage.node = node
    }
}
