/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 A table view controller that displays filtered strings (used by other view controllers for simple displaying and filtering of data).
 */

import UIKit
import BrightFutures
import Swiftz

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

        func updateDataSource(get: @escaping () -> [(String, (NetworkState, isVisible: Bool))],
                              set: @escaping ([(String, (NetworkState, isVisible: Bool))]) -> (),
                              api: [String: String]) -> () {
            set(api.map { p in (p.0, (NetworkState.loading, true)) })
            api.forEach { (pair) in
                let (hs, url) = pair
                SpaceAPI.getParsedHackerspace(url: url, name: hs, fromCache: false).map(NetworkState.finished)
                    .onSuccess { finalState in
                        set(addOrUpdate(key: hs, value: (finalState, true), get()))
                    }
                    .onFailure { error in
                        set(addOrUpdate(key: hs, value: (NetworkState.unresponsive(error: error), true), get()))
                }
            }
        }
        dataSource().onComplete(callback: constFn(sender.endRefreshing))
            .onSuccess { api in
                updateDataSource(get: { self.hackerspaces }, set: { self.hackerspaces = $0 }, api: api)
        }
        let customAPI = SharedData.getCustomEndPoints()
        updateDataSource(get: { self.customEndpoints },
                         set: { self.customEndpoints = $0 },
                         api: tuplesAsDict(customAPI))
    }

    var dataSource: () -> Future<[String: String], SpaceAPIError> = { _ in SpaceAPI.loadHackerspaceList(fromCache: true)}

    // MARK: Types

    struct TableViewConstants {
        static let tableViewCellIdentifier = "searchResultsCell"
    }

    // MARK: Properties
    var hackerspaces: [(String, (NetworkState, isVisible: Bool))] = [] {
        didSet {
            hackerspaces.sort(by: {l, r in l.0 < r.0})
            tableView.reloadData()
        }
    }

    func visibleHackerspaces() -> [(String, NetworkState)] {
        return self.hackerspaces.filter { hs in hs.1.1 }.map { hs in (hs.0, hs.1.0)}
    }

    var customEndpoints: [(String, (NetworkState, isVisible: Bool))] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    func visibleEndpoints() -> [(String, NetworkState)] {
        return self.customEndpoints.filter { $0.1.1 }.map { ($0.0, $0.1.0) }
    }

    func hackerspaceStatus(indexPath: IndexPath) -> (String, NetworkState) {
        let isCustom =  !SharedData.getCustomEndPoints().isEmpty && indexPath.section == 0
        return (isCustom ? visibleEndpoints() : visibleHackerspaces())[indexPath.row]
    }

    func updateHackerspaceStatus(_ status: NetworkState, forKey name: String) -> () {
        var cpy = self.hackerspaces
        if let idx = cpy.index(where: { $0.0 == name }) {
            cpy[idx] = (name, (status, cpy[idx].1.isVisible))
        }
        self.hackerspaces = cpy
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        } 
        self.refreshControl?.addTarget(self, action: #selector(HackerspaceBaseTableViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        // Force touch code
        self.refresh(refreshControl!)
        registerForPreviewing(with: self, sourceView: tableView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        refreshControl?.endRefreshing()
    }

    /// A `nil` / empty filter string means show all results. Otherwise, show only results containing the filter.
    var filterString: String? = nil {
        didSet {

            if let str = filterString , !str.isEmpty {
                let filterByName = { (hs: (String, (NetworkState, Bool))) -> (String, (NetworkState, Bool)) in
                    let (name, (network, _)) = hs
                    return (name, (network, name.contains(str)))
                }
                hackerspaces = hackerspaces.map(filterByName)
                customEndpoints = customEndpoints.map(filterByName)
            } else {
                hackerspaces = hackerspaces.map { hs in (hs.0, (hs.1.0, isVisible: true)) }
                customEndpoints = customEndpoints.map { hs in (hs.0, (hs.1.0, isVisible: true)) }
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
            case (_, .finished(let data)) = hackerspaceStatus(indexPath: indexPath) else { return nil }
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return SharedData.getCustomEndPoints().isEmpty ? 1 : 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if SharedData.getCustomEndPoints().isEmpty {
            return nil
        } else {
            return section == 0 ? "Custom Endpoints" : "Space API"
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let isCustom = !SharedData.getCustomEndPoints().isEmpty && section == 0
        return isCustom ? visibleEndpoints().count : visibleHackerspaces().count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewConstants.tableViewCellIdentifier, for: indexPath)
        let (name, state) = hackerspaceStatus(indexPath: indexPath)

        cell.textLabel?.text = name
        cell.detailTextLabel?.text = state.stateMessage
        cell.detailTextLabel?.textColor = UIColor.gray
        cell.selectionStyle = state.isDone ? .default : .none

        //workaround a bug where detail is no updated correctly
        //see: http://stackoverflow.com/questions/25987135/ios-8-uitableviewcell-detail-text-not-correctly-updating
        cell.layoutSubviews()
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (hsName, state) = hackerspaceStatus(indexPath: indexPath)
        switch state {
        case .finished(_): performSegue(withIdentifier: UIConstants.showHSSearch.rawValue, sender: hsName)
        case .unresponsive(let err) where SharedData.isInDebugMode(): handleUnresponsiveError(error: err)
        case .unresponsive: break
        case .loading: print("still loading")

        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        switch segue.destination {
        case let SHVC as SelectedHackerspaceTableViewController :
            guard let hackerspaceKey = sender as? String else {return print("cannot prepare for segue, sender was not a string, instead it was: \(sender)")}
            guard let data = (get(hackerspaces, key: hackerspaceKey) ?? get(customEndpoints, key: hackerspaceKey))  else {return print("could not find hackerspace with name \(hackerspaceKey)")}
            switch data.0 {
            case .finished(let data): SHVC.prepare(data)
            case _ : print("could not segue into hackerspace with no data")
            }
        case let errorVC as DisplayErrorViewController :
            errorVC.prepare(message: sender as! String, title: "Error details")
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
