//
//  UnitTests.swift
//  UnitTests
//
//  Created by Vinicius Leal on 28/10/2020.
//  Copyright © 2020 FolioReader. All rights reserved.
//

@testable import FolioReaderKit
import XCTest
import WebKit

class FolioReaderPageTests: XCTestCase {

    func test_loadHTML_deliversMessageToWebView() {
        let sut = FolioReaderPage()
        let webViewSpy = WebViewSpy()
        
        sut.webView = webViewSpy
        let htmlString: String = .htmlString
        let baseURL = anyURL()
        
        sut.loadHTMLString(htmlString, baseURL: baseURL)
        
        XCTAssertEqual(webViewSpy.loadedURLs, [baseURL])
        XCTAssertEqual(webViewSpy.loadedStrings, [htmlString])
    }
    
    // MARK: - Helpers
    
    private func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    private class WebViewSpy: FolioReaderWebView {
        private var loaded = [(htmlString: String, baseURL: URL?)]()
        
        var loadedURLs: [URL?] {
            loaded.map { $0.baseURL }
        }
        
        var loadedStrings: [String] {
            loaded.map { $0.htmlString }
        }
        
        convenience init() {
            let container = FolioReaderContainer(withConfig: FolioReaderConfig(), folioReader: FolioReader(), epubPath: "any path")
            self.init(frame: CGRect(x: 0, y: 0, width: 300, height: 300), readerContainer: container)
        }
        
        override func loadHTMLString(_ string: String, baseURL: URL?) -> WKNavigation? {
            loaded.append((string, baseURL))
            return nil
        }
    }
}
