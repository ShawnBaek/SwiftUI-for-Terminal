/// Errors that can occur during notcurses operations.
public enum TerminalError: Error, CustomStringConvertible {
    case initFailed
    case renderFailed
    case planeFailed(String)

    public var description: String {
        switch self {
        case .initFailed:
            return "Failed to initialize notcurses"
        case .renderFailed:
            return "Failed to render"
        case .planeFailed(let reason):
            return "Plane operation failed: \(reason)"
        }
    }
}
