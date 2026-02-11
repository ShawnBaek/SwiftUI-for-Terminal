/// A stored variable that updates an external property of a view.
///
/// The framework calls `update()` before evaluating a view's body
/// to install state storage on the node.
public protocol DynamicProperty {
    /// Called before evaluating the body to install/update storage.
    mutating func update()
}

extension DynamicProperty {
    public mutating func update() {}
}
