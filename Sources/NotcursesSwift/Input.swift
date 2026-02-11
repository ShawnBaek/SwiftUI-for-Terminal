import Cnotcurses

/// Represents a keyboard/mouse event from the terminal.
public struct InputEvent {
    /// The key that was pressed.
    public let key: KeyEvent
    /// Whether shift was held.
    public let shift: Bool
    /// Whether ctrl was held.
    public let ctrl: Bool
    /// Whether alt was held.
    public let alt: Bool
}

/// Known key events.
public enum KeyEvent: Equatable {
    case character(Character)
    case up
    case down
    case left
    case right
    case enter
    case escape
    case backspace
    case tab
    case resize
    case unknown(UInt32)
}

extension Terminal {
    /// Poll for input with an optional timeout in milliseconds.
    /// Returns nil if no input is available within the timeout.
    public func getInput(timeout: Int = -1) -> InputEvent? {
        var ni = ncinput()
        let result: UInt32
        if timeout >= 0 {
            var ts = timespec(tv_sec: timeout / 1000, tv_nsec: (timeout % 1000) * 1_000_000)
            result = notcurses_get(nc, &ts, &ni)
        } else {
            result = notcurses_get(nc, nil, &ni)
        }

        guard result != 0 else { return nil }

        let shift = ni.shift
        let ctrl = ni.ctrl
        let alt = ni.alt

        let key: KeyEvent
        switch result {
        case nckey_up():
            key = .up
        case nckey_down():
            key = .down
        case nckey_left():
            key = .left
        case nckey_right():
            key = .right
        case nckey_enter():
            key = .enter
        case nckey_esc():
            key = .escape
        case nckey_backspace():
            key = .backspace
        case nckey_tab():
            key = .tab
        case nckey_resize():
            key = .resize
        default:
            if let scalar = Unicode.Scalar(result) {
                key = .character(Character(scalar))
            } else {
                key = .unknown(result)
            }
        }

        return InputEvent(key: key, shift: shift, ctrl: ctrl, alt: alt)
    }
}
