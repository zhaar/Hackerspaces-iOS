//
//  HackerspaceTableViewController.swift
//  Hackerspaces
//
//  Created by zephyz on 14/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import UIKit
import SwiftHTTP
import JSONJoy

class HackerspaceTableViewController: UITableViewController {
    
    var hackerspaces: [Hackerspace] = []
    
    private struct Storyboard {
        static let CellIdentifier = "Cell"
    }

    //MARK: - View controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var request = HTTPTask()
        request.GET(spaceAPI, parameters: nil, completionHandler: {(response: HTTPResponse) in
            dispatch_async(dispatch_get_main_queue()) {
                if let err = response.error {
                    println("error: \(err.localizedDescription)")
                } else if let data = response.responseObject as? NSData {
                    if let dict = JSONDecoder(data).dictionary {
                        let keys = dict.keys.array
                        let hs = keys.map { (name) -> Hackerspace? in
                            let api = dict[name]?.string
                            return api == nil ? nil : Hackerspace(name: name, api: api!)}
                        self.tableView.reloadData()
    //                    self.tableView.updateSpaceList(JSONDecoder(data).dictionary?.keys.array)
                    }
                }
            }
        
        })
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hackerspaces.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellIdentifier, forIndexPath: indexPath) as! UITableViewCell

        cell.textLabel?.text = hackerspaces[indexPath.row].name
        
        return cell
    }
    
}
