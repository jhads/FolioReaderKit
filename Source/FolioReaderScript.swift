//
//  FolioReaderScript.swift
//  FolioReaderKit
//
//  Created by Stanislav on 12.06.2020.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import WebKit

class FolioReaderScript: WKUserScript {
        
    convenience init(source: String) {
        self.init(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }
    
    func addIfNeeded(to webView: WKWebView?) {
        guard let controller = webView?.configuration.userContentController else { return }
        let alreadyAdded = controller.userScripts.contains { [unowned self] in
            return $0.source == self.source &&
                $0.injectionTime == self.injectionTime &&
                $0.isForMainFrameOnly == self.isForMainFrameOnly
        }
        if alreadyAdded { return }
        controller.addUserScript(self)
    }
}

struct ScriptSource {
    static let bridgeJS: String = {
        let jsURL = Bundle.frameworkBundle().url(forResource: "Bridge", withExtension: "js")!
        let jsSource = try! String(contentsOf: jsURL)
        return jsSource
    }()
    
    static let cssInjection: String = {
        let cssURL = Bundle.frameworkBundle().url(forResource: "Style", withExtension: "css")!
        let cssString = try! String(contentsOf: cssURL)
        return cssInjectionSource(for: cssString)
    }()
    
    static func cssInjection(overflow: String) -> String {
        let cssString = "html{overflow:\(overflow)}"
        return ScriptSource.cssInjectionSource(for: cssString)
    }
    
    static private func cssInjectionSource(for content: String) -> String {
        let oneLineContent = content.components(separatedBy: .newlines).joined()
        let source = """
        var style = document.createElement('style');
        style.type = 'text/css'
        style.innerHTML = '\(oneLineContent)';
        document.head.appendChild(style);
        """
        return source
    }
}
