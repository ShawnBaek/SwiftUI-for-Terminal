/// A part of an app's user interface with a life cycle managed by the system.
public protocol Scene {
    associatedtype Body: Scene
    @SceneBuilder var body: Body { get }
}

/// A scene builder.
@resultBuilder
public struct SceneBuilder {
    public static func buildBlock<Content: Scene>(_ content: Content) -> Content {
        content
    }
}
