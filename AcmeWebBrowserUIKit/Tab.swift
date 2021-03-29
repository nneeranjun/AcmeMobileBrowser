//
//  Tab.swift
//  AcmeWebBrowserUIKit
//
//  Created by Nilay Neeranjun on 3/27/21.
//

import Foundation
import WebKit

enum TabType {
    case normal
    case newTab
}

class Tab {
    var url: String
    var webView: WKWebView = WKWebView()
    var type: TabType
    
    init(url: String, type: TabType) {
        self.url = url
        self.type = type
    }
    
    var description : String {
        "Tab : url : `\(url) - webView : `\(webView)` - type : `\(type)`"
    }
    
    var title: String {
        if type == .newTab || url == "" {
            return "Empty Tab"
        } else {
            return url
        }
    }
}
