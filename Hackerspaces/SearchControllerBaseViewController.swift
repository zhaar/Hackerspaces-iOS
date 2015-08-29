/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    A table view controller that displays filtered strings (used by other view controllers for simple displaying and filtering of data).
*/

import UIKit
import JSONJoy

class SearchControllerBaseViewController: UITableViewController {
    
    @IBAction func refresh(sender: UIRefreshControl) {
        SpaceAPI.getHackerspaceOpens(fromCache: false).onSuccess { api in
            self.hackerspaces = api
            sender.endRefreshing()
        }
    }

    // MARK: Types
    
    struct TableViewConstants {
        static let tableViewCellIdentifier = "searchResultsCell"
    }
    
    // MARK: Properties
    var hackerspaces = [String : Bool]() {
        didSet {
            allResults = hackerspaces.keys.array
            allResults.sort(<)
        }
    }
    
    var spaceAPI = [String : String]()
    
    var allResults = [String]() {
        didSet {
            visibleResults = allResults
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SpaceAPI.loadAPI().onSuccess {
            self.spaceAPI = $0
        }.andThen { _ in
            SpaceAPI.getHackerspaceOpens().onSuccess {
                self.hackerspaces = $0
            }
        }
    }

    lazy var visibleResults: [String] = self.allResults

    /// A `nil` / empty filter string means show all results. Otherwise, show only results containing the filter.
    var filterString: String? = nil {
        didSet {
            if filterString == nil || filterString!.isEmpty {
                visibleResults = allResults
            }
            else {
                // Filter the results using a predicate based on the filter string.
                let filterPredicate = NSPredicate(format: "self contains[c] %@", argumentArray: [filterString!])

                visibleResults = allResults.filter { filterPredicate.evaluateWithObject($0) }
            }

            tableView.reloadData()
        }
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleResults.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewConstants.tableViewCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        let name = visibleResults[indexPath.row]
        let isOpen = self.hackerspaces[name]
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = ((isOpen ?? false) ? UIConstants.SpaceIsOpenMark : "")
        //workaround a bug where detail is no updated correctly
        //see: http://stackoverflow.com/questions/25987135/ios-8-uitableviewcell-detail-text-not-correctly-updating
        cell.layoutSubviews()
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        Model.sharedInstance.favoriteHackerspaceURL = self.spaceAPI[visibleResults[indexPath.row]]
        self.tabBarController?.selectedIndex = 0
    }

}
