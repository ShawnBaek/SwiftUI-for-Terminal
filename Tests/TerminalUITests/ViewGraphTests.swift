import Testing
@testable import TerminalUI

@Suite("ViewGraph Tests")
struct ViewGraphTests {

    @Test("Builds Text control")
    func textControl() {
        let node = Node(viewType: Text.self)
        let control = ViewGraph.buildControl(from: Text("Hello"), node: node)
        if case .text(let content, _, _, _) = control.kind {
            #expect(content == "Hello")
        } else {
            Issue.record("Expected .text control, got \(control.kind)")
        }
    }

    @Test("Builds Spacer control")
    func spacerControl() {
        let node = Node(viewType: Spacer.self)
        let control = ViewGraph.buildControl(from: Spacer(minLength: 3), node: node)
        if case .spacer(let minLength) = control.kind {
            #expect(minLength == 3)
        } else {
            Issue.record("Expected .spacer control")
        }
    }

    @Test("Builds Button control")
    func buttonControl() {
        let node = Node(viewType: Button<Text>.self)
        let control = ViewGraph.buildControl(from: Button("Tap") {}, node: node)
        if case .button(let label, _) = control.kind {
            #expect(label == "Tap")
        } else {
            Issue.record("Expected .button control")
        }
    }

    @Test("Builds VStack with children")
    func vstackControl() {
        let view = VStack {
            Text("A")
            Text("B")
        }
        let node = Node(viewType: type(of: view))
        let control = ViewGraph.buildControl(from: view, node: node)
        if case .vstack = control.kind {
            #expect(control.children.count == 2)
            if case .text(let content, _, _, _) = control.children[0].kind {
                #expect(content == "A")
            }
            if case .text(let content, _, _, _) = control.children[1].kind {
                #expect(content == "B")
            }
        } else {
            Issue.record("Expected .vstack control, got \(control.kind)")
        }
    }

    @Test("Builds HStack with children")
    func hstackControl() {
        let view = HStack {
            Text("Left")
            Spacer()
            Text("Right")
        }
        let node = Node(viewType: type(of: view))
        let control = ViewGraph.buildControl(from: view, node: node)
        if case .hstack = control.kind {
            #expect(control.children.count == 3)
        } else {
            Issue.record("Expected .hstack control")
        }
    }

    @Test("Builds nested VStack > HStack")
    func nestedStacks() {
        let view = VStack {
            Text("Title")
            HStack {
                Text("A")
                Text("B")
            }
        }
        let node = Node(viewType: type(of: view))
        let control = ViewGraph.buildControl(from: view, node: node)
        if case .vstack = control.kind {
            #expect(control.children.count == 2)
            // First child: Text
            if case .text(let content, _, _, _) = control.children[0].kind {
                #expect(content == "Title")
            }
            // Second child: HStack
            if case .hstack = control.children[1].kind {
                #expect(control.children[1].children.count == 2)
            } else {
                Issue.record("Expected nested .hstack, got \(control.children[1].kind)")
            }
        } else {
            Issue.record("Expected .vstack control")
        }
    }

    @Test("Builds padding modifier wrapping content")
    func paddingModifier() {
        let view = Text("Hello").padding(2)
        let node = Node(viewType: type(of: view))
        let control = ViewGraph.buildControl(from: view, node: node)
        if case .padding(_, let length) = control.kind {
            #expect(length == 2)
            #expect(control.children.count == 1)
            if case .text(let content, _, _, _) = control.children[0].kind {
                #expect(content == "Hello")
            }
        } else {
            Issue.record("Expected .padding control, got \(control.kind)")
        }
    }

    @Test("Builds user-defined composite view")
    func compositeView() {
        struct MyView: View {
            var body: some View {
                VStack {
                    Text("Custom")
                    Text("View")
                }
            }
        }
        let node = Node(viewType: MyView.self)
        let control = ViewGraph.buildControl(from: MyView(), node: node)
        // MyView is a container wrapping a VStack
        #expect(control.children.count == 1)
        if case .vstack = control.children[0].kind {
            #expect(control.children[0].children.count == 2)
        } else {
            Issue.record("Expected .vstack inside composite, got \(control.children[0].kind)")
        }
    }

    @Test("Full ContentView-like structure builds correctly")
    func fullContentView() {
        struct DemoView: View {
            var body: some View {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Title").bold().foregroundColor(.cyan)
                    Text("Count: 0").foregroundColor(.green)
                    HStack(spacing: 2) {
                        Button("Inc") {}
                        Button("Reset") {}
                    }
                    Spacer(minLength: 1)
                    Text("Footer").italic()
                }
                .padding(2)
            }
        }
        let node = Node(viewType: DemoView.self)
        let control = ViewGraph.buildControl(from: DemoView(), node: node)
        // DemoView > container > ModifiedContent(padding) > VStack > children
        #expect(control.children.count >= 1, "DemoView should have at least 1 child")

        // Walk to the VStack
        func findVStack(in ctrl: Control) -> Control? {
            if case .vstack = ctrl.kind { return ctrl }
            for child in ctrl.children {
                if let found = findVStack(in: child) { return found }
            }
            return nil
        }

        if let vstack = findVStack(in: control) {
            #expect(vstack.children.count == 5, "VStack should have 5 children (3 texts + hstack + spacer)")
        } else {
            Issue.record("Could not find VStack in control tree")
        }
    }

    @Test("Layout sizes Text correctly")
    func textLayout() {
        let node = Node(viewType: Text.self)
        let control = ViewGraph.buildControl(from: Text("Hello"), node: node)
        let size = control.sizeThatFits(ProposedSize.fixed(width: 80, height: 24))
        #expect(size.width == 5)
        #expect(size.height == 1)
    }

    @Test("Layout sizes VStack correctly")
    func vstackLayout() {
        let view = VStack(spacing: 0) {
            Text("AB")
            Text("CDE")
        }
        let node = Node(viewType: type(of: view))
        let control = ViewGraph.buildControl(from: view, node: node)
        let size = control.sizeThatFits(ProposedSize.fixed(width: 80, height: 24))
        #expect(size.width == 3, "VStack width = max child width")
        #expect(size.height == 2, "VStack height = sum of children (no spacing)")
    }
}
