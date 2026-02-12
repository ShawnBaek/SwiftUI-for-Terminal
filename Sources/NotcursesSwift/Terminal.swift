import Cnotcurses
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

/// Notcurses initialization flags.
public struct TerminalOptions: OptionSet, Sendable {
    public let rawValue: UInt64
    public init(rawValue: UInt64) { self.rawValue = rawValue }

    public static let noAlternateScreen = TerminalOptions(rawValue: UInt64(NCOPTION_NO_ALTERNATE_SCREEN))
    public static let suppressBanners   = TerminalOptions(rawValue: UInt64(NCOPTION_SUPPRESS_BANNERS))
}

/// Safe Swift wrapper around the notcurses terminal library.
public final class Terminal {
    let nc: OpaquePointer

    /// Initialize a notcurses context.
    /// - Parameter flags: Initialization flags (default: no alternate screen for debugging).
    public init(flags: UInt64 = UInt64(NCOPTION_NO_ALTERNATE_SCREEN)) throws {
        // Required for proper Unicode rendering
        setlocale(LC_ALL, "")

        var opts = notcurses_options()
        opts.flags = flags
        guard let nc = notcurses_init(&opts, stdout) else {
            throw TerminalError.initFailed
        }
        self.nc = nc
    }

    deinit {
        notcurses_stop(nc)
    }

    /// Render the current state to the terminal.
    @discardableResult
    public func render() throws -> Self {
        guard notcurses_render(nc) == 0 else {
            throw TerminalError.renderFailed
        }
        return self
    }

    /// The standard plane (root plane covering the entire terminal).
    public var standardPlane: Plane {
        let stdPlane = notcurses_stdplane(nc)!
        return Plane(plane: stdPlane, ownsPlane: false)
    }

    /// Terminal dimensions (rows, columns).
    public var dimensions: (rows: Int, cols: Int) {
        var rows: UInt32 = 0
        var cols: UInt32 = 0
        notcurses_stddim_yx(nc, &rows, &cols)
        return (Int(rows), Int(cols))
    }
}
