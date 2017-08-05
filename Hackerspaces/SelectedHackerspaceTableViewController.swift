import UIKit
import SwiftHTTP
import MapKit
import Swiftz
import BrightFutures
import Haneke

class SelectedHackerspaceTableViewController: UITableViewController {

    // MARK: - Outlets & Actions
    @IBAction func refresh(_ sender: UIRefreshControl) {
        reloadData(.Left(hackerspaceData.apiInfo), fromCache: false, callback: sender.endRefreshing)
    }
    
    @IBOutlet weak var favoriteStatusButton: UIBarButtonItem!
    
    @IBAction func MarkAsFavorite(_ sender: UIBarButtonItem?) {
        if isFavorite {
            SharedData.removeFromFavoritesList(hackerspaceData.apiName)
        } else {
            SharedData.addToFavoriteDictionary((hackerspaceData.apiName, hackerspaceData.apiEndpoint))
        }
        updateFavoriteButton()
    }
    
    let addToFavorites = UIImage(named: "Star-empty")
    let removeFromFavorites = UIImage(named: "Star-full")
    
    func prepare(_ name: String, url: String) {
        self.loadOrigin = Either.Left((name: name, url: url))
    }
    
    func prepare(_ model: ParsedHackerspaceData) {
        self.loadOrigin = Either.Right(model)
    }
    
    var previewDeleteAction : (() -> ())? = nil

    typealias LoadOrigin = Either<(name: String, url: String), ParsedHackerspaceData>
    fileprivate var loadOrigin: LoadOrigin!
    fileprivate var hackerspaceData: ParsedHackerspaceData!
    var isFavorite: Bool {
        get {
            return SharedData.favoritesDictionary().keys.contains(hackerspaceData.apiName)
        }
    }
    
    fileprivate struct storyboard {
        static let CellIdentifier = "Cell"
        static let TitleIdentifier = "TitleCell"
        static let GeneralInfoIdentifier = "GeneralInfoCell"
        static let MapIdentifier = "MapCell"
        static let CustomIdentifier = "CustomCell"
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        refreshControl?.endRefreshing()
    }
    
    // MARK: - View controller lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        reloadData(loadOrigin)
    }
    
    
    func reloadData(_ source: LoadOrigin, fromCache: Bool = true, callback: (() -> Void)? = nil) {
        func applyDataModel(_ hackerspaceData: ParsedHackerspaceData) -> () {
            self.hackerspaceData = hackerspaceData
            self.tableView.reloadData()
            updateFavoriteButton()
        }
        
        switch source {
            case .Right(let m):
                applyDataModel(m)
                callback?()
            case .Left(let (name,url)) :
                SpaceAPI.loadHackerspace(url).map {parseHackerspaceDataModel(json: $0, name: name,url: url)}.filter {$0 != nil}.map{$0!}.onSuccess(callback: applyDataModel).onComplete {_ in
                    self.refreshControl?.endRefreshing()
                    callback?()
            }
        }
    }
    
    func updateFavoriteButton() {
        favoriteStatusButton.image = isFavorite ? removeFromFavorites : addToFavorites
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 0: return 1
        case 1: return 1
        case 2: return 1
        default: return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch(indexPath.section) {
        case 0 : return reuseTitleCell(indexPath)
        case 1 : return reuseGeneralInfoCell(indexPath)
        default : return reuseMapCell(indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case 3: return "Raw Data"
        case 4: return "Custom Data"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 150
        case 1: return 132
        case 2: return 150
        default : return UITableViewAutomaticDimension
        }
    }
    
    func reuseTitleCell(_ indexPath: IndexPath) -> UITableViewCell {
        if let titleCell = tableView.dequeueReusableCell(withIdentifier: storyboard.TitleIdentifier, for: indexPath) as? HackerspaceTitleTableViewCell{
            titleCell.logo.image = nil
            hackerspaceData?.logoURL >>- URL.init(string: ) >>- { titleCell.logo.hnk_setImageFromURL($0) }
            return titleCell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: storyboard.TitleIdentifier, for: indexPath)
        }
    }
    
    func reuseMapCell(_ indexPath: IndexPath) -> UITableViewCell {
        if let mapCell = tableView.dequeueReusableCell(withIdentifier: storyboard.MapIdentifier, for: indexPath) as? HackerspaceMapTableViewCell {
            mapCell.location = hackerspaceData?.location
            return mapCell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: storyboard.TitleIdentifier, for: indexPath)
        }
    }
    
    func reuseGeneralInfoCell(_ indexPath: IndexPath) -> UITableViewCell {
        if let mapCell = tableView.dequeueReusableCell(withIdentifier: storyboard.GeneralInfoIdentifier, for: indexPath) as? HSGeneralInfoTableViewCell {
            if let data = hackerspaceData {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = DateFormatter.Style.medium
                mapCell.HSStatus.text = data.state.open ? "Open" : "Closed"
                mapCell.HSUrl.text = data.websiteURL
                mapCell.HSLastUpdateTime.text = data.state.lastChange >>- { dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval($0))) }
                mapCell.openningMessageLabel.text = hackerspaceData?.state.message
                mapCell.HSUsedAPI.text = "space api v " + (hackerspaceData?.apiVersion ?? "")
             }
            return mapCell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: storyboard.TitleIdentifier, for: indexPath)
        }
    }
    
    override var previewActionItems : [UIPreviewActionItem] {
        let callback: (UIPreviewAction, UIViewController) -> () =  { action, controller in
            self.MarkAsFavorite(nil)
            self.previewDeleteAction >>- {$0()}
        }
        let addToFavs = UIPreviewAction(title: "Add Favorite", style: .default, handler: callback )
        let removeFromFavs = UIPreviewAction(title: "Remove Favorite", style: .destructive, handler: callback)
        return isFavorite ? [removeFromFavs] : [addToFavs]
    }
}
