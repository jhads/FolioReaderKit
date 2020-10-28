//
//  FRHighlightInjector.swift
//  FolioReaderKit
//
//  Created by Vinicius Leal on 28/10/2020.
//  Copyright © 2020 FolioReader. All rights reserved.
//

import Foundation

// MARK: - Highlights

public class FRHighlightInjector {
    
    public init() {}
    
    public static func htmlContentWithInsertedHighlights(
        _ htmlContent: String,
        highlights: [Highlight]
    ) -> String {
        guard !highlights.isEmpty else { return htmlContent }
        
        var tempHtmlContent = htmlContent.htmlUnescape() as NSString
        
        for item in highlights {
            let style = HighlightStyle.classForStyle(item.type)
            
            let tag = generateTag(from: item, style: style)
            
            var locator = generateLocator(from: item)
                .replacingOccurrences(of: "“", with: "&#x201C;")
                .replacingOccurrences(of: "”", with: "&#x201D;")
            
            locator = Highlight.removeSentenceSpam(locator.htmlUnescape()) /// Fix for Highlights
            
            let range: NSRange = tempHtmlContent.localizedStandardRange(of: locator)
            
            if range.location != NSNotFound {
                let newRange = NSRange(location: range.location + item.contentPre.count, length: item.content.count)
                tempHtmlContent = tempHtmlContent.replacingCharacters(in: newRange, with: tag) as NSString
            } else {
                debugPrint("🔴🔴 Highlight range not found 🟢🟢")
            }
        }
        return tempHtmlContent as String
    }
    
    static func generateTag(from highlight: Highlight, style: String) -> String {
        var tag = ""
        if let _ = highlight.noteForHighlight {
            tag = "<highlight id=\"\(highlight.highlightId!)\" onclick=\"callHighlightWithNoteURL(this);\" class=\"\(style)\">\(highlight.content!)</highlight>"
        } else {
            tag = "<highlight id=\"\(highlight.highlightId!)\" onclick=\"callHighlightURL(this);\" class=\"\(style)\">\(highlight.content!)</highlight>"
        }
        return tag
    }
    
    static func generateLocator(from highlight: Highlight) -> String {
        highlight.contentPre + highlight.content + highlight.contentPost
    }
}
