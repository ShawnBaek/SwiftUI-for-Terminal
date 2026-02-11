import Testing
@testable import TerminalUI

@Suite("EmptyView Tests")
struct EmptyViewTests {
    @Test("EmptyView can be created")
    func creation() {
        let view = EmptyView()
        _ = view // compiles and creates without error
    }
}
