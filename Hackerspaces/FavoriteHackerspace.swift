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
        navigationItem.leftBarButtonItem = editButtonItem
        title = "Favorites"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refresh(refreshControl!)
    }
        
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let hackerspaceToDelete = visibleResults[indexPath.row]
            SharedData.removeFromFavoritesList(name: hackerspaceToDelete)
            visibleResults.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if visibleResults.count == 0 {
            let instructions = UILabel(frame: self.tableView.bounds)
            instructions.attributedText = NSAttributedString(string: "Select your favorite hackerspace from search or map")
            instructions.textAlignment = .center
            instructions.textColor = UIColor.black
            instructions.numberOfLines = 0
            tableView.backgroundView = instructions
            tableView.separatorStyle = .none
            return 1
        } else {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView = nil
            return 1
        }
    }
    
    override func previewActionCallback() {
        print("refreshing from callback")
        self.refresh(refreshControl!)
    }
}
