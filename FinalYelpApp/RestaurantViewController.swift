//
//  RestaurantViewController.swift
//  YelpApp
//
//  Created by Monika Gorkani on 9/21/14.
//  Copyright (c) 2014 Monika Gorkani. All rights reserved.
//

import UIKit
import CoreLocation

class RestaurantViewController: UIViewController, UITableViewDataSource, CLLocationManagerDelegate, UITextFieldDelegate, SearchProtocol {
    
    @IBAction func enteredSearchTerm(sender: AnyObject) {
         
         let textField = sender as UITextField
         if (!textField.text.isEmpty) {
            filterParams["term"] = textField.text;
            searchRestaurants()
         }
        
        
    }
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var client: YelpClient!
    let locationManager = CLLocationManager()
    var filterSettings = NSMutableArray()
   
    
    // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
    let yelpConsumerKey = "L2j3EFUHakZejnRcRY0taQ"
    let yelpConsumerSecret = "QKjwBtvtewgH8U-v0wjbl76HnwE"
    let yelpToken = "mfXKXpgPmIDuB4eCPet6sRM_wIhFtZ5a"
    let yelpTokenSecret = "9yA_lBvuZv1zHmWcZXtRUZbCsOw"
    var restaurants: [NSDictionary] = []
    var filterParams = NSMutableDictionary()
    
    func searchWithParams(parameters:NSMutableArray) {
       
        filterSettings = parameters;
       
        for setting in parameters {
            let name = setting["name"] as String
            if (name == "Radius") {
                var rows = setting["rows"] as NSArray
                for row in rows {
                    let selected = row["selected"] as Bool
                    
                    if (selected) {
                        let value = row["value"] as String
                        if (value == "auto")
                        {
                            filterParams.removeObjectForKey("radius_filter")
                        }
                        else
                        {
                            filterParams["radius_filter"] = row["value"]
                        }
                        break
                        
                    }
                    
                }
            }
            if (name == "Sort") {
                
                let rows = setting["rows"] as NSArray
                for row in rows {
                    let selected = row["selected"] as Bool
                    
                    if (selected) {
                        filterParams["sort"] = row["value"]
                        break
                        
                    }
                }
                
            }
            if (name == "Deals") {
                let rows = setting["rows"] as NSArray
                for row in rows {
                    let selected = row["selected"] as Bool
                    
                    filterParams["deals_filter"] = selected
                }
                
            }
            
            if (name == "Category") {
                let rows = setting["rows"] as NSArray
                var categories: String = ""
                var isFirst =  true
                for row in rows {
                   
                    let selected = row["selected"] as Bool
                    let value = row["value"] as String
                    
                    if (selected) {
                        if (isFirst) {
                            categories += value
                            isFirst = false
                        }
                        else {
                           categories += "," + value
                        }
                        
                    }
                }
                if (!categories.isEmpty) {
                   
                    filterParams["category_filter"] = categories
                }

            }

        }
   
        searchRestaurants()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
       
        let cell = tableView.dequeueReusableCellWithIdentifier("RestaurantCell") as RestaurantCell
        let restaurant = self.restaurants[indexPath.row]
              cell.nameLabel.text = restaurant["name"] as? String
        let distance = restaurant["distance"] as NSNumber
        let miles : CGFloat = distance * 0.000621371
        let s = String(format: "%.2f", Double(miles))
        cell.milesLabel.text = "\(s) mi"
        cell.priceLabel.text = "$$$$"
        let reviewCount = restaurant["review_count"] as NSNumber
        let addressDic = restaurant["location"] as NSDictionary
        let addressArray = addressDic["display_address"] as NSArray
        cell.reviewsLabel.text = "\(reviewCount.stringValue) Reviews"
        cell.addressLabel.text = "\(addressArray[0]), \(addressArray[1]) \(addressArray[2])"
        let categories = restaurant["categories"] as NSArray
        var categoryNames = ""
        for category in categories {
            
            categoryNames += " \(category[0])"
        }
        
        let imageRequestFailure = {
            (request : NSURLRequest!, response : NSHTTPURLResponse!, error : NSError!) -> Void in
            if (error? != nil) {
                let errorString = error.localizedDescription
 
                
            }
            
        }
        
        // do the fade in for the thumbnail images
        let imageURL = restaurant["image_url"] as String
        let request = NSURLRequest(URL: NSURL(string: imageURL))
        let imageRequestSuccess = {
            (request : NSURLRequest!, response : NSHTTPURLResponse!, image : UIImage!) -> Void in
            
            cell.thumbnailView.alpha = 0.0;
            cell.thumbnailView.image = image;
            UIView.animateWithDuration(0.7, animations: { () -> Void in
                cell.thumbnailView.alpha = 1.0
            })
            
            
        }
        
        cell.thumbnailView.setImageWithURLRequest(request, placeholderImage: nil, success: imageRequestSuccess, failure: imageRequestFailure)
        
        let starImageURL = restaurant["rating_img_url"] as String
        cell.starsView.setImageWithURL(NSURL(string:starImageURL))
   
        cell.typeLabel.text = categoryNames
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
       //
        
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error while updating location" + error.localizedDescription)
       
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
         if (segue.identifier == "GotoFilter") {
            
            let navigationController = segue.destinationViewController as UINavigationController
            let filterController = navigationController.viewControllers[0] as FilterController
            filterController.delegate = self
            // copy the settings for the filter controller. in case someone cancels we still have the original 
            // settings
            var setSettings = NSKeyedUnarchiver.unarchiveObjectWithData(NSKeyedArchiver.archivedDataWithRootObject(filterSettings)) as NSMutableArray
          
          
            filterController.settings = setSettings
            
        }
    }
  

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 122
        self.tableView.rowHeight = UITableViewAutomaticDimension
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        self.searchField.delegate = self
        filterParams.setValue("thai", forKey: "term")
        filterParams.setValue( "37.788022,-122.399797", forKey:"ll")
        filterParams.setValue(0, forKey: "sort")
        filterParams.setValue(false,forKey: "deals_filter")
        initializeFilterSettings()
        searchRestaurants()
        
      

