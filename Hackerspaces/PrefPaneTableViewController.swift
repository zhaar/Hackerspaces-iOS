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
            let alert = UIAlertController(title: "Debug mode enabled", message: "debug mode allows you to access error details when a hackerspace is unreachable", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
