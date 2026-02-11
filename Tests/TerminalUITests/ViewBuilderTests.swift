import Testing
@testable import TerminalUI

@Suite("ViewBuilder Tests")
struct ViewBuilderTests {

    @Test("Single view passthrough")
    func singleView() {
        @ViewBuilder
        func build() -> some View {
            Text("Hello")
        }
        let view = build()
        // Should compile and produce a Text
        #expect(view is Text)
    }

    @Test("Two views produce TupleView")
    func twoViews() {
        @ViewBuilder
        func build() -> some View {
            Text("A")
            Text("B")
        }
        let view = build()
        let typeName = String(describing: type(of: view))
        #expect(typeName.contains("TupleView"))
    }

    @Test("Empty builder produces EmptyView")
    func emptyBuilder() {
        @ViewBuilder
        func build() -> some View {
            // empty
        }
        let view = build()
        #expect(view is EmptyView)
    }

    @Test("Conditional builds correctly")
    func conditionalBuild() {
        let showFirst = true
        @ViewBuilder
        func build() -> some View {
            if showFirst {
                Text("First")
            } else {
                Text("Second")
            }
        }
        let view = build()
        let typeName = String(describing: type(of: view))
        #expect(typeName.contains("ConditionalContent"))
    }
}
