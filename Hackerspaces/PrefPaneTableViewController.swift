//
//  TableViewController.swift
//  Hackerspaces
//
//  Created by zephyz on 14/09/16.
//  Copyright © 2016 Fixme. All rights reserved.
//

import UIKit
import Swiftz

class PrefPaneTableViewController: UITableViewController {

    let refresh = UIRefreshControl()

    @IBOutlet weak var toggle: UISwitch! {
        didSet {
            toggle.isOn = SharedData.isInDebugMode()
        }
    }
    @IBOutlet var darkModeToggle: UISwitch! {
        didSet {
            darkModeToggle.isOn = SharedData.isInDarkMode()
        }
    }

    @IBAction func toggleDebug() {

        if !SharedData.isInDebugMode() {
            displayAlert(alertTitle: "Advanced mode enabled",
                         message: "Advanced mode displays more advanced features useful for hackerspace API developers",
                         buttonTitle: "OK",
                         confirmed: { _ in self.setupDebugMode(enable: true) },
                         canceled: constFn(refresh.endRefreshing))
        } else {
            setupDebugMode(enable: false)
        }
    }

    @IBAction func toggleDarkMode(_ sender: Any) {
        SharedData.setDarkMode(value: !SharedData.isInDarkMode())
        darkModeToggle.isOn = SharedData.isInDarkMode()
        if SharedData.isInDarkMode() {
            Theme.enableDarkMode()
        } else {
            Theme.enableClearMode()
        }
        Theme.redrawAll()
        tableView.reloadData()
    }

    func setupDebugMode(enable isEnabled: Bool) {
        let rows = (1...3).map { IndexPath.init(row: $0, section: 0) }
        let refreshTitle = isEnabled ? "Pull to disable Advanced Mode" : "Pull to enable Advanced Mode"
        let updateRows = isEnabled ? tableView.insertRows : tableView.deleteRows
        SharedData.setDebugMode(value: isEnabled)
        toggle.isOn = isEnabled
        refresh.endRefreshing()
        refresh.attributedTitle = NSAttributedString(string: refreshTitle)
        updateRows(rows, .automatic)
    }


    // MARK: - App lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        refresh.attributedTitle = NSAttributedString.init(string: "Enable Advanced Mode")
        refresh.tintColor = UIColor.clear
        refresh.addTarget(self, action: #selector(PrefPaneTableViewController.toggleDebug), for: UIControlEvents.valueChanged)
        self.refreshControl = refresh
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.backgroundColor = SharedData.isInDarkMode() ? UIColor.darkBackground : UIColor.staticTableBackground
    }

    //MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if SharedData.isInDebugMode() && section == 0 {
            return 4
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = SharedData.isInDarkMode() ? UIColor.themeGray : UIColor.white
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected indexpath \(indexPath)")
        if SharedData.isInDebugMode(), indexPath.section == 0, indexPath.row == 2 {
            displayAlert(alertTitle: "Deleting Cache",
                         alertStyle: .actionSheet,
                         message: "Are you sure you want to delete the local cache?",
                         buttonTitle: "Delete",
                         buttonStyle: .destructive,
                         confirmed: constFn(SharedData.deleteAllDebug))
        }
    }
}
