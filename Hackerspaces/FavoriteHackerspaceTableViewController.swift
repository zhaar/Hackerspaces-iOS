
//
//  FavoriteHackerspaceTableViewController.swift
//  Hackerspaces
//
//  Created by zephyz on 20/08/15.
//  Copyright (c) 2015 Fixme. All rights reserved.
//

import UIKit
import SwiftHTTP
import JSONJoy
import MapKit
import Swiftz
import BrightFutures
import Haneke

class FavoriteHackerspaceTableViewController: UITableViewController {

    
    // MARK: - Outlets & Actions
    @IBAction func refresh(sender: UIRefreshControl) {
        reloadData(fromCache: false, callback: { sender.endRefreshing() })
    }
    
    @IBOutlet weak var favoriteStatusButton: UIBarButtonItem! {
        didSet {
            updateFavoriteButton()
        }
    }
    
    @IBAction func MarkAsFavorite(sender: UIBarButtonItem) {
        if let h = currentlySelectedHackerspace {
            Model.sharedInstance.addToFavorites(h)
            updateFavoriteButton()
        }
    }
    
    var currentlySelectedHackerspace: String? {
        get {
            return Model.sharedInstance.selectedHackerspace
        }
    }
    
    var generalInfo: [String : JSONDecoder]?
    var customInfo: [String : JSONDecoder]?
    var hackerspaceData: HackerspaceDataModel?
    
    private struct storyboard {
        static let CellIdentifier = "Cell"
        static let TitleIdentifier = "TitleCell"
        static let GeneralInfoIdentifier = "GeneralInfoCell"
        static let MapIdentifier = "MapCell"
        static let CustomIdentifier = "CustomCell"
    }

    
    // MARK: - View controller lifecycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
        updateFavoriteButton()

    }
    
    func reloadData(fromCache: Bool = true, callback: (() -> Void)? = nil) {
        if let url = Model.sharedInstance.selectedHackerspace {
            (fromCache ? SpaceAPI.loadHackerspaceAPI : SpaceAPI.loadHackerspaceAPIFromWeb)(url).onSuccess { dict in
                self.navigationController?.navigationBar.topItem?.title = dict["space"]?.string
                let (g, c) = dict.split { (key: String, value: JSONDecoder) -> Bool in !key.hasPrefix(SpaceAPIConstants.customAPIPrefix) }
                self.generalInfo = g
                self.customInfo = c
                self.hackerspaceData = parseHackerspaceDataModel(dict)
                self.tableView.reloadData()
                callback >>- { $0() }
            }
        }
    }
    
    func updateFavoriteButton() {
        if let h = currentlySelectedHackerspace {
            let isfavorited = contains(Model.sharedInstance.listOfFavorites(),h ) ?? false
            favoriteStatusButton.enabled = !isfavorited
            favoriteStatusButton.title = isfavorited ? "" : "favorite"
            println("hackerspace selected button is " + (!isfavorited ? "disabled" : "enabled"))
        } else {
            println("currently no hackerspace selected, favorite disabled")
            favoriteStatusButton.enabled = false
            favoriteStatusButton.title = ""
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4 + (((customInfo?.count > 0) ?? false) ? 1 : 0)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 0: return 1
        case 1: return 1
        case 2: return 1
        case 3: return generalInfo?.count ?? 0
        case 4: return customInfo?.count ?? 0
        default: return 0
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch(indexPath.section) {
        case 0 : return reuseTitleCell(indexPath)
        case 1 : return reuseGeneralInfoCell(indexPath)
        case 2 : return reuseMapCell(indexPath)
        case 3 : return reuseRawDataCell(indexPath)
        default: return reuseCustomDataCell(indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case 3: return "Raw Data"
        case 4: return "Custom Data"
        default: return nil
        }
    }
    
    func reuseTitleCell(indexPath: NSIndexPath) -> UITableViewCell {
        if let titleCell = tableView.dequeueReusableCellWithIdentifier(storyboard.TitleIdentifier, forIndexPath: indexPath) as? HackerspaceTitleTableViewCell{
            titleCell.logo.image = nil
            generalInfo?["logo"]?.string >>- { NSURL(string: $0) } >>- { titleCell.logo.hnk_setImageFromURL($0) }
            return titleCell
        } else {
            println("unknown cell")
            return tableView.dequeueReusableCellWithIdentifier(storyboard.TitleIdentifier, forIndexPath: indexPath) as! UITableViewCell
        }
    }
    
    func reuseMapCell(indexPath: NSIndexPath) -> UITableViewCell {
        if let mapCell = tableView.dequeueReusableCellWithIdentifier(storyboard.MapIdentifier, forIndexPath: indexPath) as? HackerspaceMapTableViewCell {
            generalInfo >>- { SpaceAPI.extractLocationInfo($0)} >>- { mapCell.location = $0 }
            return mapCell
        } else {
            println("unknown cell")
            return tableView.dequeueReusableCellWithIdentifier(storyboard.TitleIdentifier, forIndexPath: indexPath) as! UITableViewCell
        }
    }
    
    func reuseGeneralInfoCell(indexPath: NSIndexPath) -> UITableViewCell {
        if let mapCell = tableView.dequeueReusableCellWithIdentifier(storyboard.GeneralInfoIdentifier, forIndexPath: indexPath) as? HSGeneralInfoTableViewCell {
            if let info = generalInfo {
                mapCell.HSStatus.text = SpaceAPI.extractIsSpaceOpen(info) ? "Open" : "Closed"
                mapCell.HSUrl.text = hackerspaceData?.websiteURL
                mapCell.HSLastUpdateTime.text = hackerspaceData?.state.lastChange?.description
                mapCell.openningMessageLabel.text = hackerspaceData?.state.message
                mapCell.HSUsedAPI.text = "space api v " + (hackerspaceData?.api ?? "")
             }
            return mapCell
        } else {
            println("unknown cell")
            return tableView.dequeueReusableCellWithIdentifier(storyboard.TitleIdentifier, forIndexPath: indexPath) as! UITableViewCell
        }
    }
    
    func reuseRawDataCell(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(storyboard.CellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        if let key = generalInfo?.keys.array[indexPath.row] {
            cell.textLabel?.text = key
            cell.detailTextLabel?.text = generalInfo?[key]?.description
        }
        return cell
    }
    
    func reuseCustomDataCell(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(storyboard.CustomIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        if let key = customInfo?.keys.array[indexPath.row] {
            cell.textLabel?.text = key
            cell.detailTextLabel?.text = customInfo?[key]?.description
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch(indexPath.section) {
        case 0: return CGFloat(150)
        case 1: return CGFloat(138)
        case 2: return CGFloat(200)
        default: return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
