/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    A view controller that demonstrates how to present a search controller's search bar within a navigation bar.
*/

import UIKit

class SearchBarEmbeddedInNavigationBarViewController: SearchResultsViewController , UISearchBarDelegate {
    // MARK: Properties
    
    // `searchController` is set in viewDidLoad(_:).
    var searchController: UISearchController!

    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create the search results view controller and use it for the UISearchController.
//        let searchResultsController = storyboard!.instantiateViewControllerWithIdentifier(SearchResultsViewController.StoryboardConstants.identifier) as! SearchResultsViewController
        
        // Create the search controller and make it perform the results updating.
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        
        // Configure the search controller's search bar. For more information on how to configure
        // search bars, see the "Search Bar" group under "Search".
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.placeholder = NSLocalizedString("Search", comment: "")
        
        // Include the search bar within the navigation bar.
        navigationItem.titleView = searchController.searchBar

        definesPresentationContext = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filterString = nil
    }
}