        // Do any additional setup after loading the view.
    }
    
    func initializeFilterSettings() {
        var dictionary = NSMutableDictionary();
        dictionary.setValue("Radius", forKey: "name")
        dictionary.setValue("RadiusCell", forKey: "cell_type")
        var rows : [NSMutableDictionary] = [["display_name":"Auto","value":"auto","selected":true],["display_name":"0.3 Miles","value":"483","selected":false],["display_name":"1 Mile","value":"1609","selected":false],["display_name":"5 Miles","value":"8047","selected":false],["display_name":"20 Miles","value":"32187","selected":false]]
        dictionary.setValue(rows,forKey: "rows")
        
        
        
        filterSettings[0] = dictionary;
        dictionary = NSMutableDictionary();
        dictionary.setValue("Sort", forKey: "name")
        dictionary.setValue("SortCell", forKey: "cell_type")
        rows  = [["display_name":"Best Match","value":"0","selected":true],["display_name":"Distance","value":"1","selected":false],["display_name":"Highest Rated","value":"2","selected":false]]
        
        dictionary.setValue(rows,forKey: "rows")
        filterSettings[1] = dictionary
        
        dictionary = NSMutableDictionary();
        dictionary.setValue("Deals", forKey: "name")
        dictionary.setValue("DealsCell", forKey: "cell_type")
        rows = [["display_name":"Deals","value":"deals","selected":false]]
        dictionary.setValue(rows,forKey: "rows")
        filterSettings[2] = dictionary
        dictionary = NSMutableDictionary();
        dictionary.setValue("Category", forKey: "name")
        dictionary.setValue("CategoryCell", forKey: "cell_type")
        rows = [["display_name":"Active Life","value":"active","selected":false],["display_name":"Bars","value":"bars","selected":false],["display_name":"Restaurants","value":"restaurants","selected":false],
            ["display_name":"Fitness & Instruction","value":"fitness","selected":false],
            ["display_name":"Museums","value":"museums","selected":false],
            ["display_name":"Music Venues","value":"musicvenues","selected":false],
        
        ]
        
        dictionary.setValue(rows,forKey: "rows")
        filterSettings[3] = dictionary
        // Do any additional setup after loading the view.
    }
    
    func searchRestaurants() {
         self.view.showActivityViewWithLabel("Loading")
        client = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
        
        client.searchWithTerm(filterParams, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            
            println(response)
            self.restaurants = response["businesses"] as [NSDictionary]
             self.view.hideActivityView()
            self.tableView.reloadData()
            
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                self.view.hideActivityView()
                println(error)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
