//
//  ObjectTableViewController.swift
//  Hackerspaces
//
//  Created by zephyz on 13/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import UIKit

class ObjectTableViewController: UITableViewController {
    let collation = UILocalizedIndexedCollation.currentCollation() as UILocalizedIndexedCollation
    var sections: [[Object]] = []
    var objects: [Object] {
        didSet {
            let selector: Selector = "localizedTitle"
            
            
            sections = [[Object]](count: collation.sectionTitles.count, repeatedValue: [])
            
            let sortedObjects = collation.sortedArrayFromArray(objects, collationStringSelector: selector) as [Object]
            for object in sortedObjects {
                let sectionNumber = collation.sectionForObject(object, collationStringSelector: selector)
                sections[sectionNumber].append(object)
            }
            
            self.tableView.reloadData()
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
        return collation.sectionTitles![section] as String
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView!) -> [AnyObject]! {
        return collation.sectionIndexTitles
    }
    
    override func tableView(tableView: UITableView!, sectionForSectionIndexTitle title: String!, atIndex index: Int) -> Int {
        return collation.sectionForSectionIndexTitleAtIndex(index)
    }
}