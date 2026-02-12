import NotcursesSwift
import Foundation

/// The main application run loop that drives the terminal UI.
public final class Application {
    private var terminal: Terminal?
    private var canvas: TerminalCanvas?
    private var rootNode: Node?
    private var rootControl: Control?
    private var needsUpdate = true
    private var isRunning = false

    // Focused button index for keyboard navigation
    private var focusedButtonIndex = 0
    private var buttonActions: [() -> Void] = []

    public init() {}

    /// Run an application with the given root view.
    public func run<V: View>(_ rootView: V) throws {
        let terminal = try Terminal(flags: TerminalOptions.suppressBanners.rawValue)
        self.terminal = terminal

        let plane = terminal.standardPlane
        let canvas = TerminalCanvas(plane: plane)
        self.canvas = canvas

        isRunning = true

        // Build initial view tree
        let rootNode = Node(viewType: V.self)
        rootNode.application = self
        self.rootNode = rootNode

        // Initial render
        updateAndRender(rootView, terminal: terminal, canvas: canvas, rootNode: rootNode)

        // Main run loop
        while isRunning {
            if let event = terminal.getInput(timeout: 50) {
                switch event.key {
                case .character("q"), .escape:
                    isRunning = false
                case .up:
                    focusedButtonIndex = max(0, focusedButtonIndex - 1)
                    needsUpdate = true
                case .down:
                    focusedButtonIndex += 1
                    needsUpdate = true
                case .enter:
                    if focusedButtonIndex < buttonActions.count {
                        buttonActions[focusedButtonIndex]()
                    }
                case .resize:
                    needsUpdate = true
                default:
                    break
                }
            }

            if needsUpdate {
                rootNode.children.removeAll()
                updateAndRender(rootView, terminal: terminal, canvas: canvas, rootNode: rootNode)
                needsUpdate = false
            }
        }
    }

    private func updateAndRender<V: View>(_ rootView: V, terminal: Terminal, canvas: TerminalCanvas, rootNode: Node) {
        // Build the control tree
        let control = ViewGraph.buildControl(from: rootView, node: rootNode)
        self.rootControl = control

        // Layout
        let dims = terminal.dimensions
        let proposed = ProposedSize.fixed(width: dims.cols, height: dims.rows)
        control.size = control.sizeThatFits(proposed)

        // Collect button actions
        buttonActions = collectButtonActions(from: control)

        // Draw
        canvas.clear()
        let renderer = RenderContext(canvas: canvas)
        renderer.render(control: control)
        _ = try? terminal.render()
    }

    /// Invalidate a node (triggers re-render on next loop iteration).
    func invalidateNode(_ node: Node) {
        needsUpdate = true
    }

    /// Stop the application.
    public func stop() {
        isRunning = false
    }

    // Collect all button actions from the control tree.
    private func collectButtonActions(from control: Control) -> [() -> Void] {
        var actions: [() -> Void] = []
        if case .button(_, let action) = control.kind {
            actions.append(action)
        }
        for child in control.children {
            actions.append(contentsOf: collectButtonActions(from: child))
        }
        return actions
    }
}
