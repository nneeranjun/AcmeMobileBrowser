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
        get {
            return "Tab : url : `\(url) - webView : `\(webView)` - type : `\(type)`"
        }
    }
}

class ViewController: UIViewController, WKNavigationDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var searchBar: UITextField!
    
    private let errorPage = ErrorPage()
    private let newTabPage = NewTabPage()
    
    private var currentTabIndex: Int = 0
    
    private var tabs: [Tab] = [
        Tab(url: "https://www.google.com", type: .normal),
        Tab(url: "https://amazon.com", type: .normal)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        errorPage.errorMessage.text = "Sorry the webpage could not be loaded. Please try again!"
        newTabPage.message.text = "Welcome to the Acme web browser. Start searching above!"
        
        for tab in tabs {
            if tab.type == .normal {
                tab.webView.load(URLRequest(url: URL(string: tab.url)!))
                tab.webView.allowsBackForwardNavigationGestures = true
                tab.webView.navigationDelegate = self
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
    
    func getTabWith(webView: WKWebView) -> Tab? {
        for tab in tabs {
            if tab.webView.isEqual(webView) {
                return tab
            }
        }
        return nil
    }
    
    //One we have started navigating, set the search bar and current tab url
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        let usedTab = getTabWith(webView: webView)
        usedTab!.url = webView.url!.absoluteString
        
        if tabs[currentTabIndex].webView.isEqual(usedTab!.webView) {
            searchBar.text = webView.url?.absoluteString
        }
    }
    
    //Once we have finished navigating, we know we did not hit an error, so set our type to normal and switch to our new tab
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let usedTab = getTabWith(webView: webView)
        
        print(usedTab?.description)
        
        usedTab!.url = webView.url!.absoluteString
        if tabs[currentTabIndex].webView.isEqual(usedTab!.webView) {
            searchBar.text = webView.url?.absoluteString
        }
        
        usedTab!.type = .normal
    }
    
    //If we encounter an error in navigating, remove the current page and transition to the error page. We also need to set the current tab to type error
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        removeCurrentPage()
        loadErrorPage()
        
        let usedTab = getTabWith(webView: webView)
        usedTab?.type = .error
    }
    
    //If the user clicks search, then load the webpage and close the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let tab = tabs[currentTabIndex]
        tab.url = textField.text!
        loadPageWithinCurrentTab(url: textField.text ?? "")
        return true
    }
    
    //helper function to return the webView at the give index
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
    
    //transition to tabs page
    @IBAction func showTabs(_ sender: Any) {
        performSegue(withIdentifier: "showTabs", sender: self)
    }
    
    @IBAction func refresh(_ sender: Any) {
        tabs[currentTabIndex].webView.reload()
    }
    
    //Add a new tab, switch to it, then load it
    func addNewTab(_ tab: Tab) {
        self.tabs.append(tab)
        switchTab(to: tabs.count - 1)
        tab.webView.navigationDelegate = self
    }
    
    func deleteTab(at index: Int) {
        //delete tab
        tabs.remove(at: index)
        //this probably doesn't work
        if index == currentTabIndex {
            if tabs.isEmpty {
                //handle if empty case
            } else {
                currentTabIndex = 0
            }
            removeCurrentPage()
            switchTab(to: currentTabIndex)
        } else {
            currentTabIndex -= 1
        }
    }
    
    //removes the current tab being presented
    func removeCurrentPage() {
        let currTab = tabs[currentTabIndex]
        switch currTab.type {
        case .normal:
            currTab.webView.removeFromSuperview()
        case .error:
            errorPage.removeFromSuperview()
        case .newTab:
            newTabPage.removeFromSuperview()
        }
    }
    
    //loads the error page
    func loadErrorPage() {
        webViewContainer.addSubview(errorPage)
        errorPage.bindFrameToSuperviewBounds()
    }
    
    //loads the new tab page
    func loadNewTabPage() {
        webViewContainer.addSubview(newTabPage)
        newTabPage.bindFrameToSuperviewBounds()
    }
    
    
    func switchTab(to index: Int) {
        let newTab = tabs[index]
        print("switching to \(newTab.type)")
        
        //remove the current tab being displayed
        removeCurrentPage()
        
        //load the new tab based on its type
        switch newTab.type {
        case .normal:
            newTab.webView.navigationDelegate = self
            webViewContainer.addSubview(newTab.webView)
            newTab.webView.bindFrameToSuperviewBounds()
            searchBar.text = newTab.url
            searchBar.resignFirstResponder()
        case .error:
            loadErrorPage()
            searchBar.text = newTab.url
            searchBar.resignFirstResponder()
        case .newTab:
            loadNewTabPage()
            searchBar.text = ""
            searchBar.becomeFirstResponder()
        }
        
        //set the current tab index
        currentTabIndex = index
    }
    
    func loadPageWithinCurrentTab(url: String) {
        let currTab = tabs[currentTabIndex]
        let request = URLRequest(url: URL(string: url)!)
        currTab.webView.load(request)
        
        switch currTab.type {
        case .error:
            errorPage.removeFromSuperview()
        case .newTab:
            newTabPage.removeFromSuperview()
        default: break
        }
        
        webViewContainer.addSubview(currTab.webView)
        currTab.webView.bindFrameToSuperviewBounds()
        
        currTab.url = url
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
