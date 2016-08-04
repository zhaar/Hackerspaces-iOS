
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

enum LoadOrigin {
    case url(String)
    case dataModel(data: HackerspaceDataModel)
}

class SelectedHackerspaceTableViewController: UITableViewController {

    
    // MARK: - Outlets & Actions
    @IBAction func refresh(sender: UIRefreshControl) {
        reloadData(false, callback: { sender.endRefreshing() })
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
    
    func prepare(url: String) {
        self.loadOrigin = LoadOrigin.url(url)
    }
    
    func prepare(model: HackerspaceDataModel) {
        self.loadOrigin = LoadOrigin.dataModel(data: model)
    }
    
    var currentlySelectedHackerspace: String?

    var loadOrigin: LoadOrigin?
    var hackerspaceData: HackerspaceDataModel?
    
    private struct storyboard {
        static let CellIdentifier = "Cell"
        static let TitleIdentifier = "TitleCell"
        static let GeneralInfoIdentifier = "GeneralInfoCell"
        static let MapIdentifier = "MapCell"
        static let CustomIdentifier = "CustomCell"
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        refreshControl?.endRefreshing()
    }
    
    // MARK: - View controller lifecycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        reloadData()
        updateFavoriteButton()
    }
    
    
    func reloadData(fromCache: Bool = true, callback: (() -> Void)? = nil) {
        func loadFromURL(url: String) {
            (fromCache ? SpaceAPI.loadHackerspaceAPI : SpaceAPI.loadHackerspaceAPIFromWeb)(url).onSuccess { dict in
                self.navigationController?.navigationBar.topItem?.title = dict["space"]?.string
                self.hackerspaceData = parseHackerspaceDataModel(dict)
                self.tableView.reloadData()
                callback >>- { $0() }
            }
        }
        
        switch loadOrigin! {
            case .url(let url) : loadFromURL(url)
            case .dataModel(let data) :
                self.hackerspaceData = data
                reloadData()
                updateFavoriteButton()
        }
    }
    
    func updateFavoriteButton() {
        if let h = currentlySelectedHackerspace {
            let isfavorited = Model.sharedInstance.listOfFavorites().contains(h) ?? false
            favoriteStatusButton.enabled = !isfavorited
            favoriteStatusButton.title = isfavorited ? "" : "Favorite"
        } else {
            favoriteStatusButton.enabled = false
            favoriteStatusButton.title = ""
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 0: return 1
        case 1: return 1
        case 2: return 1
        default: return 0
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch(indexPath.section) {
        case 0 : return reuseTitleCell(indexPath)
        case 1 : return reuseGeneralInfoCell(indexPath)
        default : return reuseMapCell(indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case 3: return "Raw Data"
        case 4: return "Custom Data"
        default: return nil
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 150
        case 1: return 132
        case 2: return 150
        default : return UITableViewAutomaticDimension
        }
    }
    
    func reuseTitleCell(indexPath: NSIndexPath) -> UITableViewCell {
        if let titleCell = tableView.dequeueReusableCellWithIdentifier(storyboard.TitleIdentifier, forIndexPath: indexPath) as? HackerspaceTitleTableViewCell{
            titleCell.logo.image = nil
            hackerspaceData?.logoURL >>- { NSURL(string: $0) } >>- { titleCell.logo.hnk_setImageFromURL($0) }
            return titleCell
        } else {
            return tableView.dequeueReusableCellWithIdentifier(storyboard.TitleIdentifier, forIndexPath: indexPath)
        }
    }
    
    func reuseMapCell(indexPath: NSIndexPath) -> UITableViewCell {
        if let mapCell = tableView.dequeueReusableCellWithIdentifier(storyboard.MapIdentifier, forIndexPath: indexPath) as? HackerspaceMapTableViewCell {
            mapCell.location = hackerspaceData?.location
            return mapCell
        } else {
            return tableView.dequeueReusableCellWithIdentifier(storyboard.TitleIdentifier, forIndexPath: indexPath)
        }
    }
    
    func reuseGeneralInfoCell(indexPath: NSIndexPath) -> UITableViewCell {
        if let mapCell = tableView.dequeueReusableCellWithIdentifier(storyboard.GeneralInfoIdentifier, forIndexPath: indexPath) as? HSGeneralInfoTableViewCell {
            if let data = hackerspaceData {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
                mapCell.HSStatus.text = data.state.open ? "Open" : "Closed"
                mapCell.HSUrl.text = data.websiteURL
                mapCell.HSLastUpdateTime.text = data.state.lastChange >>- { dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: NSTimeInterval($0))) }
                mapCell.openningMessageLabel.text = hackerspaceData?.state.message
                mapCell.HSUsedAPI.text = "space api v " + (hackerspaceData?.api ?? "")
             }
            return mapCell
        } else {
            return tableView.dequeueReusableCellWithIdentifier(storyboard.TitleIdentifier, forIndexPath: indexPath)
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
