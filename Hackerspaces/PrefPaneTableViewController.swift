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
            toggle.on = UserDefaults.isInDebugMode()
        }
    }
    
    @IBAction func toggleDebugMode(sender: UISwitch) {
        UserDefaults.toggleDebugMode()
        toggle.on = UserDefaults.isInDebugMode()
        if toggle.on {
            let alert = UIAlertController(title: "Debug mode enabled", message: "debug mode allows you to access error details when a hackerspace is unreachable", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
