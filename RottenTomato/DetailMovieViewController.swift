//
//  DetailMovieViewController.swift
//  RottenTomato
//
//  Created by datdn1 on 8/27/15.
//  Copyright (c) 2015 datdn1. All rights reserved.
//

import UIKit

class DetailMovieViewController: UIViewController {

    var movieObject:NSDictionary!
    var lowResolutionImageView:UIImageView!
    
    
    @IBOutlet weak var posterDetailMovie: UIImageView!
    
    @IBOutlet weak var synosysDetaiMovie: UITextView!
    
    @IBOutlet weak var titleMovie: UILabel!
    
    @IBOutlet weak var scoreMovie: UILabel!
    
    @IBOutlet weak var mpaaRating: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let posterObject = movieObject["posters"] as! NSDictionary
        let lowResolutionUrl = posterObject["detailed"] as? String
        self.posterDetailMovie.setImageWithURL(NSURL(string: lowResolutionUrl!)!)
        
        let highResolutionUrl = getHighResolutionUrl(lowResolutionUrl!)
        println(lowResolutionUrl!)
        println(highResolutionUrl)
        
        // load asynsonos poster image
        self.posterDetailMovie.setImageWithURL(NSURL(string: getHighResolutionUrl(lowResolutionUrl!))!)
        self.synosysDetaiMovie.text = movieObject["synopsis"] as? String

        self.mpaaRating.text = movieObject["mpaa_rating"] as? String
        
        let criticsScore = movieObject.valueForKeyPath("ratings.critics_score") as! Int
        let audienceScore = movieObject.valueForKeyPath("ratings.audience_score") as! Int
        self.scoreMovie.text = "Critics Score: " + String(criticsScore) + ", " + "Audience Score: " + String(audienceScore)
        
        self.titleMovie.text = movieObject["title"] as? String
        self.title = movieObject["title"] as? String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

}
