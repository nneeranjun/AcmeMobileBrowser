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

class ViewController: UIViewController, WKNavigationDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var searchBar: UITextField!
    
    private let newTabPage = NewTabPage()
    
    private let invalidURLAlert = UIAlertController(title: "Invalid URL format", message: "Please enter a valid formatted URL", preferredStyle: UIAlertController.Style.alert)
    
    private let urlDoesNotExistAlert = UIAlertController(title: "URL Does Not Exist", message: "The entered domain does not exist. Please try a different one", preferredStyle: UIAlertController.Style.alert)
    
    private var currentTabIndex: Int = 0
    
    private var tabs: [Tab] = [
        Tab(url: "https://www.google.com", type: .normal),
        Tab(url: "https://amazon.com", type: .normal)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

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
        
        invalidURLAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        urlDoesNotExistAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
    }
    
    func validateURL(url: String) -> Bool {
        guard let URL = URL(string: url), UIApplication.shared.canOpenURL(URL) else {
            view.bringSubviewToFront(invalidURLAlert.view)
            present(invalidURLAlert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func getTabWith(webView: WKWebView) -> Tab? {
        for tab in tabs {
            if tab.webView.isEqual(webView) {
                return tab
            }
        }
        return nil
    }
    
    func updateSearchAndTabURL(updatedURL: String, tab: Tab) {
        tab.url = updatedURL
        if tabs[currentTabIndex].webView.isEqual(tab.webView) {
            searchBar.text = updatedURL
        }
    }
    
    //Once we have started navigating, set the search bar and current tab url
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        let urlString = webView.url?.absoluteString ?? ""
        let usedTab = getTabWith(webView: webView)
        
        updateSearchAndTabURL(updatedURL: urlString, tab: usedTab!)
        usedTab?.type = .normal
    }
    
    //Once we have finished navigating, we know we did not hit an error, so set our type to normal and switch to our new tab
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let urlString = webView.url?.absoluteString ?? ""
        let usedTab = getTabWith(webView: webView)
        
        updateSearchAndTabURL(updatedURL: urlString, tab: usedTab!)
        usedTab?.type = .normal
    }
    
    //If we encounter an error in navigating, remove the current page and transition to the error page. We also need to set the current tab to type error
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        searchBar.text = webView.url?.absoluteString ?? ""
        let usedTab = getTabWith(webView: webView)
        usedTab?.url = webView.url?.absoluteString ?? ""
        
        view.bringSubviewToFront(urlDoesNotExistAlert.view)
        present(urlDoesNotExistAlert, animated: true, completion: nil)
        
    }
    
    //If the user clicks search, then load the webpage and close the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchBar.resignFirstResponder()

        if validateURL(url: textField.text!) {
            let tab = tabs[currentTabIndex]
            tab.url = textField.text ?? ""
            loadPageWithinCurrentTab(url: tab.url)
        }

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
        let currTab = tabs[currentTabIndex]
        
        if currTab.type != .newTab {
            currTab.webView.reload()
        }
    }
    
    
    //Add a new tab, switch to it
    func addNewTab(_ tab: Tab) {
        self.tabs.append(tab)
        switchTab(to: tabs.count - 1)
        tab.webView.navigationDelegate = self
        tab.webView.allowsBackForwardNavigationGestures = true
    }
    
    /**
     return: Whether or not to dismiss the modal tab presenter
     */
    func deleteTab(at index: Int) -> Bool {
        //delete tab
        
        if index == currentTabIndex {
            removeCurrentPage()
        } else {
            currentTabIndex -= 1
        }
        
        tabs.remove(at: index)
        
        if tabs.isEmpty {
            let emptyTab = Tab(url: "Empty Tab", type: .newTab)
            addNewTab(emptyTab)
            return true
        } else {
            currentTabIndex = 0
            switchTab(to: currentTabIndex)
            return false
        }
        
    }
    
    //removes the current tab being presented
    func removeCurrentPage() {
        let currTab = tabs[currentTabIndex]
        
        switch currTab.type {
        case .normal:
            currTab.webView.removeFromSuperview()
        case .newTab:
            newTabPage.removeFromSuperview()
        }
    }
    
    //loads the new tab page
    func loadNewTabPage() {
        webViewContainer.addSubview(newTabPage)
        newTabPage.bindFrameToSuperviewBounds()
    }
    
    func switchTab(to index: Int) {
        let newTab = tabs[index]
        
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
        guard let urlString = URL(string: url) else { return }
        let request = URLRequest(url: urlString)

        currTab.webView.load(request)
        
        switch currTab.type {
        case .newTab:
            newTabPage.removeFromSuperview()
            webViewContainer.addSubview(currTab.webView)
            currTab.webView.bindFrameToSuperviewBounds()
        default: break
        }
    
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
        guard let superview = self.superview else { return}

        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: superview.topAnchor, constant: 0).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0).isActive = true
        self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0).isActive = true
    }
}
