/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    A table view controller that displays filtered strings (used by other view controllers for simple displaying and filtering of data).
*/

import UIKit
import JSONJoy
import BrightFutures

extension SearchControllerBaseViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRowAtPoint(location) else { return nil }
        let hsName = visibleResults[indexPath.row]
        guard let state = hackerspaces[hsName] else { return nil }
        if state == .Unresponsive || state == .Loading { return nil }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let hackerspaceViewController = storyboard.instantiateViewControllerWithIdentifier("HackerspaceDetail") as! SelectedHackerspaceTableViewController
        hackerspaceViewController.prepare(url: spaceAPI[hsName]! , model: parsedHackerspaceStates[hsName]!)
        let cellRect = tableView.rectForRowAtIndexPath(indexPath)
        let sourceRect = previewingContext.sourceView.convertRect(cellRect, toView: tableView)
        previewingContext.sourceRect = sourceRect
        return hackerspaceViewController
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        showViewController(viewControllerToCommit, sender: self)
    }
}

enum SpaceOpeningState: String {
    case Open = "open"
    case Closed = "closed"
    case Loading = "loading"
    case Unresponsive = "unresponsive"
}

extension Bool {
    var asOpeningState: SpaceOpeningState {
        get {
            return self ? SpaceOpeningState.Open : SpaceOpeningState.Closed
        }
    }
}

class SearchControllerBaseViewController: UITableViewController {
    
    @IBAction func refresh(sender: UIRefreshControl) {
        SpaceAPI.loadAPIFromWeb().onSuccess { api in
            self.spaceAPI = api
            sender.endRefreshing()
        }
    }

    // MARK: Types
    
    struct TableViewConstants {
        static let tableViewCellIdentifier = "searchResultsCell"
    }
    
    // MARK: Properties
    var hackerspaces = [String : SpaceOpeningState]() {
        didSet {
            allResults = Array(hackerspaces.keys)
            allResults.sortInPlace(<)
        }
    }
    
    var parsedHackerspaceStates: [String: HackerspaceDataModel] = [String: HackerspaceDataModel]()
    
    var spaceAPI = [String : String]() {
        didSet {
            self.hackerspaces = spaceAPI.map { _ in SpaceOpeningState.Loading }
            spaceAPI.forEach { (hs, address) in
                let jsonData = SpaceAPI.loadHackerspaceAPI(address).map(parseHackerspaceDataModel)
                jsonData.filter {$0 != nil}.map {$0!}.onSuccess { data in
                        self.parsedHackerspaceStates.updateValue(data, forKey: hs)
                        let status = data.state.open
                        self.updateHackerspaceStatus(status.asOpeningState, forKey: hs)
                    }.onFailure { error in
                        self.updateHackerspaceStatus(SpaceOpeningState.Unresponsive, forKey: hs)
                    }
                
            }
        }
    }
    
    func updateHackerspaceStatus(status: SpaceOpeningState, forKey name: String) -> () {
        var cpy = self.hackerspaces
        cpy.updateValue(status, forKey: name)
        self.hackerspaces = cpy
    }
    
    var allResults = [String]() {
        didSet {
            visibleResults = allResults
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl?.beginRefreshing()
        SpaceAPI.loadAPI().onSuccess {
            self.spaceAPI = $0
        }
        
//      Force touch code
        registerForPreviewingWithDelegate(self, sourceView: tableView)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        refreshControl?.endRefreshing()
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
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewConstants.tableViewCellIdentifier, forIndexPath: indexPath)
        let name = visibleResults[indexPath.row]
        let isOpen = self.hackerspaces[name]
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = (isOpen ?? SpaceOpeningState.Closed).rawValue
        //workaround a bug where detail is no updated correctly
        //see: http://stackoverflow.com/questions/25987135/ios-8-uitableviewcell-detail-text-not-correctly-updating
        cell.layoutSubviews()
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let hsName = visibleResults[indexPath.row]
        let state = hackerspaces[hsName].map { $0 == .Unresponsive || $0 == .Loading }
        switch state {
            case .Some(true): print("trying to segue into unresponsive hackerspace")
            case .Some(false): performSegueWithIdentifier(UIConstants.showHSSearch, sender: hsName)
            case .None: print("couldn't find data for hackerspace \"\(hsName)\"")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if let SHVC = segue.destinationViewController as? SelectedHackerspaceTableViewController {
            let hackerspaceKey = sender as! String
            let parsedData = parsedHackerspaceStates[hackerspaceKey]!
            let hackerspaceURL = spaceAPI[hackerspaceKey]!
            SHVC.prepare(url: hackerspaceURL , model: parsedData)
        }
    }

}
