/// A view that displays one or more lines of read-only text.
public struct Text: View, Equatable {
    public var body: Never { fatalError() }

    internal let content: String
    internal var _foregroundColor: Color?
    internal var _font: Font?
    internal var _bold: Bool = false
    internal var _italic: Bool = false
    internal var _underline: Bool = false
    internal var _strikethrough: Bool = false

    /// Creates a text view that displays a string.
    public init(verbatim content: String) {
        self.content = content
    }

    /// Creates a text view that displays a string.
    public init<S: StringProtocol>(_ content: S) {
        self.content = String(content)
    }

    // MARK: - Text-specific modifiers (return Text, not some View)

    /// Sets the color of the text.
    public func foregroundColor(_ color: Color?) -> Text {
        var copy = self
        copy._foregroundColor = color
        return copy
    }

    /// Sets the font of the text.
    public func font(_ font: Font?) -> Text {
        var copy = self
        copy._font = font
        return copy
    }

    /// Applies a bold font weight to the text.
    public func bold(_ isActive: Bool = true) -> Text {
        var copy = self
        copy._bold = isActive
        return copy
    }

    /// Applies italics to the text.
    public func italic(_ isActive: Bool = true) -> Text {
        var copy = self
        copy._italic = isActive
        return copy
    }

    /// Applies an underline to the text.
    public func underline(_ isActive: Bool = true) -> Text {
        var copy = self
        copy._underline = isActive
        return copy
    }

    /// Applies a strikethrough to the text.
    public func strikethrough(_ isActive: Bool = true) -> Text {
        var copy = self
        copy._strikethrough = isActive
        return copy
    }

    public static func == (lhs: Text, rhs: Text) -> Bool {
        lhs.content == rhs.content
    }
}

// MARK: - String interpolation support

extension Text {
    /// Creates a text view from a string interpolation.
    public init(_ value: Int) {
        self.content = "\(value)"
    }
}
