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

    let hiddenRange = 2..<5
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
            displayAlert(alertTitle: R.string.localizable.advancedModeEngagedTitle(),
                         message: R.string.localizable.advancedModeEngagedMessage(),
                         buttonTitle: R.string.localizable.ok(),
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
        let rows = hiddenRange.map { IndexPath.init(row: $0, section: 0) }
        let refreshTitle = isEnabled ? R.string.localizable.pullToEngage()
                                     : R.string.localizable.pullToDisengage()
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
            return hiddenRange.upperBound
        } else {
            return hiddenRange.lowerBound
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = SharedData.isInDarkMode() ? UIColor.themeGray : UIColor.white
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if SharedData.isInDebugMode(), indexPath.section == 0, indexPath.row == 3 {
            displayAlert(alertTitle: R.string.localizable.deleteCacheTitle(),
                         alertStyle: .actionSheet,
                         message: R.string.localizable.deleteCacheMessage(),
                         buttonTitle: R.string.localizable.delete(),
                         buttonStyle: .destructive,
                         confirmed: constFn(SpaceAPI.deleteCache))
        }
    }
}
