//
//  FavoriteHackerspace.swift
//  Hackerspaces
//
//  Created by zephyz on 10/08/16.
//  Copyright © 2016 Fixme. All rights reserved.
//

import UIKit
import BrightFutures

class FavoriteHackerspaceTableViewController: HackerspaceBaseTableViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshCustomEndpoints()
        refreshHackerspaces()
    }

    override func viewDidLoad() {
        navigationItem.leftBarButtonItem = editButtonItem
        dataSource =  { _ in
            Future(value: SharedData.favoritesDictionary()).promoteError()
        }
        title = "Favorites"
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        if indexPath.section == 0 && !customEndpoints.isEmpty {
            let hackerspaceToDelete = visibleEndpoints()[indexPath.row].0
            SharedData.removeCustomEndPoint(name: hackerspaceToDelete)
            customEndpoints = remove(from: customEndpoints, key: hackerspaceToDelete)
            if customEndpoints.count == 0 {
                tableView.deleteSections([0], with: .automatic)
            } else {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        } else {
            let hackerspaceToDelete = visibleHackerspaces()[indexPath.row].0
            SharedData.removeFromFavoritesList(name: hackerspaceToDelete)
            hackerspaces = remove(from: hackerspaces, key: hackerspaceToDelete)
            tableView.deleteRows(at: [indexPath], with: .fade)

        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if visibleHackerspaces().count + visibleEndpoints().count == 0 {
            let instructions = UILabel.init(frame: self.tableView.bounds)
            instructions.attributedText = NSAttributedString(string: "Select your favorite hackerspace from search or map")
            instructions.textAlignment = .center
            instructions.textColor = UIColor.gray
            instructions.numberOfLines = 0
            tableView.backgroundView = instructions
            tableView.separatorStyle = .none
            return 1
        } else {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView = nil
            return visibleEndpoints().count > 0 ? 2 : 1
        }
    }
    
    override func previewActionCallback() {
        print("refreshing from callback")
        self.refresh(refreshControl!)
    }
}
