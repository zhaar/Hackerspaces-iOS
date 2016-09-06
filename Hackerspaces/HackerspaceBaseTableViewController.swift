/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 A table view controller that displays filtered strings (used by other view controllers for simple displaying and filtering of data).
 */

import UIKit
import BrightFutures

enum NetworkState {
    case finished(ParsedHackerspaceData)
    case loading
    case unresponsive(error: NSError)

    var isDone: Bool {
        get {
            switch self {
            case .finished(_): return true
            case _ : return false
            }
        }
    }
    var stateMessage: String { get {
        switch self {
        case .finished(let data): return data.state.open ? "open"  : "closed"
        case .loading: return "loading"
        case .unresponsive(_): return "unresponsive"
        }
        }
    }
}

class HackerspaceBaseTableViewController: UITableViewController, UIViewControllerPreviewingDelegate {

    func refresh(_ sender: UIRefreshControl) {
        dataSource().onComplete { _ in
            sender.endRefreshing()
        }.onSuccess { api in
            self.hackerspaces = api.map { _ in NetworkState.loading }
            api.forEach { (hs, url) in
                SpaceAPI.getParsedHackerspace(url: url, name: hs, fromCache: false).map { NetworkState.finished($0) }
                    .onSuccess { data in
                        self.hackerspaces.updateValue(data, forKey: hs)
                    }
                    .onFailure { error in
                        self.hackerspaces.updateValue(NetworkState.unresponsive(error: error), forKey: hs)
                }
//=======
//        }.onSuccess { api in
//            self.hackerspaces = api.map { _ in NetworkState.Loading }
//            api.forEach { (hs, address) in
//                SpaceAPI.getParsedHackerspace(address, name: hs, fromCache: false).map {NetworkState.Finished($0)}.onSuccess { data in
//                    self.hackerspaces.updateValue(data, forKey: hs)
//                }.onFailure { error in
//                    self.hackerspaces.updateValue(NetworkState.Unresponsive(error: error), forKey: hs)
//>>>>>>> display error as alert when unresponsive
                }
        }
    }

    var dataSource: () -> Future<[String: String], NSError> = { _ in SpaceAPI.loadHackerspaceList(fromCache: true) }

    // MARK: Types

    struct TableViewConstants {
        static let tableViewCellIdentifier = "searchResultsCell"
    }

    // MARK: Properties
    var hackerspaces = [String : NetworkState]() {
        didSet {
            allResults = Array(hackerspaces.keys)
            allResults.sort(by: <)
        }
    }

    func updateHackerspaceStatus(_ status: NetworkState, forKey name: String) -> () {
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
        self.refreshControl?.addTarget(self, action: #selector(HackerspaceBaseTableViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        // Force touch code
        self.refresh(refreshControl!)
        registerForPreviewing(with: self, sourceView: tableView)
    }

    override func viewWillDisappear(_ animated: Bool) {
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

                visibleResults = allResults.filter { filterPredicate.evaluate(with: $0) }
            }

            tableView.reloadData()
        }
    }

    func previewActionCallback() -> () {
        print("callback from hackerspace table")
        return
    }

    // MARK: PreviewingDelegate
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location),
            let hsName = visibleResults.safeIndex(indexPath.row),
            let state = hackerspaces[hsName],
            case .finished(let data) = state else { return nil }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let hackerspaceViewController = storyboard.instantiateViewController(withIdentifier: "HackerspaceDetail") as! SelectedHackerspaceTableViewController
        hackerspaceViewController.prepare(data)
        hackerspaceViewController.previewDeleteAction = self.previewActionCallback
        let cellRect = tableView.rectForRow(at: indexPath)
        let sourceRect = previewingContext.sourceView.convert(cellRect, to: tableView)
        previewingContext.sourceRect = sourceRect
        return hackerspaceViewController
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }

    // MARK: UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewConstants.tableViewCellIdentifier, for: indexPath)
        let name = visibleResults[indexPath.row]
        let state = self.hackerspaces[name]
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = state?.stateMessage ?? "not found"
        cell.selectionStyle = state?.isDone ?? true ? .default : .none

        //workaround a bug where detail is no updated correctly
        //see: http://stackoverflow.com/questions/25987135/ios-8-uitableviewcell-detail-text-not-correctly-updating
        cell.layoutSubviews()
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let hsName = visibleResults[indexPath.row]
        let state = hackerspaces[hsName]
        switch state {
        case .some(.finished(_)): performSegue(withIdentifier: UIConstants.showHSSearch, sender: hsName)
        case .some(.unresponsive(let err)): handleUnresponsiveError(error: err)
        case .some(.loading): print("still loading")
        case .none: print("couldn't find data for hackerspace \"\(hsName)\"")

        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        guard let SHVC = segue.destination as? SelectedHackerspaceTableViewController else {return}
        guard let hackerspaceKey = sender as? String else {return print("cannot prepare for segue, sender was not a string, instead it was: \(sender)")}
        guard let data = hackerspaces[hackerspaceKey]  else {return print("could not find hackerspace with name \(hackerspaceKey)")}
        switch data {
        case .finished(let data): SHVC.prepare(data)
        case _ : print("could not segue into hackerspace with no data")
        }
    }

    func handleUnresponsiveError(error: NSError) -> () {
        let title = "Hackerspace Unresponsive"

        if (error.code == -1 && error.domain == "parse Error") {
            let alert = UIAlertController(title: title, message: "An error occured while parsing data. Either the data is corrupted or the format doesn't comply with SpaceAPI v0.13", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: title, message: "Unknown Error", preferredStyle: .alert)
            let okaction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            let detailaction = UIAlertAction(title: "More details", style: .default, handler: {_ in print("\(error)")})
            alert.addAction(okaction)
            alert.addAction(detailaction)
            present(alert, animated: true, completion: nil)
        }
        
        
    }

}
