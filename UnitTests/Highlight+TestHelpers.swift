//
//  Highlight+TestHelpers.swift
//  UnitTests
//
//  Created by Vinicius Leal on 28/10/2020.
//  Copyright © 2020 FolioReader. All rights reserved.
//

@testable import FolioReaderKit
import Foundation

extension Highlight {
    convenience init(
        bookId: String? = nil,
        content: String? = nil,
        contentPost: String? = nil,
        contentPre: String? = nil,
        date: Date? = nil,
        highlightId: String? = nil,
        page: Int = 0,
        type: Int = 0,
        startOffset: Int = -1,
        endOffset: Int = -1,
        noteForHighlight: String? = nil
    ) {
        self.init()
        self.bookId = bookId
        self.content = content
        self.contentPost = contentPost
        self.contentPre = contentPre
        self.date = date
        self.highlightId = highlightId
        self.page = page
        self.type = type
        self.startOffset = startOffset
        self.endOffset = endOffset
        self.noteForHighlight = noteForHighlight
    }
}
