
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

class FavoriteHackerspaceTableViewController: UITableViewController {

    var generalInfo: [String : JSONDecoder]?
    var customInfo: [String : JSONDecoder]?
    
    private struct storyboard {
        static let CellIdentifier = "Cell"
        static let TitleIdentifier = "TitleCell"
        static let MapIdentifier = "MapCell"
        static let CustomIdentifier = "CustomCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.estimatedRowHeight = tableView.rowHeight
//        tableView.rowHeight = UITableViewAutomaticDimension
        reloadData()
        
    }
    
    
    func reloadData() {
        SpaceAPI.loadHackerspaceAPI("https://fixme.ch/cgi-bin/spaceapi.py").onSuccess { (dict: [String : JSONDecoder]) -> Void in
//            println(dict.description)
            self.navigationController?.navigationBar.topItem?.title = dict["space"]?.string
            let (g, c) = splitDict(dict) { (key, value) in !key.hasPrefix(SpaceAPIConstants.customAPIPrefix) }
            self.generalInfo = g
            self.customInfo = c
            self.tableView.reloadData()
//            self.navigationController?.navigationBar.topItem?.title = dict["space"]
        }
//        let request = HTTPTask()
//        request.GET("https://fixme.ch/cgi-bin/spaceapi.py", parameters: nil, completionHandler: {(response: HTTPResponse) in
//            dispatch_async(dispatch_get_main_queue()) {
//                if let err = response.error {
//                    println("error: \(err.localizedDescription)")
//                } else if let data = response.responseObject as? NSData {
//                    if let dict = JSONDecoder(data).dictionary {
//                        for (k,v) in dict {
//                            self.generalInfo[k] = v
//                        }
//                        self.navigationController?.navigationBar.topItem?.title = dict["space"]?.string
//                    }
//                    self.tableView.reloadData()
//                }
//            }
//        })
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 0: return 1
        case 1: return 1
        case 2: return generalInfo?.count ?? 0
        case 3: return customInfo?.count ?? 0
        default: return 0
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch(indexPath.section) {
        case 0 : return reuseTitleCell(indexPath)
        case 1 : return reuseMapCell(indexPath)
        case 2 :
            let cell = tableView.dequeueReusableCellWithIdentifier(storyboard.CellIdentifier, forIndexPath: indexPath) as! UITableViewCell
            
            if let key = generalInfo?.keys.array[indexPath.row] {
                cell.textLabel?.text = key
                cell.detailTextLabel?.text = generalInfo?[key]?.description
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(storyboard.CustomIdentifier, forIndexPath: indexPath) as! UITableViewCell
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case 2: return "General Info"
        case 3: return "Custom Info"
        default: return nil
        }
    }
    
    func reuseTitleCell(indexPath: NSIndexPath) -> UITableViewCell {
        if let titleCell = tableView.dequeueReusableCellWithIdentifier(storyboard.TitleIdentifier, forIndexPath: indexPath) as? HackerspaceTitleTableViewCell{
            if let logoURL = self.generalInfo?["logo"]?.string {
                let request = HTTPTask()
                request.GET(logoURL, parameters: nil) {
                    (response) in
                    dispatch_async(dispatch_get_main_queue()) {
                        if let err = response.error {
                            println("error: \(err.localizedDescription)")
                        } else if let data = response.responseObject as? NSData {
                            titleCell.logo.image = UIImage(data: data)
                        }
                    }
                }
            }
            titleCell.hackerspaceStatus.text = (generalInfo?["state"]?.dictionary?["open"]?.bool ?? false) ? "open" : "closed"
            titleCell.url.text = generalInfo?["url"]?.string
            return titleCell
        } else {
            println("unknown cell")
            return tableView.dequeueReusableCellWithIdentifier(storyboard.TitleIdentifier, forIndexPath: indexPath) as! UITableViewCell
        }
    }
    
    func reuseMapCell(indexPath: NSIndexPath) -> UITableViewCell {
        if let mapCell = tableView.dequeueReusableCellWithIdentifier(storyboard.MapIdentifier, forIndexPath: indexPath) as? HackerspaceMapTableViewCell {
            generalInfo >>- {MKFunctions.spaceCoordinate($0)} >>- { MKFunctions.centerMapOnLocation(mapCell.map, location: $0) }
            return mapCell
        } else {
            println("unknown cell")
            return tableView.dequeueReusableCellWithIdentifier(storyboard.TitleIdentifier, forIndexPath: indexPath) as! UITableViewCell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch(indexPath.section) {
        case 0: return CGFloat(150)
        case 1: return CGFloat(200)
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
