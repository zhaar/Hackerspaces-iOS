import UIKit
import SwiftHTTP
import JSONJoy
import MapKit
import Swiftz
import BrightFutures
import Haneke

class SelectedHackerspaceTableViewController: UITableViewController {

    // MARK: - Outlets & Actions
    @IBAction func refresh(sender: UIRefreshControl) {
        reloadData(.Left(hackerspaceData.apiInfo), fromCache: false, callback: sender.endRefreshing)
    }
    
    @IBOutlet weak var favoriteStatusButton: UIBarButtonItem!
    
    @IBAction func MarkAsFavorite(sender: UIBarButtonItem?) {
        if isFavorite {
            UserDefaults.removeFromFavoritesList(hackerspaceData.apiName)
        } else {
            UserDefaults.addToFavoriteDictionary((hackerspaceData.apiName, hackerspaceData.apiEndpoint))
        }
        updateFavoriteButton()
    }
    
    let addToFavorites = UIImage(named: "Star-empty")
    let removeFromFavorites = UIImage(named: "Star-full")
    
    func prepare(name: String, url: String) {
        self.loadOrigin = Either.Left((name: name, url: url))
    }
    
    func prepare(model: ParsedHackerspaceData) {
        self.loadOrigin = Either.Right(model)
    }
    
    var previewDeleteAction : (() -> ())? = nil

    typealias LoadOrigin = Either<(name: String, url: String), ParsedHackerspaceData>
    private var loadOrigin: LoadOrigin!
    private var hackerspaceData: ParsedHackerspaceData!
    var isFavorite: Bool {
        get {
            return UserDefaults.favoritesDictionary().keys.contains(hackerspaceData.apiName) ?? false
        }
    }
    
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
        reloadData(loadOrigin)
    }
    
    
    func reloadData(source: LoadOrigin, fromCache: Bool = true, callback: (() -> Void)? = nil) {
        func applyDataModel(hackerspaceData: ParsedHackerspaceData) -> () {
            self.hackerspaceData = hackerspaceData
            self.tableView.reloadData()
            updateFavoriteButton()
        }
        
        switch source {
            case .Right(let m):
                applyDataModel(m)
                callback >>- { $0() }
            case .Left(let (name,url)) :
                SpaceAPI.loadHackerspaceData(url,fromCache: false).map {parseHackerspaceDataModel($0, name: name,url: url)}.filter {$0 != nil}.map{$0!}.onSuccess(callback: applyDataModel).onComplete {_ in
                    self.refreshControl?.endRefreshing()
                    callback >>- { $0() }
            }
        }
    }
    
    func updateFavoriteButton() {
        favoriteStatusButton.image = isFavorite ? removeFromFavorites : addToFavorites
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
                mapCell.HSUsedAPI.text = "space api v " + (hackerspaceData?.apiVersion ?? "")
             }
            return mapCell
        } else {
            return tableView.dequeueReusableCellWithIdentifier(storyboard.TitleIdentifier, forIndexPath: indexPath)
        }
    }
    
    override func previewActionItems() -> [UIPreviewActionItem] {
        let callback: (UIPreviewAction, UIViewController) -> () =  { action, controller in
            self.MarkAsFavorite(nil)
            self.previewDeleteAction >>- {$0()}
        }
        let addToFavs = UIPreviewAction(title: "Add Favorite", style: .Default, handler: callback )
        let removeFromFavs = UIPreviewAction(title: "Remove Favorite", style: .Destructive, handler: callback)
        return isFavorite ? [removeFromFavs] : [addToFavs]
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
