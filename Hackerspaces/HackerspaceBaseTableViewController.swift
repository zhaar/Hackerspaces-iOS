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
    case unresponsive(error: SpaceAPIError)

    var isDone: Bool {
        get {
            switch self {
            case .finished(_): return true
            case _ : return false
            }
        }
    }
    var stateMessage: String {

        switch self {
        case .finished(let data): return data.state.open ? "open"  : "closed"
        case .loading: return "loading"
        case .unresponsive(_): return "unresponsive"
        }
    }
}

class HackerspaceBaseTableViewController: UITableViewController, UIViewControllerPreviewingDelegate {

    func refresh(_ sender: UIRefreshControl) {
        dataSource().onComplete(callback: constFn(sender.endRefreshing))
            .onSuccess { api in
                self.hackerspaces = api.map { _ in NetworkState.loading }
                api.forEach { (hs, url) in
                    SpaceAPI.getParsedHackerspace(url: url, name: hs, fromCache: false).map(NetworkState.finished)
                        .onSuccess { data in
                            self.hackerspaces.updateValue(data, forKey: hs)
                        }
                        .onFailure { error in
                            self.hackerspaces.updateValue(NetworkState.unresponsive(error: error), forKey: hs)
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
        case .some(.finished(_)): performSegue(withIdentifier: UIConstants.showHSSearch.rawValue, sender: hsName)
        case .some(.unresponsive(let err)) where SharedData.isInDebugMode(): handleUnresponsiveError(error: err)
        case .some(.unresponsive): break
        case .some(.loading): print("still loading")
        case .none: print("couldn't find data for hackerspace \"\(hsName)\"")

        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        switch segue.destination {
        case let SHVC as SelectedHackerspaceTableViewController :
            guard let hackerspaceKey = sender as? String else {return print("cannot prepare for segue, sender was not a string, instead it was: \(sender)")}
            guard let data = hackerspaces[hackerspaceKey]  else {return print("could not find hackerspace with name \(hackerspaceKey)")}
            switch data {
            case .finished(let data): SHVC.prepare(data)
            case _ : print("could not segue into hackerspace with no data")
            }
        case let errorVC as DisplayErrorViewController :
            errorVC.prepare(message: sender as! String)
        case _: return

        }
    }

    func handleUnresponsiveError(error: SpaceAPIError) -> () {

        func messageHandler(err: SpaceAPIError) -> (String, String?) {
            switch error {
            case .dataCastError(data: let data):
                return ("Could not parse data as JSON", data.description)
            case .httpRequestError(error: _):
                return ("Unknown HTTP error", nil)
            case .parseError(let json):
                return ("An error occured while parsing data. Maybe the data doesn't comply with SpaceAPI v0.13", "\ncould not parse:  \(json)")
            case .unknownError(error: let error):
                return ("Unknown error", error.localizedDescription)

            }
        }

        let title = "Hackerspace Unresponsive"
        var actions:[UIAlertAction] = [UIAlertAction(title: "Ok", style: .default, handler: nil)]

        let (msg, sender) = messageHandler(err: error)
        if let s = sender {
            actions.append(UIAlertAction(title: "More details", style: .default, handler: {_ in
                self.performSegue(withIdentifier: UIConstants.showErrorDetail.rawValue, sender: s)
            }))
        }
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        actions.foreach(alert.addAction)
        //FIXME: There is a bug around here, the "More detail" button is added twice to the array but only once in the alert
        actions.append(UIAlertAction(title: "More details", style: .default, handler: {_ in
            self.performSegue(withIdentifier: UIConstants.showErrorDetail.rawValue, sender: error.localizedDescription)
        }))
        present(alert, animated: true, completion: nil)
        
    }
}
