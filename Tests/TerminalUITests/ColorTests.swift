import Testing
@testable import TerminalUI

@Suite("Color Tests")
struct ColorTests {

    @Test("All 17 named colors exist")
    func namedColorsExist() {
        let colors: [Color] = [
            .black, .white, .gray, .red, .orange, .yellow, .green,
            .mint, .teal, .cyan, .blue, .indigo, .purple, .pink,
            .brown, .clear, .primary, .secondary,
        ]
        #expect(colors.count == 18) // 17 unique + secondary (which equals gray)
    }

    @Test("Named colors have correct RGB values")
    func correctRGBValues() {
        #expect(Color.red.rgbColor.r == 255)
        #expect(Color.red.rgbColor.g == 59)
        #expect(Color.red.rgbColor.b == 48)

        #expect(Color.blue.rgbColor.r == 0)
        #expect(Color.blue.rgbColor.g == 122)
        #expect(Color.blue.rgbColor.b == 255)

        #expect(Color.black.rgbColor.r == 0)
        #expect(Color.black.rgbColor.g == 0)
        #expect(Color.black.rgbColor.b == 0)

        #expect(Color.white.rgbColor.r == 255)
        #expect(Color.white.rgbColor.g == 255)
        #expect(Color.white.rgbColor.b == 255)
    }

    @Test("Color conforms to ShapeStyle")
    func shapeStyleConformance() {
        let style: any ShapeStyle = Color.red
        #expect(style is Color)
    }

    @Test("Color is a View")
    func viewConformance() {
        let view: any View = Color.red
        #expect(view is Color)
    }

    @Test("RGB initializer")
    func rgbInit() {
        let color = Color(red: 1.0, green: 0.5, blue: 0.0)
        #expect(color.rgbColor.r == 255)
        #expect(color.rgbColor.g == 127)
        #expect(color.rgbColor.b == 0)
    }
}
