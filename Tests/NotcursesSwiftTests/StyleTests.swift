import Testing
@testable import NotcursesSwift

@Suite("RGBColor Tests")
struct RGBColorTests {
    @Test("Named colors have expected RGB values")
    func namedColors() {
        #expect(RGBColor.red == RGBColor(r: 255, g: 59, b: 48))
        #expect(RGBColor.green == RGBColor(r: 52, g: 199, b: 89))
        #expect(RGBColor.blue == RGBColor(r: 0, g: 122, b: 255))
        #expect(RGBColor.black == RGBColor(r: 0, g: 0, b: 0))
        #expect(RGBColor.white == RGBColor(r: 255, g: 255, b: 255))
    }

    @Test("RGB value combines correctly")
    func rgbCombination() {
        let color = RGBColor(r: 0xAB, g: 0xCD, b: 0xEF)
        #expect(color.rgb == 0xABCDEF)
    }
}
