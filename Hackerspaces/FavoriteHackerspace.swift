//
//  FavoriteHackerspace.swift
//  Hackerspaces
//
//  Created by zephyz on 10/08/16.
//  Copyright © 2016 Fixme. All rights reserved.
//

import UIKit

class FavoriteHackerspaceTableViewController: HackerspaceBaseTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem()
        title = "Favorites"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshControl?.beginRefreshing()
        self.refresh(refreshControl!)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let hackerspaceToDelete = visibleResults[indexPath.row]
            SharedData.removeFromFavoritesList(hackerspaceToDelete)
            visibleResults.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if visibleResults.count == 0 {
            let instructions = UILabel(frame: self.tableView.bounds)
            instructions.attributedText = NSAttributedString(string: "Select your favorite hackerspace from search or map")
            instructions.textAlignment = .Center
            instructions.textColor = UIColor.blackColor()
            instructions.numberOfLines = 0
            tableView.backgroundView = instructions
            tableView.separatorStyle = .None
            return 1
        } else {
            tableView.separatorStyle = .SingleLine
            tableView.backgroundView = nil
            return 1
        }
    }
}