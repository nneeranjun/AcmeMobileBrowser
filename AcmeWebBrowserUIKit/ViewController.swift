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
    
    private var currentTabIndex: Int = 0
    
    private var tabs: [Tab] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        newTabPage.message.text = "Welcome to the Acme web browser. Start searching above!"
        
        let entryTab = Tab(url: "", type: .newTab)
        addNewTab(entryTab)
        
        searchBar.delegate = self
        searchBar.clearButtonMode = .whileEditing
    }
    
    func validateURL(url: String) -> Bool {
        if let URL = URL(string: url), UIApplication.shared.canOpenURL(URL) {
            return true
        } else {
            return false
        }
    }
    
    func presentInvalidURLAlert() {
        let invalidURLAlert = UIAlertController(title: "Invalid URL format", message: "Please enter a valid formatted URL", preferredStyle: UIAlertController.Style.alert)
        invalidURLAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        
        present(invalidURLAlert, animated: true, completion: nil)
    }
    
    func presentURLDoesNotExistAlert() {
        let urlDoesNotExistAlert = UIAlertController(title: "URL Does Not Exist", message: "The entered domain does not exist. Please try a different one", preferredStyle: UIAlertController.Style.alert)
        urlDoesNotExistAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        
        present(urlDoesNotExistAlert, animated: true, completion: nil)
    }
    
    //retrieves the tab which contains the specified WKWebView. used to tell which tab is being loaded since they can load separately
    func getTabContaining(webView: WKWebView) -> Tab? {
        for tab in tabs {
            if tab.webView.isEqual(webView) {
                return tab
            }
        }
        return nil
    }
    
    //updates the tab's url and the search bar url (only if we aren't that current tab)
    func updateSearchAndTabURL(updatedURL: String, tab: Tab) {
        tab.url = updatedURL
        if tabs[currentTabIndex].webView.isEqual(tab.webView) {
            searchBar.text = updatedURL
        }
    }
    
    //Once we have finished navigating, we know we did not hit an error, so set our type to normal, update the search and tab url, and switch to our new tab.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let urlString = webView.url?.absoluteString ?? ""
        let usedTab = getTabContaining(webView: webView)
        
        updateSearchAndTabURL(updatedURL: urlString, tab: usedTab!)
        usedTab?.type = .normal
    }
    
    //If we encounter an error in navigating, remove the current page and transition to the error page
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        presentURLDoesNotExistAlert()
        
        let urlString = webView.url?.absoluteString ?? ""
        let usedTab = getTabContaining(webView: webView)
        
        updateSearchAndTabURL(updatedURL: urlString, tab: usedTab!)
        
        if usedTab!.type == .newTab {
            usedTab!.webView.removeFromSuperview()
            loadNewTabPage()
        }
    }
    
    //If the user clicks search, then load the webpage and close the keyboard. If it is invalid, present an alert
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let searchText = textField.text ?? ""
        searchBar.resignFirstResponder()
        
        if validateURL(url: searchText) {
            let tab = tabs[currentTabIndex]
            tab.url = searchText
            loadPageWithinCurrentTab(url: tab.url)
        } else {
            presentInvalidURLAlert()
        }
        
        return true
    }

    @IBAction func goBack(_ sender: Any) {
        let webView = tabs[currentTabIndex].webView
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @IBAction func refresh(_ sender: Any) {
        let currTab = tabs[currentTabIndex]
        
        if currTab.type != .newTab {
            currTab.webView.reload()
        }
    }
    
    @IBAction func goForward(_ sender: Any) {
        let webView = tabs[currentTabIndex].webView
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    //transition to tabs page
    @IBAction func showTabs(_ sender: Any) {
        performSegue(withIdentifier: "showTabs", sender: self)
    }
    
    //transition to qr scanner page
    @IBAction func showScanner(_ sender: Any) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showScanner", sender: self)
        }
    }
    
    //Add a new tab, switch to it. if it is a normal tab, then load it
    func addNewTab(_ tab: Tab) {
        tab.webView.navigationDelegate = self
        tab.webView.allowsBackForwardNavigationGestures = true
        
        self.tabs.append(tab)
        switchTab(to: tabs.count - 1)
        
        if tab.type == .normal {
            let request = URLRequest(url: URL(string: tab.url)!)
            tab.webView.load(request)
        }
    }
    
    //deletes tab at given index and returns whether or not to dismiss modal tab (from tabs view)
    func deleteTab(at index: Int) -> Bool {
        if index == currentTabIndex {
            removeCurrentPage()
        } else {
            currentTabIndex -= 1
        }
        
        tabs.remove(at: index)
        
        if tabs.isEmpty {
            let emptyTab = Tab(url: "", type: .newTab)
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
    
    //switces to the tab at given index
    func switchTab(to index: Int) {
        let newTab = tabs[index]
        
        //remove the current tab being displayed
        removeCurrentPage()
        
        //load the correct page based on the tab type
        switch newTab.type {
        case .normal:
            webViewContainer.addSubview(newTab.webView)
            newTab.webView.bindFrameToSuperviewBounds()
            searchBar.text = newTab.url
        case .newTab:
            loadNewTabPage()
            searchBar.text = ""
        }
        
        //set the current tab index
        currentTabIndex = index
    }
    
    //loads new page within current tab
    func loadPageWithinCurrentTab(url: String) {
        let currTab = tabs[currentTabIndex]
        let request = URLRequest(url: URL(string: url)!) //this is ok since I already validated url in the calling function
        currTab.url = url

        currTab.webView.load(request)
        
        if currTab.type == .newTab {
            newTabPage.removeFromSuperview()
            webViewContainer.addSubview(currTab.webView)
            currTab.webView.bindFrameToSuperviewBounds()
        }
    }
    
    //navigation to different views
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTabs" {
            let controller = segue.destination as! TabTableView
            controller.delegate = self
            controller.tabs = tabs
            controller.currentTabIndex = currentTabIndex
        } else if segue.identifier == "showScanner" {
            let controller = segue.destination as! QRScanner
            controller.delegate = self
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
