//
//  MoviesTableViewController.swift
//  RottenTomato
//
//  Created by datdn1 on 8/26/15.
//  Copyright (c) 2015 datdn1. All rights reserved.
//

import UIKit
import KVNProgress
import AFNetworking
import MBProgressHUD

class MoviesTableViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    enum MovieType
    {
        case Box
        case DVD
    }
    
    enum DisplayTypeMovie:Int
    {
        case List = 0, Grid
    }

    // MARK: - Property
    // collection of movies
    var movies = []
    
    var filterMovies = []
    
    // view to attach progress
    var viewContainerProgress:UIView!
    
    // view to display error
    var viewError:UIView!
    
    // controll to triger reload movie event
    var refreshMovieControl:UIRefreshControl!
    
    // request object to request data from server
    var request:NSURLRequest!
    
    var currentSelectedTabbarItem:UITabBarItem!
    
    var searching:Bool!
    
    @IBOutlet weak var movieTableView: UITableView!
    
    @IBOutlet weak var movieTabbar: UITabBar!
    
    
    @IBOutlet weak var displayMovieTypeSegment: UISegmentedControl!
    
    @IBOutlet weak var collectionMovie: UICollectionView!
    
    @IBOutlet weak var searchBarMovie: UISearchBar!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchBarMovie.delegate = self
        
        // configure view to display error
        let subviewArray = NSBundle.mainBundle().loadNibNamed("ErrorMessageView", owner: self, options: nil) as! [UIView]
        viewError = subviewArray[0] as UIView
        viewError.frame = CGRectMake(0, -64, self.view.bounds.width, 64)
        viewError.backgroundColor = UIColor.clearColor()
        
        // configure movie tabbar
        currentSelectedTabbarItem = self.movieTabbar.items![0] as? UITabBarItem
        self.movieTabbar.selectedItem = currentSelectedTabbarItem
        
        // configure refresh controll 
        refreshMovieControl = UIRefreshControl()
        refreshMovieControl.addTarget(self, action: "refreshMovie", forControlEvents: UIControlEvents.ValueChanged)
        self.movieTableView.insertSubview(refreshMovieControl, atIndex: 0)
        
        // link to get movies
        let url = NSURL(string:"https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json")
        
        // create a request to server
        request = NSURLRequest(URL: url!)
        
        // query asynchronous to server
        getMoviesAndShow(request)
    }
    
    func refreshMovie()
    {
        // get movies again and reload table view
        getMoviesAndShow(request, reload: true)
    }
    
    func getMoviesAndShow(request:NSURLRequest, reload:Bool = false)
    {
        // configure and show progress status
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            
            if data != nil{
                if let moviesCollection:NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary
                {
                    if let moviesParse = moviesCollection["movies"] as? NSArray
                    {
                        self.movies = moviesParse
                        self.updateMovie(success: true, withError: nil)
                    }
                }
            }
            else
            {
                self.updateMovie(success: false, withError: error)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let search = searching
        {
            if search{
                return filterMovies.count
            }
        }
        return movies.count
    }

     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        var moviesAtCell:NSDictionary? = nil
        if let search = searching
        {
            if search{
                moviesAtCell = filterMovies.objectAtIndex(indexPath.row) as? NSDictionary
            }
        }
        else {
            moviesAtCell = movies.objectAtIndex(indexPath.row) as! NSDictionary
        }
        cell.titleMovie.text = moviesAtCell!["title"] as? String
        cell.synosysMovie.text = moviesAtCell!["synopsis"] as? String
        
        let posterObject = moviesAtCell!["posters"] as! NSDictionary
        let thumbnail = posterObject["thumbnail"] as? String
        
        // load asynsonos poster image
        cell.posterMovie.setImageWithURL(NSURL(string: thumbnail!)!)
        
        let posterImageUrl = getHighResolutionUrl(thumbnail!)
        // load asynsonos poster image
        cell.posterMovie.setImageWithURL(NSURL(string: posterImageUrl)!)
        return cell
    }
    
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.movieTableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
         if let identifier = segue.identifier
         {
            println(identifier)
            let destination = segue.destinationViewController as! DetailMovieViewController
            let selectedMovieIndex:Int?
            switch identifier
            {
                case "Show Detail Movie From List":
                    selectedMovieIndex = self.movieTableView.indexPathForSelectedRow()?.row
                case "Show Detail Movie From Grid":
                    selectedMovieIndex = self.collectionMovie.indexPathForCell((sender as! UICollectionViewCell))?.row
                default:
                    return
            }
            destination.movieObject = movies.objectAtIndex(selectedMovieIndex!) as! NSDictionary
         }
    }
