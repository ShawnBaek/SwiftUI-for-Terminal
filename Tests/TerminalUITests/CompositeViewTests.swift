import Testing
@testable import TerminalUI

@Suite("Composite View Tests")
struct CompositeViewTests {

    @Test("Custom view compiles with body")
    func customView() {
        struct MyView: View {
            var body: some View {
                Text("Hello from MyView")
            }
        }
        let view = MyView()
        // Should compile; body should be accessible
        _ = view.body
    }

    @Test("VStack with mixed children compiles")
    func vstackWithMixedChildren() {
        let _ = VStack {
            Text("Title").bold()
            Text("Subtitle")
            Spacer()
        }
    }

    @Test("Button with string label")
    func buttonStringLabel() {
        var tapped = false
        let button = Button("Tap Me") { tapped = true }
        button.action()
        #expect(tapped == true)
    }

    @Test("Button with custom label")
    func buttonCustomLabel() {
        let button = Button(action: {}) {
            Text("Custom")
        }
        _ = button.label
    }

    @Test("Nested stacks compile")
    func nestedStacks() {
        let _ = VStack {
            HStack {
                Text("Left")
                Spacer()
                Text("Right")
            }
            Text("Bottom")
        }
    }

    @Test("AnyView type erasure")
    func anyViewErasure() {
        let view = AnyView(Text("Hello"))
        #expect(view._viewType == Text.self)
    }

    @Test("Full demo view compiles — matches SwiftUI API")
    func fullDemoView() {
        struct ContentView: View {
            @State var count = 0
            var body: some View {
                VStack {
                    Text("Count: \(count)")
                        .foregroundColor(.green)
                        .bold()
                    Button("Increment") { count += 1 }
                }
                .padding(2)
            }
        }
        let _ = ContentView()
    }
}
