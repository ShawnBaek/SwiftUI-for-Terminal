/// Builds a Control tree from a View hierarchy.
internal struct ViewGraph {

    /// Build a control tree from any View.
    static func buildControl<V: View>(from view: V, node: Node) -> Control {
        let control = Control()
        control.node = node

        // Install dynamic properties
        var mutableView = view
        node.installDynamicProperties(&mutableView)

        // Dispatch based on concrete view type
        if let text = mutableView as? Text {
            control.kind = .text(
                content: text.content,
                foregroundColor: text._foregroundColor,
                isBold: text._bold,
                isItalic: text._italic
            )
        } else if let spacer = mutableView as? Spacer {
            control.kind = .spacer(minLength: spacer.minLength)
        } else if let button = mutableView as? Button<Text> {
            control.kind = .button(label: button.label.content, action: button.action)
        } else if mutableView is EmptyView {
            control.kind = .container
        } else {
            // Composite view — evaluate body and recurse
            buildCompositeControl(from: mutableView, control: control, node: node)
        }

        return control
    }

    // MARK: - Composite view handling

    private static func buildCompositeControl<V: View>(from view: V, control: Control, node: Node) {
        // Check for layout containers first via type name (avoids opening existential)
        let typeName = String(describing: type(of: view))

        if typeName.hasPrefix("VStack") {
            buildVStackControl(from: view, control: control, node: node)
        } else if typeName.hasPrefix("HStack") {
            buildHStackControl(from: view, control: control, node: node)
        } else if typeName.hasPrefix("ZStack") {
            buildZStackControl(from: view, control: control, node: node)
        } else if typeName.hasPrefix("ModifiedContent") {
            buildModifiedControl(from: view, control: control, node: node)
        } else if typeName.hasPrefix("TupleView") {
            buildTupleViewControl(from: view, control: control, node: node)
        } else {
            // User-defined composite view — evaluate its body
            let childNode = Node(viewType: V.Body.self)
            node.addChild(childNode)
            childNode.application = node.application
            let childControl = buildControl(from: view.body, node: childNode)
            control.addChild(childControl)
            control.kind = .container
        }
    }

    private static func buildVStackControl<V: View>(from view: V, control: Control, node: Node) {
        let mirror = Mirror(reflecting: view)
        let alignment = mirror.descendant("alignment") as? HorizontalAlignment ?? .center
        let spacing = mirror.descendant("spacing") as? CGFloat?
        control.kind = .vstack(alignment: alignment, spacing: spacing ?? nil)

        if let content = mirror.descendant("content") {
            buildChildrenFromContent(content, into: control, node: node)
        }
    }

    private static func buildHStackControl<V: View>(from view: V, control: Control, node: Node) {
        let mirror = Mirror(reflecting: view)
        let alignment = mirror.descendant("alignment") as? VerticalAlignment ?? .center
        let spacing = mirror.descendant("spacing") as? CGFloat?
        control.kind = .hstack(alignment: alignment, spacing: spacing ?? nil)

        if let content = mirror.descendant("content") {
            buildChildrenFromContent(content, into: control, node: node)
        }
    }

    private static func buildZStackControl<V: View>(from view: V, control: Control, node: Node) {
        let mirror = Mirror(reflecting: view)
        let alignment = mirror.descendant("alignment") as? Alignment ?? .center
        control.kind = .zstack(alignment: alignment)

        if let content = mirror.descendant("content") {
            buildChildrenFromContent(content, into: control, node: node)
        }
    }

    private static func buildModifiedControl<V: View>(from view: V, control: Control, node: Node) {
        let mirror = Mirror(reflecting: view)

        // Extract the modifier
        if let modifier = mirror.descendant("modifier") {
            let modMirror = Mirror(reflecting: modifier)
            let modType = String(describing: type(of: modifier))

            if modType == "PaddingModifier" {
                let edges = modMirror.descendant("edges") as? Edge.Set ?? .all
                let length = modMirror.descendant("length") as? CGFloat?
                control.kind = .padding(edges: edges, length: length ?? nil)
            } else if modType == "FrameModifier" {
                let width = modMirror.descendant("width") as? CGFloat?
                let height = modMirror.descendant("height") as? CGFloat?
                let alignment = modMirror.descendant("alignment") as? Alignment ?? .center
                control.kind = .frame(width: width ?? nil, height: height ?? nil, alignment: alignment)
            } else if modType == "ForegroundColorModifier" || modType == "ForegroundStyleModifier" {
                // Pass-through: foreground color is applied at the Text level
                control.kind = .container
            } else if modType == "BackgroundModifier" {
                control.kind = .container
            } else if modType == "BoldModifier" || modType == "FontModifier" {
                control.kind = .container
            } else {
                control.kind = .container
            }
        } else {
            control.kind = .container
        }

        // Build the content child
        if let content = mirror.descendant("content") {
            buildChildrenFromContent(content, into: control, node: node)
        }
    }

    private static func buildTupleViewControl<V: View>(from view: V, control: Control, node: Node) {
        control.kind = .container
        let mirror = Mirror(reflecting: view)
        if let value = mirror.descendant("value") {
            let valueMirror = Mirror(reflecting: value)
            for child in valueMirror.children {
                buildChildrenFromContent(child.value, into: control, node: node)
            }
        }
    }

    // MARK: - Child content helpers

    private static func buildChildrenFromContent(_ content: Any, into parentControl: Control, node: Node) {
        if let view = content as? Text {
            let childNode = Node(viewType: Text.self)
            node.addChild(childNode)
            childNode.application = node.application
            let childControl = buildControl(from: view, node: childNode)
            parentControl.addChild(childControl)
        } else if let view = content as? EmptyView {
            let childNode = Node(viewType: EmptyView.self)
            node.addChild(childNode)
            childNode.application = node.application
            let childControl = buildControl(from: view, node: childNode)
            parentControl.addChild(childControl)
        } else if let view = content as? Spacer {
            let childNode = Node(viewType: Spacer.self)
            node.addChild(childNode)
            childNode.application = node.application
            let childControl = buildControl(from: view, node: childNode)
            parentControl.addChild(childControl)
        } else {
            // Try to use Mirror for TupleView content and other composites
            let mirror = Mirror(reflecting: content)
            let typeName = String(describing: type(of: content))

            if typeName.hasPrefix("TupleView") {
                if let value = mirror.descendant("value") {
                    let valueMirror = Mirror(reflecting: value)
                    for child in valueMirror.children {
                        buildChildrenFromContent(child.value, into: parentControl, node: node)
                    }
                }
            } else if mirror.children.isEmpty {
                // Leaf node we don't recognize — skip
            } else {
                // Try to treat it as a generic view through existential
                let childNode = Node(viewType: type(of: content))
                node.addChild(childNode)
                childNode.application = node.application
                let childControl = Control()
                childControl.kind = .container
                childControl.node = childNode

                // Check if it has a body we can evaluate via Mirror
                if let bodyValue = mirror.descendant("body") {
                    buildChildrenFromContent(bodyValue, into: childControl, node: childNode)
                }
                parentControl.addChild(childControl)
            }
        }
    }
}
