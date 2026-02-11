import Testing
@testable import TerminalUI

@Suite("Text Tests")
struct TextTests {

    @Test("Text creation with string")
    func creation() {
        let text = Text("Hello")
        #expect(text.content == "Hello")
    }

    @Test("Text creation with verbatim")
    func verbatimCreation() {
        let text = Text(verbatim: "Hello")
        #expect(text.content == "Hello")
    }

    @Test("Modifier chaining preserves content")
    func modifierChaining() {
        let text = Text("Hello")
            .bold()
            .italic()
            .foregroundColor(.red)
        #expect(text.content == "Hello")
        #expect(text._bold == true)
        #expect(text._italic == true)
        #expect(text._foregroundColor == .red)
    }

    @Test("Bold modifier")
    func boldModifier() {
        let text = Text("Test").bold()
        #expect(text._bold == true)
    }

    @Test("Font modifier")
    func fontModifier() {
        let text = Text("Test").font(.headline)
        #expect(text._font == .headline)
    }
}
