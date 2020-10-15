//
//  FolioReaderWebViewTests.swift
//  FolioReaderKitTests
//
//  Created by Vinicius Leal on 15/10/2020.
//  Copyright © 2020 FolioReader. All rights reserved.
//

@testable import FolioReaderKit
import XCTest

class FolioReaderWebViewTests: XCTestCase {
    
    func test_init_noTextIsSelected() {
        let container = ContainerSpy(epubPath: getEbubPath())
        let sut = FolioReaderWebView(frame: CGRect(x: 0, y: 0, width: 300, height: 200), readerContainer: container)
        
        let selection = sut.js("getSelectedText()")
        
        XCTAssertNil(selection)
    }
    
    // Mark: - Helpers
    
    private func getEbubPath() -> String {
        let bundle = Bundle(for: FolioReaderWebViewTests.self)
        return bundle.path(forResource: "The Adventures Of Sherlock Holmes - Adventure I", ofType: "epub")!
    }
    
    private class ContainerSpy: FolioReaderContainer {
        
        convenience init(epubPath: String) {
            let config = FolioReaderConfig()
            let reader = FolioReader()
            self.init(withConfig: config, folioReader: reader, epubPath: epubPath)
        }
    }
}
