import Foundation

public struct CityNameValidator: Sendable {
    public enum Result: Equatable, Sendable {
        case valid
        case empty
        case containsDigits
        case containsDisallowedCharacters
    }

    public init() {}

    public func validate(_ name: String) -> Result {
        let normalized = normalize(name)
        guard !normalized.isEmpty else { return .empty }
        if normalized.contains(where: \.isNumber) {
            return .containsDigits
        }
        guard normalized.allSatisfy(Self.isAllowed) else {
            return .containsDisallowedCharacters
        }
        return .valid
    }

    /// Composes decomposed diacritics (pasted "ą" can arrive as "a" + U+0328), trims edge
    /// separators left over while typing ("Bielsko-") and collapses repeated spaces.
    public func normalize(_ name: String) -> String {
        name.precomposedStringWithCanonicalMapping
            .trimmingCharacters(in: Self.edgeSeparators)
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
    }

    private static let edgeSeparators = CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: "-"))

    private static func isAllowed(_ character: Character) -> Bool {
        character.isLetter || character == " " || character == "-"
    }
}
