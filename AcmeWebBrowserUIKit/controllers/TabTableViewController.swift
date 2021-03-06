//
//  TabTableView.swift
//  AcmeWebBrowserUIKit
//
//  Created by Nilay Neeranjun on 3/26/21.
//

import Foundation

import UIKit

class TabTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: ViewController!
    var tabs: [Tab] = []

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addNewTab(_ sender: Any) {
        let newTab = Tab(url: "", type: .newTab)
        delegate.addNewTab(newTab)
        tableView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tabs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = UITableViewCell(style: .default, reuseIdentifier: "basicRow")
        row.textLabel?.text = tabs[indexPath.row].title
        row.imageView?.image = UIImage(systemName: "safari")
        
        if indexPath.row == delegate.currentTabIndex {
            row.backgroundColor = .secondarySystemBackground
        }
        
        return row
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.switchTab(to: indexPath.row)
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            tabs.remove(at: indexPath.row)
            self.tableView.reloadData()
            
            //delete tab and dismiss if we have no tabs left
            if delegate.deleteTab(at: indexPath.row) {
                dismiss(animated: true, completion: nil)
            }
            
        }
    }
    
}
