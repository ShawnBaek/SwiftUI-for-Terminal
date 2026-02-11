import NotcursesSwift

/// A font that you apply to text in a view.
public struct Font: Equatable, Sendable {
    /// The terminal text attribute to use for rendering.
    public let attribute: TextAttribute
    /// A label for identification.
    public let name: String

    init(name: String, attribute: TextAttribute) {
        self.name = name
        self.attribute = attribute
    }

    // MARK: - Text Styles (11 matching Apple's API)

    /// Large title style — rendered as bold in terminal.
    public static let largeTitle  = Font(name: "largeTitle", attribute: .bold)
    /// Title style — rendered as bold.
    public static let title       = Font(name: "title", attribute: .bold)
    /// Title 2 style — rendered as bold.
    public static let title2      = Font(name: "title2", attribute: .bold)
    /// Title 3 style — rendered as bold.
    public static let title3      = Font(name: "title3", attribute: .bold)
    /// Headline style — rendered as bold.
    public static let headline    = Font(name: "headline", attribute: .bold)
    /// Subheadline style — rendered normally.
    public static let subheadline = Font(name: "subheadline", attribute: TextAttribute(rawValue: 0))
    /// Body style — rendered normally.
    public static let body        = Font(name: "body", attribute: TextAttribute(rawValue: 0))
    /// Callout style — rendered normally.
    public static let callout     = Font(name: "callout", attribute: TextAttribute(rawValue: 0))
    /// Footnote style — rendered with dim/italic.
    public static let footnote    = Font(name: "footnote", attribute: .italic)
    /// Caption style — rendered with dim/italic.
    public static let caption     = Font(name: "caption", attribute: .italic)
    /// Caption 2 style — rendered with dim/italic.
    public static let caption2    = Font(name: "caption2", attribute: .italic)

    // MARK: - Modifiers

    /// Returns a bold version of this font.
    public func bold() -> Font {
        Font(name: name, attribute: attribute.union(.bold))
    }

    /// Returns an italic version of this font.
    public func italic() -> Font {
        Font(name: name, attribute: attribute.union(.italic))
    }

    /// Returns a monospaced version of this font (no-op in terminal, already monospaced).
    public func monospaced() -> Font {
        self
    }
}
