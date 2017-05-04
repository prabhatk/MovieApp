//
//  ViewController.swift
//  Movie
//
//  Created by Prabhat Kasera on 29/04/17.
//  Copyright © 2017 Prabhat Kasera. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource,UITableViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var ErrorLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var ErrorLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var suggestionTableView: UITableView!
    
    @IBOutlet weak var SearchBar: UISearchBar!
    var imageDownloadsInProgress = NSMutableDictionary() // tracking downloading items.
    var entries : NSMutableArray = NSMutableArray() // record array
    var suggestionArray = NSMutableArray() // getting suggestion array from nsuser default.
    let refreshControl = UIRefreshControl() // pull to refresh
    var searchString : String = "" // it will keep track if we are already searching for the keywords.
    
    let appDelegate  = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()

        let MovieCellNib = UINib.init(nibName: "MovieListCell", bundle: nil)
        tableView.register(MovieCellNib, forCellReuseIdentifier: "MovieCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0
        self.suggestionTableView.isHidden = true
        
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(ViewController.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        loader.stopAnimating()
        ErrorLabelHeight.constant = 0;
        NotificationCenter.default.addObserver(self, selector: #selector(internetRechabilityChanged), name: ReachabilityChangedNotification, object: nil)
        internetRechabilityChanged()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(obj:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(obj:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
    }
    //keyboard handiling
    func keyboardWillShow (obj : Any) {
        self.suggestionTableView.isHidden = false
    }
    func keyboardWillHide (obj : Any) {
        self.suggestionTableView.isHidden = true
    }
    //reachablity change 
    // in case of no network
    // network
    func internetRechabilityChanged() {
        
        if appDelegate.reachability.isReachable {
            ErrorLabelHeight.constant = 0;
        }
        else {
            ErrorLabelHeight.constant = 28;
        }
        UIView.animate(withDuration: 0.2) { 
            self.view.layoutIfNeeded()
        }
    }

    // pull to refresh delegate.
    func refresh() {
        // Code to refresh table view
        if searchString.trimmingCharacters(in: .whitespacesAndNewlines).characters.count == 0 {
            refreshControl.endRefreshing()
        }
        if appDelegate.reachability.isReachable == false {
             refreshControl.endRefreshing()
            loader.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }
        else {
            searchMovieWith(name: searchString)
        }
    }
    //search movie with the given name if name of the search string is same than conutn will continue like 0..20, 20.. 40 ...etc
    //if search string is different thencount will start from ZERO
    func searchMovieWith(name:String) {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).characters.count == 0 {
            return
        }
        self.view.isUserInteractionEnabled = false;
        self.loader.startAnimating()
        CommunicationManager().getMovieResults(searchString: searchString, existingCount: entries.count) { (responseData) in
            if let result = (responseData!["results"] as? NSArray) {
                if result.count > 0 {
                    for dict in result {
                        let feedData : NSDictionary = dict as! NSDictionary
                        let record : Record = Record()
                        record.title = feedData.object(forKey: movie_title) as? String
                        record.releaseDate = feedData.object(forKey: release_date) as? String
                        record.overview = feedData.object(forKey: overview) as? String
                        //let movie_id = feedData.object(forKey: movie_id)
                       record.movie_id = "\((feedData.object(forKey: movie_id) as? NSNumber)?.intValue)"
                        if let path = feedData[poster_path] as? String {
                            record.url = (imageURL) + path
                        }
                        self.entries.insert(record, at: 0) // arranging the order of incoming data in reverse form 
                        //  beause we applied pull to refresh as per requirement.
                        //  so always the latest page data on top'
                    }
                }
                SuggestionManager.saveValue(self.searchString)
                self.tableView.reloadData()
                self.view.isUserInteractionEnabled = true;
                self.loader.stopAnimating()
                if self.SearchBar.isFirstResponder {
                    self.SearchBar.resignFirstResponder()
                }
                
            }
            else {
                let alertController = UIAlertController(title: "Movie App", message: "No Result Found for the '\(self.searchString)' Keyword.", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction.init(title: "Continue", style: UIAlertActionStyle.cancel, handler: { (alert) in
                    
                }))
                self.present(alertController, animated: true, completion: nil);
            }
            self.refreshControl.endRefreshing()
        }
        if(SearchBar.isFirstResponder){
            SearchBar.resignFirstResponder()
        }
    }
    // table view delegate, data source methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.tableView){
            return entries.count;
        }
        else {
            if let newsuggestionArray = SuggestionManager.getValue(){
                suggestionArray = newsuggestionArray;
                return suggestionArray.count
            }
            return 0
            
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == self.tableView){
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieListCell
        
        let record = self.entries[indexPath.row] as! Record
        cell.renderDataToCellWith(record: record)
                if record.image == nil {
                    if self.tableView.isDragging == false && self.tableView.isDecelerating == false {
                        self.startImageDownload(indexPath: indexPath, record: record)
                    }
                }
                else {
                    cell.MovieImageView.image = record.image!
                }
        
        return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionCell");
            cell?.textLabel?.text = suggestionArray.object(at: indexPath.row) as? String
            return cell!
        }
    }
    // iw till work for suggestion table only
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (tableView == self.suggestionTableView){
            searchString = (suggestionArray[indexPath.row] as? String)!
            if appDelegate.reachability.isReachable {
                SearchBar.text = searchString
                searchMovieWith(name: searchString)
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        suggestionTableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if( searchBar.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != searchString){
            searchString = searchBar.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            self.entries.removeAllObjects()
            self.imageDownloadsInProgress.removeAllObjects()
            //self.resultList.removeAllObjects()
            searchMovieWith(name: searchString)
           
        }
        if(searchBar.isFirstResponder){
            searchBar.resignFirstResponder()
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchString = "";
        if(SearchBar.isFirstResponder) {
            SearchBar.resignFirstResponder()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


// extension for images downloader
extension ViewController {
    func terminateAllDownloads() {
        let arr = self.imageDownloadsInProgress.allValues as NSArray
        arr.forEach { imageDownloader  in
            (imageDownloader as! ImageDownloader).cancelDownload()
        }
    }
    func startImageDownload(indexPath:IndexPath,record:Record){
        if self.imageDownloadsInProgress[record.movie_id!] == nil {
            let imageDownloader = ImageDownloader()
            imageDownloader.record = record
            imageDownloader.compeletionHandler = {
                DispatchQueue.main.async {
                    if let cell = self.tableView.cellForRow(at: indexPath) as? MovieListCell {
                        if let image = record.image {
                            cell.MovieImageView.image = image
                        }
                        self.imageDownloadsInProgress.removeObject(forKey: record.movie_id!)
                    }
                    
                }
            }
            self.imageDownloadsInProgress[record.movie_id!] = imageDownloader
            imageDownloader.startDownload()
        }
    }
    func loadImagesForOnScreenRows() {
        
            if (self.entries.count) > 0 {
                let visiblePaths = self.tableView.indexPathsForVisibleRows
                for indexPath  in visiblePaths! {
                    let record : Record  = self.entries[indexPath.row] as! Record
                    if record.image == nil {
                        self.startImageDownload(indexPath: indexPath, record: record)
                    }
                }
            }
    }
         func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate {
                self.loadImagesForOnScreenRows()
            }
        }
         func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            self.loadImagesForOnScreenRows()
        }
}


