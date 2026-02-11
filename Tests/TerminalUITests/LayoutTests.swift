import Testing
@testable import TerminalUI

@Suite("Layout Tests")
struct LayoutTests {

    @Test("VStack can be created with alignment and spacing")
    func vstackCreation() {
        let stack = VStack(alignment: .leading, spacing: 2) {
            Text("A")
            Text("B")
        }
        #expect(stack.alignment == .leading)
        #expect(stack.spacing == 2)
    }

    @Test("HStack can be created with alignment and spacing")
    func hstackCreation() {
        let stack = HStack(alignment: .top, spacing: 3) {
            Text("A")
            Text("B")
        }
        #expect(stack.alignment == .top)
        #expect(stack.spacing == 3)
    }

    @Test("ZStack can be created with alignment")
    func zstackCreation() {
        let stack = ZStack(alignment: .topLeading) {
            Text("A")
            Text("B")
        }
        #expect(stack.alignment == .topLeading)
    }

    @Test("Spacer has default nil minLength")
    func spacerDefault() {
        let spacer = Spacer()
        #expect(spacer.minLength == nil)
    }

    @Test("Spacer with custom minLength")
    func spacerCustom() {
        let spacer = Spacer(minLength: 5)
        #expect(spacer.minLength == 5)
    }

    @Test("Alignment all 9 values")
    func alignmentValues() {
        let alignments: [Alignment] = [
            .topLeading, .top, .topTrailing,
            .leading, .center, .trailing,
            .bottomLeading, .bottom, .bottomTrailing,
        ]
        #expect(alignments.count == 9)
        #expect(Alignment.center.horizontal == .center)
        #expect(Alignment.center.vertical == .center)
    }

    @Test("Edge.Set operations")
    func edgeSet() {
        let all: Edge.Set = .all
        #expect(all.contains(.top))
        #expect(all.contains(.leading))
        #expect(all.contains(.bottom))
        #expect(all.contains(.trailing))

        let horizontal: Edge.Set = .horizontal
        #expect(horizontal.contains(.leading))
        #expect(horizontal.contains(.trailing))
        #expect(!horizontal.contains(.top))
    }
}
