import Testing
@testable import TerminalUI

@Suite("Modifier Tests")
struct ModifierTests {

    @Test("Padding modifier compiles and chains")
    func paddingModifier() {
        let view = Text("Hello").padding()
        let typeName = String(describing: type(of: view))
        #expect(typeName.contains("ModifiedContent"))
    }

    @Test("Padding with specific value")
    func paddingWithValue() {
        let view = Text("Hello").padding(2)
        let typeName = String(describing: type(of: view))
        #expect(typeName.contains("ModifiedContent"))
    }

    @Test("Frame modifier compiles")
    func frameModifier() {
        let view = Text("Hello").frame(width: 10, height: 5)
        let typeName = String(describing: type(of: view))
        #expect(typeName.contains("ModifiedContent"))
    }

    @Test("ForegroundColor modifier compiles — Text returns Text")
    func foregroundColorModifier() {
        // Text.foregroundColor returns Text (text-specific modifier)
        let textView = Text("Hello").foregroundColor(.red)
        #expect(textView is Text)
        #expect(textView._foregroundColor == .red)
    }

    @Test("ForegroundStyle modifier compiles")
    func foregroundStyleModifier() {
        let view = Text("Hello").foregroundStyle(.blue)
        let typeName = String(describing: type(of: view))
        #expect(typeName.contains("ModifiedContent"))
    }

    @Test("Background modifier compiles")
    func backgroundModifier() {
        let view = Text("Hello").background(.green)
        let typeName = String(describing: type(of: view))
        #expect(typeName.contains("ModifiedContent"))
    }

    @Test("Bold modifier compiles")
    func boldModifier() {
        let view = Text("Hello").bold()
        // Note: Text.bold() returns Text, not ModifiedContent
        #expect(view is Text)
    }

    @Test("Chained modifiers compile")
    func chainedModifiers() {
        let _ = Text("Hello")
            .padding(2)
            .frame(width: 20)
            .foregroundStyle(.cyan)
            .background(.black)
        // Compiles = pass
    }
}
