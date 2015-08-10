//
//  TableViewController.swift
//  Hackerspaces
//
//  Created by zephyz on 07/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import UIKit

class TableViewController: UITableView, UITableViewDataSource, UITableViewDelegate {

    let textCellIdentifier = "TextCell"
    
    var spaces: [String] = []

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spaces.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        let row = indexPath.row
        cell.textLabel?.text = spaces[row]
        
        return cell
    }
    
    func updateSpaceList(arr: [String]?) {
        self.spaces = arr ?? []
        self.spaces.sort(<)
        self.reloadData()
    }
}
