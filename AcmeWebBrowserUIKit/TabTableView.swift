//
//  TabTableView.swift
//  AcmeWebBrowserUIKit
//
//  Created by Nilay Neeranjun on 3/26/21.
//

import Foundation

import UIKit

class TabTableView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: ViewController!
    var tabs: [Tab] = []
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addNewTab(_ sender: Any) {
        let newTab = Tab(url: "https://yahoo.com", type: .normal)
        delegate.addTabFromTabView(tab: newTab)
        tableView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tabs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = UITableViewCell(style: .default, reuseIdentifier: "basicRow")
        row.textLabel?.text = tabs[indexPath.row].url
        return row
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.switchTab(to: indexPath.row
        )
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
