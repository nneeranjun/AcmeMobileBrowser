//
//  ViewController.swift
//  AcmeWebBrowserUIKit
//
//  Created by Nilay Neeranjun on 3/25/21.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private let newTabPage = NewTabPage()
    
    var currentTabIndex: Int = 0
    
    private var tabs: [Tab] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        newTabPage.message.text = "Welcome to the Acme web browser. Start searching above!"
        
        let entryTab = Tab(url: "", type: .newTab)
        addNewTab(entryTab)
        
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        searchBar.setShowsCancelButton(false, animated: false)
        searchBar.searchTextField.clearButtonMode = .whileEditing
        
        //makes the search bar have no borders
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: UIBarMetrics.default)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: false)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: false)
        searchBar.text = tabs[currentTabIndex].url
        searchBar.resignFirstResponder()
    }
    
    func presentInvalidURLAlert() {
        let invalidURLAlert = UIAlertController(title: "Invalid URL format", message: "Please enter a valid formatted URL", preferredStyle: UIAlertController.Style.alert)
        invalidURLAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        
        present(invalidURLAlert, animated: true, completion: nil)
    }
    
    func presentURLDoesNotExistAlert(error: Error) {
        let urlDoesNotExistAlert = UIAlertController(title: "Error Loading URL", message: "The URL could not be loaded due to the following reason: \(error.localizedDescription) Please try again!", preferredStyle: UIAlertController.Style.alert)
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
    
    //Update the url and tab when we start navigating
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        let urlString = webView.url?.absoluteString ?? ""
        guard let usedTab = getTabContaining(webView: webView) else {
            self.searchBar.isLoading = false
            return
        }
        
        updateSearchAndTabURL(updatedURL: urlString, tab: usedTab)
    }
    
    //Once we have finished navigating, we know we did not hit an error, so set our type to normal, update the search and tab url, switch to our new tab, and remove the loading indicator.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let urlString = webView.url?.absoluteString ?? ""
        guard let usedTab = getTabContaining(webView: webView) else {
            self.searchBar.isLoading = false
            return
        }
        
        if usedTab.webView == tabs[currentTabIndex].webView  {
            searchBar.isLoading = false
        }
        
        updateSearchAndTabURL(updatedURL: urlString, tab: usedTab)
        usedTab.type = .normal
    }
    
    //If we encounter an error in navigating, remove the loading indicator and current page and transition to the error page
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let urlString = webView.url?.absoluteString ?? ""
        guard let usedTab = getTabContaining(webView: webView) else {
            self.searchBar.isLoading = false
            return
        }
        
        if usedTab.webView == tabs[currentTabIndex].webView  {
            searchBar.isLoading = false
        }
        
        presentURLDoesNotExistAlert(error: error)
        updateSearchAndTabURL(updatedURL: urlString, tab: usedTab)
        
        if usedTab.type == .newTab {
            usedTab.webView.removeFromSuperview()
            loadNewTabPage()
        }
    }
    
    //If the user clicks search, then load the webpage and close the keyboard. If it is invalid, present an alert and reset the keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchText = searchBar.text ?? ""
        searchBar.setShowsCancelButton(false, animated: false)
        searchBar.resignFirstResponder()
        let tab = tabs[currentTabIndex]
        
        if searchText == "" {
            presentInvalidURLAlert()
            searchBar.text = tab.url
            return
        }
        
        //allows to load urls without an explicit protocol
        let urlOptions = [searchText, "https://\(searchText)", "http://\(searchText)"]
        
        for url in urlOptions {
            if url.isValidURL {
                searchBar.isLoading = true
                tab.url = url
                loadPageWithinCurrentTab(url: tab.url)
                return
            }
        }
        
        //no urls work, so default to google search
        //if there are spaces or other special characters, escape them
        let allowedCharacters = NSCharacterSet.urlFragmentAllowed
        guard let encodedSearchString  = searchText.addingPercentEncoding(withAllowedCharacters: allowedCharacters)  else { return }
        let queryString = "https://www.google.com/search?q=\(encodedSearchString)"
        
        searchBar.isLoading = true
        loadPageWithinCurrentTab(url: queryString)
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
    
    //loads the new tab page
    func loadNewTabPage() {
        webViewContainer.addSubview(newTabPage)
        newTabPage.bindFrameToSuperviewBounds()
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
    
    //navigation to different views
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTabs" {
            let controller = segue.destination as! TabTableViewController
            controller.delegate = self
            controller.tabs = tabs
        } else if segue.identifier == "showScanner" {
            let controller = segue.destination as! QRScannerController
            controller.delegate = self
        }
    }

}