//    func boxClickHandler(sender:UIBarButtonItem)
//    {
//        println("Box Clicked!!!")
//    }
    
    func closeErrorMessage(sender:UIButton)
    {
        UIView.animateWithDuration(1.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
            {
                self.viewError.transform = CGAffineTransformIdentity
                self.viewError.backgroundColor = UIColor.clearColor()
            }, completion: nil)
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!)
    {
        if item.title != currentSelectedTabbarItem.title
        {
            currentSelectedTabbarItem = item
            switch item.title!
            {
                case "Box":
                    // get movie with box data
                    createRequest(movieType: MovieType.Box)
                case "DVD":
                    // get movie with DVD data
                    createRequest(movieType: MovieType.DVD)
                default:
                    return
            }
            getMoviesAndShow(self.request, reload: false)
        }
    }
    
    func createRequest(movieType withMovieType:MovieType)
    {
        var url:String?
        var nsURL:NSURL
        if withMovieType == MovieType.Box
        {
            url = "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json"
        }
        else if withMovieType == MovieType.DVD
        {
            url = "https://gist.githubusercontent.com/timothy1ee/e41513a57049e21bc6cf/raw/b490e79be2d21818f28614ec933d5d8f467f0a66/gistfile1.json"
        }
        nsURL = NSURL(string: url!)!
        self.request = NSURLRequest(URL: nsURL)
    }
    
    func updateMovie(#success:Bool, withError error: NSError?)
    {
        if success
        {
            let displayTypeMovie = self.displayMovieTypeSegment.selectedSegmentIndex
            if displayTypeMovie == DisplayTypeMovie.List.rawValue
            {
                self.movieTableView.reloadData()
            }
            else if displayTypeMovie == DisplayTypeMovie.Grid.rawValue
            {
                self.collectionMovie.reloadData()
            }
            self.refreshMovieControl.endRefreshing()
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }
        else
        {
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            self.refreshMovieControl.endRefreshing()
            self.view.addSubview(self.viewError)
            let errorMessageView = self.viewError.viewWithTag(100) as! UILabel
            errorMessageView.text = error!.localizedDescription
            
            let closeButtonView = self.viewError.viewWithTag(101) as! UIButton
            closeButtonView.addTarget(self, action: "closeErrorMessage:", forControlEvents: UIControlEvents.TouchUpInside)
            UIView.animateWithDuration(1.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
                {
                    self.viewError.transform = CGAffineTransformMakeTranslation(0, 128)
                }, completion: nil)

        }
    }
    
    @IBAction func showListOrCollectionHandler(sender: UISegmentedControl)
    {
        if sender.selectedSegmentIndex == 0
        {
            self.movieTableView.hidden = false
            self.collectionMovie.hidden = true
            self.movieTableView.insertSubview(self.refreshMovieControl, atIndex: 0)
            self.movieTableView.reloadData()
        }
        else if sender.selectedSegmentIndex == 1
        {
            self.movieTableView.hidden = true
            self.collectionMovie.hidden = false
            self.collectionMovie.insertSubview(self.refreshMovieControl, atIndex: 0)
            self.collectionMovie.reloadData()
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionMovieCell", forIndexPath: indexPath) as! MovieCollectionCell
        
        let moviesAtCell = movies.objectAtIndex(indexPath.row) as! NSDictionary
        cell.titleMovie.text = moviesAtCell["title"] as? String
        
        let posterObject = moviesAtCell["posters"] as! NSDictionary
        let thumbnail = posterObject["thumbnail"] as? String
        
        cell.posterImage.setImageWithURL(NSURL(string: thumbnail!)!)
        
        let posterImageUrl = getHighResolutionUrl(thumbnail!)
        // load asynsonos poster image
        cell.posterImage.setImageWithURL(NSURL(string: posterImageUrl)!)
        
        cell.mpaaRating.text = moviesAtCell["mpaa_rating"] as? String
        cell.timeMovie.text = String((moviesAtCell["runtime"] as! Int)) + " min"
        cell.audienceScore.text = String((moviesAtCell.valueForKeyPath("ratings.audience_score") as! Int)) + "%"
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    }
    
    func getHighResolutionUrl(lowResolutionUrl:String) -> String
    {
        var highResolutionUrl:String? = nil
        var range = lowResolutionUrl.rangeOfString(".*cloudfront.net/", options: NSStringCompareOptions.RegularExpressionSearch)
        if let range = range
        {
            println(range)
            highResolutionUrl = lowResolutionUrl.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }
        return highResolutionUrl!
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        filterMovies = []
        if searchText.isEmpty
        {
            self.searching = false
            updateMovie(success: true, withError: nil)
            return
        }
        for item in 0...movies.count-1
        {
            let titleMovie = (movies[item] as! NSDictionary).valueForKeyPath("title") as! String
            let range = titleMovie.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            if range != nil
            {
                filterMovies = filterMovies.arrayByAddingObject(movies[item] as! NSDictionary)
            }
        }
        if filterMovies.count == 0
        {
            searching = false
        }
        else if filterMovies.count > 0
        {
            searching = true
        }
        
        updateMovie(success: true, withError: nil)

    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searching = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        self.searching = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searching = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        updateMovie(success: true, withError: nil)
    }

}
