/// A type that represents the structure and behavior of a terminal app.
public protocol App {
    associatedtype Body: Scene
    @SceneBuilder var body: Body { get }
    init()
}

extension App {
    /// The default entry point for the app.
    public static func main() {
        let app = Self()
        let body = app.body

        // Extract the root view from the scene
        let mirror = Mirror(reflecting: body)
        if let content = mirror.descendant("content") {
            // We need to run the application with this content
            let application = Application()
            do {
                // Use type erasure to run with the content view
                if let view = content as? any View {
                    try runApp(application: application, view: view)
                }
            } catch {
                print("Application error: \(error)")
            }
        }
    }
}

// Helper to open existential
private func runApp<V: View>(application: Application, view: V) throws {
    try application.run(view)
}
