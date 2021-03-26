//
//  ViewController.swift
//  AcmeWebBrowserUIKit
//
//  Created by Nilay Neeranjun on 3/25/21.
//

import UIKit
import WebKit

enum TabType {
    case normal
    case error
    case startingPage
}

struct Tab {
    var url: String
    var webView: WKWebView = WKWebView()
    var type: TabType
}

class ViewController: UIViewController, WKNavigationDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var searchBar: UITextField!
    
    private let errorPage = ErrorPage()
    
    private var currentTabIndex: Int = 0
    
    private var tabs: [Tab] = [
        Tab(url: "https://www.google.com", type: TabType.normal),
        Tab(url: "https://amazon.com", type: TabType.normal)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        for tab in tabs {
            if tab.type == .normal {
                tab.webView.load(URLRequest(url: URL(string: tab.url)!))
                tab.webView.allowsBackForwardNavigationGestures = true
            }
        }
        
        let currentTab = tabs[currentTabIndex]
        let currentWebView = currentTab.webView
        
        currentWebView.navigationDelegate = self
        searchBar.delegate = self
        
        currentWebView.load(URLRequest(url: URL(string: currentTab.url)!))
        currentWebView.allowsBackForwardNavigationGestures = true
        webViewContainer.addSubview(currentWebView)
        currentWebView.bindFrameToSuperviewBounds()
        
        searchBar.clearButtonMode = .whileEditing
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        let newUrlString = webView.url?.absoluteString ?? ""
        searchBar.text = newUrlString
        tabs[currentTabIndex].url = newUrlString
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        tabs[currentTabIndex].type = .normal
        switchTab(to: currentTabIndex)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        removeCurrentPage()
        errorPage.errorMessage.text = "Sorry the webpage could not be loaded. Please try again!"
        tabs[currentTabIndex].webView.removeFromSuperview()
        webViewContainer.addSubview(errorPage)
        errorPage.bindFrameToSuperviewBounds()
        tabs[currentTabIndex].type = .error
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("loading \(textField.text!)")
        let tab = tabs[currentTabIndex]
        if tab.type == .error || tab.type == .startingPage {
            removeCurrentPage()
        }
        tab.webView.load(URLRequest(url: URL(string: textField.text!)!))
        searchBar.endEditing(true)
        //switchTab(to: currentTabIndex)
        return true

    }
    
    func getWebView(at index: Int) -> WKWebView {
        return tabs[index].webView
    }
    
    @IBAction func goBack(_ sender: Any) {
        let webView = getWebView(at: currentTabIndex)
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @IBAction func goForward(_ sender: Any) {
        let webView = getWebView(at: currentTabIndex)
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    @IBAction func showTabs(_ sender: Any) {
        performSegue(withIdentifier: "showTabs", sender: self)
    }
    
    func addTabFromTabView(tab: Tab) {
        self.tabs.append(tab)
        switchTab(to: tabs.count - 1)
        tab.webView.load(URLRequest(url: URL(string: tab.url)!))
    }
    
    func deleteTab(at index: Int) {
        //delete tab
        
    }
    
    func removeCurrentPage() {
        let currTab = tabs[currentTabIndex]
        switch currTab.type {
        case .normal:
            currTab.webView.removeFromSuperview()
        case .error:
            errorPage.removeFromSuperview()
        default: return
        }
    }
    
    func loadErrorPage() {
        errorPage.errorMessage.text = "Sorry the webpage could not be loaded. Please try again!"
        tabs[currentTabIndex].webView.removeFromSuperview()
        webViewContainer.addSubview(errorPage)
        errorPage.bindFrameToSuperviewBounds()
    }
    
    func switchTab(to index: Int) {
       //let currTab = tabs[currentTabIndex]
        let newTab = tabs[index]
        removeCurrentPage()
        switch newTab.type {
        case .normal:
            newTab.webView.navigationDelegate = self
            webViewContainer.addSubview(newTab.webView)
            newTab.webView.bindFrameToSuperviewBounds()
            searchBar.text = newTab.url
        case .error: loadErrorPage()
        default: return
        }
        currentTabIndex = index
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTabs" {
            let controller = segue.destination as! TabTableView
            controller.delegate = self
            controller.tabs = tabs
        }
    }

}

extension UIView {
    func bindFrameToSuperviewBounds() {
        guard let superview = self.superview else {
            return
        }

        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: superview.topAnchor, constant: 0).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0).isActive = true
        self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0).isActive = true
    }
}

