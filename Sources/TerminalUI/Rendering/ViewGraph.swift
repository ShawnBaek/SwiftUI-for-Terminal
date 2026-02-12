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

    // MARK: - Existential opening helper

    /// Open an `any View` existential and call `buildControl` with the concrete type.
    private static func openAndBuildControl(_ view: some View, node: Node) -> Control {
        return buildControl(from: view, node: node)
    }

    // MARK: - Composite view handling

    private static func buildCompositeControl<V: View>(from view: V, control: Control, node: Node) {
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
        } else if typeName.hasPrefix("ConditionalContent") {
            buildConditionalControl(from: view, control: control, node: node)
        } else if typeName.hasPrefix("Optional") {
            buildOptionalControl(from: view, control: control, node: node)
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
            } else {
                // ForegroundColor, Background, Bold, Font — pass-through containers
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

    private static func buildConditionalControl<V: View>(from view: V, control: Control, node: Node) {
        control.kind = .container
        let mirror = Mirror(reflecting: view)
        // ConditionalContent is an enum — extract the associated value
        for child in mirror.children {
            if let anyView = child.value as? any View {
                let childNode = Node(viewType: type(of: anyView))
                node.addChild(childNode)
                childNode.application = node.application
                let childControl = openAndBuildControl(anyView, node: childNode)
                control.addChild(childControl)
            }
        }
    }

    private static func buildOptionalControl<V: View>(from view: V, control: Control, node: Node) {
        control.kind = .container
        let mirror = Mirror(reflecting: view)
        for child in mirror.children {
            if let anyView = child.value as? any View {
                let childNode = Node(viewType: type(of: anyView))
                node.addChild(childNode)
                childNode.application = node.application
                let childControl = openAndBuildControl(anyView, node: childNode)
                control.addChild(childControl)
            }
        }
    }

    // MARK: - Child content helpers

    /// Resolve `Any` content (from Mirror reflection) into Control children.
    /// Uses existential opening via `any View` cast to handle all View types generically.
    private static func buildChildrenFromContent(_ content: Any, into parentControl: Control, node: Node) {
        let typeName = String(describing: type(of: content))

        // TupleView: decompose its value tuple into individual children (don't wrap as single child)
        if typeName.hasPrefix("TupleView") {
            let mirror = Mirror(reflecting: content)
            if let value = mirror.descendant("value") {
                let valueMirror = Mirror(reflecting: value)
                for child in valueMirror.children {
                    buildChildrenFromContent(child.value, into: parentControl, node: node)
                }
            }
            return
        }

        // All other View types: open existential and build recursively
        if let anyView = content as? any View {
            let childNode = Node(viewType: type(of: anyView))
            node.addChild(childNode)
            childNode.application = node.application
            let childControl = openAndBuildControl(anyView, node: childNode)
            parentControl.addChild(childControl)
            return
        }

        // Raw tuple (from Mirror of a tuple, not a TupleView) — decompose children
        let mirror = Mirror(reflecting: content)
        if mirror.displayStyle == .tuple {
            for child in mirror.children {
                buildChildrenFromContent(child.value, into: parentControl, node: node)
            }
        }
    }
}
