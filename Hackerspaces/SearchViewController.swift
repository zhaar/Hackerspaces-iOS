//
//  SearchViewController.swift
//  Hackerspaces
//
//  Created by zephyz on 05/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import UIKit
import SwiftHTTP
import JSONJoy

let spaceAPI = "http://spaceapi.net/directory.json"

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let textCellIdentifier = "TextCell"
    
    var refreshControl:UIRefreshControl!
    var spaces: [String]? = nil

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
    }
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spaces?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        let row = indexPath.row
        cell.textLabel?.text = spaces?[row]
        
        return cell
    }

    func refresh(sender:AnyObject) {
        // Code to refresh table view
        println("refresh!")
        var request = HTTPTask()
        request.GET(spaceAPI, parameters: nil, completionHandler: {(response: HTTPResponse) in
            if let err = response.error {
                println("error: \(err.localizedDescription)")
                return;
            }
            if let data = response.responseObject as? NSData {
                self.spaces = JSONDecoder(data).dictionary?.keys.array
                self.spaces?.sort(<)
                self.tableView.reloadData()
                println(self.spaces)
            }
            self.refreshControl.endRefreshing()

        })
    }
}
