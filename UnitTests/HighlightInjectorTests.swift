//
//  HighlightInjectorTests.swift
//  UnitTests
//
//  Created by Vinicius Leal on 28/10/2020.
//  Copyright © 2020 FolioReader. All rights reserved.
//

@testable import FolioReaderKit
import XCTest

class HighlightInjectorTests: XCTestCase {
    
    func test_insertHighlights_correctlyInsertsHighlightsWithSmallString() {
        let initialString = "This is a highlight example to perform test."
        let highlight = makeHighlight()
        
        let modifiedString = HighlightInjector.htmlContentWithInsertedHighlights(
            initialString,
            highlights: [highlight])
        
        XCTAssertEqual(modifiedString.numberOfHighlights(), 1)
        XCTAssertNotEqual(initialString, modifiedString)
    }
    
    func test_insertHighlights_correctlyInsertsHighlights() {
        let initialString: String = .htmlString
        let highlights = makeHighlights()
        
        let modifiedString = HighlightInjector.htmlContentWithInsertedHighlights(
            initialString,
            highlights: highlights)
        
        XCTAssertEqual(modifiedString.numberOfHighlights(), highlights.count)
        XCTAssertNotEqual(initialString, modifiedString)
    }
    
    func test_generateTag_insertsCorrectTag() {
        let highlight1 = makeHighlight()
        let tag1 = HighlightInjector.generateTag(from: highlight1, style: "any style")
        
        XCTAssertTrue(tag1.contains(highlight1.highlightId))
        XCTAssertTrue(tag1.contains(highlight1.content))
        XCTAssertTrue(tag1.contains("callHighlightURL(this)"))
        
        let highlight2 = makeHighlight("any note")
        let tag2 = HighlightInjector.generateTag(from: highlight2, style: "any style")
        
        XCTAssertTrue(tag2.contains(highlight1.highlightId))
        XCTAssertTrue(tag2.contains(highlight1.content))
        XCTAssertTrue(tag2.contains("callHighlightWithNoteURL(this)"))
    }
    
    func test_generateLocator_producesCorrectLocator() {
        let highlight = makeHighlight()
        let locator = HighlightInjector.generateLocator(from: highlight)
        
        XCTAssertTrue(locator.contains(highlight.content))
        XCTAssertTrue(locator.contains(highlight.contentPre))
        XCTAssertTrue(locator.contains(highlight.contentPost))
    }
    
    private func makeHighlight(_ note: String? = nil) -> Highlight {
        Highlight(bookId: "Writing On Art Robert",
                  content: "highlight example",
                  contentPost: " to perform",
                  contentPre: "is a ",
                  date: Date(),
                  highlightId: "59E713AC-1523-9340-0D47-6BC53EBCD443",
                  page: 4,
                  type: 0,
                  startOffset: 0,
                  endOffset: 51,
                  noteForHighlight: note)
    }
    
    private func makeHighlights() -> [Highlight] {
        [
            Highlight(bookId: "Writing On Art Robert",
                      content: "I served my apprenticeship in art criticism writing letters. This practice began in notes to a distant relative my maternal great aunt living in New York City who, starting in 1968 when I was eighteen, gave me the grand tour of the Manhattan art world. These missives recounting what I had seen and thought were my way of thanking a person who “had everything”  for showing me around. Also, she <i>was </i>everything I was not stylish, moneyed, and worldly.",
                      contentPost: " Indeed, she knew or had known",
                      contentPre: "",
                      date: Date(),
                      highlightId: "59E713AC-1523-9340-0D47-6BC53EBCD443",
                      page: 4,
                      type: 0,
                      startOffset: 0,
                      endOffset: 51,
                      noteForHighlight: nil),
            Highlight(bookId: "Writing On Art Robert",
                      content: "These missives recounting what I had seen and thought were my way of thanking",
                      contentPost: " a person who “had everything”",
                      contentPre: "r of the Manhattan art world. ",
                      date: Date(),
                      highlightId: "E3FC3180-DF84-319E-E5F4-5220F416DBB7",
                      page: 4,
                      type: 0,
                      startOffset: 253,
                      endOffset: 330,
                      noteForHighlight: "Note ..."),
            Highlight(bookId: "Writing On Art Robert",
                      content: "One evening, early in our acquaintance, my great aunt took me downtown to the loft of William Rubin, the then newly named chief curator of the Department of Painting",
                      contentPost: " and Sculpture at М0МА. For up",
                      contentPre: " ",
                      date: Date(),
                      highlightId: "77FED9F0-7AE1-5666-6741-085E732AA89A",
                      page: 4,
                      type: 0,
                      startOffset: 3,
                      endOffset: 168,
                      noteForHighlight: nil)
        ]
    }
}
