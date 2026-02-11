/// A node in the view tree that manages state and structural identity.
public final class Node {
    /// The view type this node represents.
    internal var viewType: Any.Type
    /// Child nodes.
    internal var children: [Node] = []
    /// Parent node (weak to avoid retain cycles).
    internal weak var parent: Node?
    /// The application for invalidation callbacks.
    internal weak var application: Application?
    /// Layout control associated with this node.
    internal var control: Control?

    init(viewType: Any.Type) {
        self.viewType = viewType
    }

    /// Mark this node as needing a re-render.
    func setNeedsUpdate() {
        application?.invalidateNode(self)
    }

    /// Install dynamic properties (like @State) on a view.
    func installDynamicProperties<V: View>(_ view: inout V) {
        let mirror = Mirror(reflecting: view)
        for child in mirror.children {
            if var state = child.value as? (any DynamicProperty) {
                state.update()
            }
            // Install State's node reference
            if let stateInstallable = child.value as? any StateInstallable {
                stateInstallable.install(on: self)
            }
        }
    }

    /// Add a child node.
    func addChild(_ child: Node) {
        child.parent = self
        children.append(child)
    }
}

/// Internal protocol for State to install itself on a Node.
internal protocol StateInstallable {
    func install(on node: Node)
}

extension State: StateInstallable {}
