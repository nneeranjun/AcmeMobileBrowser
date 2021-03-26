//
//  ViewController.swift
//  AcmeWebBrowserUIKit
//
//  Created by Nilay Neeranjun on 3/25/21.
//

import UIKit
import WebKit

//TODO: Make sure back, forward works when error page is loaded
//TODO: Handle empty tab list

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
        errorPage.errorMessage.text = "Sorry the webpage could not be loaded. Please try again!"
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
        loadErrorPage()
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
        tabs.remove(at: index)
        if index == currentTabIndex {
            if tabs.isEmpty {
                //handle if empty case
            } else {
                currentTabIndex = 0
            }
            removeCurrentPage()
            switchTab(to: currentTabIndex)
        }
    }
    
    func removeCurrentPage() {
        let currTab = tabs[currentTabIndex]
        switch currTab.type {
        case .normal:
            //if we are coming from a normal page, remove the webView
            currTab.webView.removeFromSuperview()
        case .error:
            //if we are coming from an error page, remove the error page
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
        let newTab = tabs[index]
        
        //remove the current page being displayed before switching
        removeCurrentPage()
        
        switch newTab.type {
        case .normal:
            //if we are going to a normal page, use the webView
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

