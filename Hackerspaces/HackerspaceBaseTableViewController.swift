/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    A table view controller that displays filtered strings (used by other view controllers for simple displaying and filtering of data).
*/

import UIKit
import JSONJoy
import BrightFutures

enum NetworkState {
    case Finished(ParsedHackerspaceData)
    case Loading
    case Unresponsive(errorMessage: String)
    var isDone: Bool {
        get {
            switch self {
            case .Finished(_): return true
            case _ : return false
            }
        }
    }
    var stateMessage: String { get {
            switch self {
            case .Finished(let data): return data.state.open ? "open"  : "closed"
            case .Loading: return "loading"
            case .Unresponsive(_): return "unresponsive"
            }
        }
    }
}

class HackerspaceBaseTableViewController: UITableViewController, UIViewControllerPreviewingDelegate {
        
    func refresh(sender: UIRefreshControl) {
        dataSource().onComplete { _ in
            sender.endRefreshing()
        }.onSuccess { api in
            self.hackerspaces = api.map { _ in NetworkState.Loading }
            api.forEach { (hs, address) in
                SpaceAPI.getParsedHackerspace(address, name: hs).map {NetworkState.Finished($0)}.onSuccess { data in
                    self.hackerspaces.updateValue(data, forKey: hs)
                    }.onFailure { error in
                        self.updateHackerspaceStatus(NetworkState.Unresponsive(errorMessage: "error while loading: \(error)"), forKey: hs)
                }
            }
        }
    }
    
    var dataSource: () -> Future<[String: String], NSError> = SpaceAPI.loadAPIFromWeb

    // MARK: Types
    
    struct TableViewConstants {
        static let tableViewCellIdentifier = "searchResultsCell"
    }
    
    // MARK: Properties
    var hackerspaces = [String : NetworkState]() {
        didSet {
            allResults = Array(hackerspaces.keys)
            allResults.sortInPlace(<)
        }
    }
    
    func updateHackerspaceStatus(status: NetworkState, forKey name: String) -> () {
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
        self.refreshControl?.addTarget(self, action: #selector(HackerspaceBaseTableViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl?.beginRefreshing()
        self.refresh(refreshControl!)
        // Force touch code
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
    
    // MARK: PreviewingDelegate
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRowAtPoint(location) else { return nil }
        let hsName = visibleResults[indexPath.row]
        guard let state = hackerspaces[hsName] else { return nil }
        guard case .Finished(let data) = state else {return nil}
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let hackerspaceViewController = storyboard.instantiateViewControllerWithIdentifier("HackerspaceDetail") as! SelectedHackerspaceTableViewController
        hackerspaceViewController.prepare(data)
        let cellRect = tableView.rectForRowAtIndexPath(indexPath)
        let sourceRect = previewingContext.sourceView.convertRect(cellRect, toView: tableView)
        previewingContext.sourceRect = sourceRect
        return hackerspaceViewController
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        showViewController(viewControllerToCommit, sender: self)
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleResults.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewConstants.tableViewCellIdentifier, forIndexPath: indexPath)
        let name = visibleResults[indexPath.row]
        let state = self.hackerspaces[name]
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = state?.stateMessage ?? "not found"
        cell.selectionStyle = state?.isDone ?? true ? .Default : .None

        //workaround a bug where detail is no updated correctly
        //see: http://stackoverflow.com/questions/25987135/ios-8-uitableviewcell-detail-text-not-correctly-updating
        cell.layoutSubviews()
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let hsName = visibleResults[indexPath.row]
        let state = hackerspaces[hsName]
        switch state {
            case .Some(.Finished(_)): performSegueWithIdentifier(UIConstants.showHSSearch, sender: hsName)
            case .Some(.Unresponsive(let message)):  print("trying to segue into unresponsive hackerspace: \(message)")
            case .Some(.Loading): print("still loading")
            case .None: print("couldn't find data for hackerspace \"\(hsName)\"")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        guard let SHVC = segue.destinationViewController as? SelectedHackerspaceTableViewController else {return}
        guard let hackerspaceKey = sender as? String else {return print("cannot prepare for segue, sender was not a string, instead it was: \(sender)")}
        guard let data = hackerspaces[hackerspaceKey]  else {return print("could not find hackerspace with name \(hackerspaceKey)")}
        switch data {
            case .Finished(let data): SHVC.prepare(data)
            case _ : print("could not segue into hackerspace with no data")
        }
    }

}
