import Testing
@testable import TerminalUI

@Suite("Font Tests")
struct FontTests {

    @Test("All 11 text styles exist")
    func textStylesExist() {
        let styles: [Font] = [
            .largeTitle, .title, .title2, .title3,
            .headline, .subheadline, .body, .callout,
            .footnote, .caption, .caption2,
        ]
        #expect(styles.count == 11)
    }

    @Test("Headline is bold")
    func headlineIsBold() {
        #expect(Font.headline.attribute.contains(.bold))
    }

    @Test("Body has no special attributes")
    func bodyIsPlain() {
        #expect(Font.body.attribute.rawValue == 0)
    }

    @Test("Bold modifier adds bold")
    func boldModifier() {
        let font = Font.body.bold()
        #expect(font.attribute.contains(.bold))
    }

    @Test("Italic modifier adds italic")
    func italicModifier() {
        let font = Font.body.italic()
        #expect(font.attribute.contains(.italic))
    }

    @Test("Chained modifiers combine attributes")
    func chainedModifiers() {
        let font = Font.body.bold().italic()
        #expect(font.attribute.contains(.bold))
        #expect(font.attribute.contains(.italic))
    }
}
