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
            SharedData.sharedInstance.removeFromFavoritesList(hackerspaceToDelete)
            visibleResults.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
}