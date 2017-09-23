//
//  TableViewController.swift
//  Hackerspaces
//
//  Created by zephyz on 24.09.17.
//  Copyright © 2017 Fixme. All rights reserved.
//

import UIKit

class EndPointTableViewController: UITableViewController {

    var source: [(String, String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.setEditing(true, animated: true)
        //        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addNewEndpoint))
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
            cell.textLabel?.text = "Name"
            cell.detailTextLabel?.text = "Url"
        } else {
            cell.textLabel?.text = source[indexPath.row].0
            cell.detailTextLabel?.text = source[indexPath.row].1
        }

        return cell
    }


    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return indexPath.section == 0 ? .insert : .delete
    }


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            source.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            performSegue(withIdentifier: "ShowAddEndpoint", sender: nil)
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
