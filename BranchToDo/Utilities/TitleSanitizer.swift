//
//  InputSanitizer.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/19/25.
//

import Foundation

struct TitleSanitizer {
    
    private static let maxCharacterLimit = 2000
    
    static func sanitize(_ input: String) -> String {
        var sanitizedText = input
        
        // 1. Limit Input Size
        if sanitizedText.count > maxCharacterLimit {
            sanitizedText = String(sanitizedText.prefix(maxCharacterLimit))
        }
        
        // 4. Trim Whitespace
        sanitizedText = sanitizedText.trimmingCharacters(in: .whitespaces)
        
        // 2. Remove Non-Printable & Control Characters
        // .controlCharacters includes things like null, escape, and delete
        // .newlines can be kept or removed based on your UI needs
        sanitizedText = sanitizedText.filter { isPrintable($0) }
        
        // 3. Remove Unsafe Links
        sanitizedText = stripUnsafeLinks(from: sanitizedText)
        return sanitizedText
    }
    
    static func stripUnsafeLinks(from text: String) -> String {
        // 1. Create a detector specifically for Links
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return text
        }
        
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        let matches = detector.matches(in: text, options: [], range: range)
        
        var sanitizedText = text
        
        // 2. Iterate backwards through matches to avoid range shifting as we delete text
        for match in matches.reversed() {
            guard let url = match.url else { continue }
            
            // 3. Define what is "Safe" (Standard Web)
            let safeSchemes = ["http", "https"]
            let scheme = url.scheme?.lowercased() ?? ""
            
            // 4. If the scheme is NOT in our safe list (e.g., javascript:, file:, tel:), remove it
            if !safeSchemes.contains(scheme) {
                if let targetRange = Range(match.range, in: sanitizedText) {
                    sanitizedText.removeSubrange(targetRange)
                }
            }
        }
        
        // Clean up any double spaces left behind by the removal
        return sanitizedText.replacingOccurrences(of: "  ", with: " ").trimmingCharacters(in: .whitespaces)
    }
    
    // Helper function to check if a character is printable
    private static func isPrintable(_ character: Character) -> Bool {
        let scalarValues = character.unicodeScalars
        return scalarValues.allSatisfy { scalar in
            // Exclude control characters (ASCII 0-31 and 127)
            !CharacterSet.controlCharacters.contains(scalar)
        }
    }
}
