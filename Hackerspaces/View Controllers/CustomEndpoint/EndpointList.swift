//
//  TableViewController.swift
//  Hackerspaces
//
//  Created by zephyz on 24.09.17.
//  Copyright © 2017 Fixme. All rights reserved.
//

import UIKit

class EditMode {
    let name: String
    let url: String
    init(name: String, url: String) {
        self.name = name
        self.url = url
    }
}

class EndPointTableViewController: UITableViewController {

    var source: [(String, String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.setEditing(true, animated: true)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        source = SharedData.customEndpoints.emptyGet()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : source.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "cellID"
        let cell: UITableViewCell
        if let dequeued = tableView.dequeueReusableCell(withIdentifier: cellID) {
            cell = dequeued
        } else {
            cell = UITableViewCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellID)
        }
        if indexPath.section == 0 {
            cell.textLabel?.text = R.string.localizable.name()
            cell.detailTextLabel?.text = "Url"
        } else {
            cell.textLabel?.text = source[indexPath.row].0
            cell.detailTextLabel?.text = source[indexPath.row].1
        }

        cell.detailTextLabel?.textColor = Theme.conditionalForegroundColor
        cell.textLabel?.textColor = Theme.conditionalForegroundColor
        return cell
    }


    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return indexPath.section == 0 ? .insert : .delete
    }


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .insert {
            performSegue(withIdentifier: "ShowAddEndpoint", sender: nil)
        }
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 1 {
            let editAction = UITableViewRowAction.init(style: .normal, title: R.string.localizable.edit(), handler: { (_, idx) in
                let (name, url) = self.source[idx.row]
                self.performSegue(withIdentifier: "ShowAddEndpoint", sender: EditMode(name: name, url: url))
            }
            )
            let deleteAction = UITableViewRowAction.init(style: .destructive, title: R.string.localizable.delete(), handler: { (_, idx) in
                self.source.remove(at: idx.row)
                SharedData.customEndpoints.deleteRow(at: idx.row)
                tableView.deleteRows(at: [idx], with: .fade)
            })
            return [deleteAction, editAction]
        } else {
            return []
        }
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? AddEndpointViewController else { return }
        if let editValues = sender as? EditMode {
            vc.presetName = editValues.name
            vc.presetURL = editValues.url
            vc.confirm = { (newName, newURL) in
                self.source = remove(from: self.source, key: editValues.name)
                self.source = addOrUpdate(key: newName, value: newURL, self.source)
                SharedData.customEndpoints.set(data: self.source)
            }
        } else {
            vc.confirm = { (newName, newURL) in
                self.source.append((newName, newURL))
                SharedData.customEndpoints.set(data: self.source)
            }
        }
    }

}
