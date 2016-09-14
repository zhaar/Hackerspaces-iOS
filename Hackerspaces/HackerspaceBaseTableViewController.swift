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
    case Unresponsive(error: SpaceAPIError)
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
                SpaceAPI.getParsedHackerspace(address, name: hs, fromCache: false).map {NetworkState.Finished($0)}.onSuccess { data in
                    self.hackerspaces.updateValue(data, forKey: hs)
                }.onFailure { error in
                    self.hackerspaces.updateValue(NetworkState.Unresponsive(error: error), forKey: hs)
                }
            }
        }
    }
    
    var dataSource: () -> Future<[String: String], SpaceAPIError> = { _ in SpaceAPI.loadHackerspaceList(fromCache: true)}

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
        // Force touch code
        self.refresh(refreshControl!)
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
    
    func previewActionCallback() -> () {
        print("callback from hackerspace table")
        return
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
        hackerspaceViewController.previewDeleteAction = self.previewActionCallback
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
            case .Some(.Finished(_)): performSegueWithIdentifier(UIConstants.showHSSearch.rawValue, sender: hsName)
            case .Some(.Unresponsive(let err)):  handleUnresponsiveError(err)
            case .Some(.Loading): print("still loading")
            case .None: print("couldn't find data for hackerspace \"\(hsName)\"")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        switch segue.destinationViewController {
        case let SHVC as SelectedHackerspaceTableViewController :
            guard let hackerspaceKey = sender as? String else {return print("cannot prepare for segue, sender was not a string, instead it was: \(sender)")}
            guard let data = hackerspaces[hackerspaceKey]  else {return print("could not find hackerspace with name \(hackerspaceKey)")}
            switch data {
            case .Finished(let data): SHVC.prepare(data)
            case _ : print("could not segue into hackerspace with no data")
            }
        case let errorVC as DisplayErrorViewController :
            errorVC.prepare(sender as! String)
        case _: return
        }
    }
    
    func handleUnresponsiveError(error: SpaceAPIError) -> () {
        
        func messageHandler(err: SpaceAPIError) -> (String, String?) {
            switch error {
            case .DataCastError(data: let data):
                return ("Could not parse data as JSON", data.description)
            case .HTTPRequestError(error: _):
                return ("Unknown HTTP error", nil)
            case .ParseError(data: let data):
                let json = NSString(data: data, encoding: NSUTF16StringEncoding) ?? "<Encoding error>"
                return ("An error occured while parsing data. Maybe the data doesn't comply with SpaceAPI v0.13", "\(JSONDecoder(data).print())\nrecieved data:  \(json)")
            case .UnknownError(error: let error):
                return ("Unknown error", error.description)
            }
        }
        
        let title = "Hackerspace Unresponsive"
        var actions:[UIAlertAction] = [UIAlertAction(title: "Ok", style: .Default, handler: nil)]
        let (msg, sender) = messageHandler(error)
        sender.forEach { s in actions.append(UIAlertAction(title: "More details", style: .Default, handler: {_ in
            self.performSegueWithIdentifier(UIConstants.showErrorDetail.rawValue, sender: s)
        }))}
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        actions.foreach(alert.addAction)
        presentViewController(alert, animated: true, completion: nil)
    }
}
