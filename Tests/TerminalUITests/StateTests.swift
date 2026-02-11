import Testing
@testable import TerminalUI

@Suite("State Tests")
struct StateTests {

    @Test("State initial value")
    func initialValue() {
        @State var count = 0
        #expect(count == 0)
    }

    @Test("State mutation")
    func mutation() {
        @State var count = 0
        count = 5
        #expect(count == 5)
    }

    @Test("Binding get/set")
    func bindingGetSet() {
        var value = 42
        let binding = Binding(
            get: { value },
            set: { value = $0 }
        )
        #expect(binding.wrappedValue == 42)
        binding.wrappedValue = 100
        #expect(value == 100)
    }

    @Test("Binding constant is read-only")
    func bindingConstant() {
        let binding = Binding.constant(99)
        #expect(binding.wrappedValue == 99)
        binding.wrappedValue = 0 // should be a no-op
        #expect(binding.wrappedValue == 99)
    }

    @Test("State projectedValue produces Binding")
    func projectedValue() {
        @State var count = 10
        let binding: Binding<Int> = $count
        #expect(binding.wrappedValue == 10)
    }
}
