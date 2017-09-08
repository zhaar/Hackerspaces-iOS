//
//  TableViewController.swift
//  Hackerspaces
//
//  Created by zephyz on 14/09/16.
//  Copyright © 2016 Fixme. All rights reserved.
//

import UIKit

class PrefPaneTableViewController: UITableViewController {
    
    @IBOutlet weak var toggle: UISwitch! {
        didSet {
            toggle.isOn = SharedData.isInDebugMode()
        }
    }

    @IBAction func toggleDebug(_ sender: UISwitch) {

        SharedData.toggleDebugMode()
        toggle.isOn = SharedData.isInDebugMode()
        if toggle.isOn {
            displayAlert(alertTitle: "Advanced mode enabled",
                         message: "Advanced mode displays more advanced features useful for hackerspace API developers",
                         buttonTitle: "OK",
                         confirmed: constFn(tableView.reloadData))
        } else {
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return toggle.isOn ? 3 : 2
        } else {
            return 5
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected indexpath \(indexPath)")
        if indexPath.section == 0, indexPath.row == 2 {
            displayAlert(alertTitle: "Deleting Cache",
                         alertStyle: .actionSheet,
                         message: "Are you sure you want to delete the local cache?",
                         buttonTitle: "Delete",
                         buttonStyle: .destructive,
                         confirmed: constFn(SharedData.deleteAllDebug))
        }
    }
}
