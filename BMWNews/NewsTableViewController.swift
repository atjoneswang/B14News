//
//  NewsTableViewController.swift
//  BMWNews
//
//  Created by jones wang on 2015/12/10.
//  Copyright © 2015年 DevJW. All rights reserved.
//

import UIKit
import Alamofire
import SWXMLHash
import Kanna
import ReachabilitySwift
import BTNavigationDropdownMenu
import CoreSpotlight
import MobileCoreServices

class NewsTableViewController: UITableViewController {
    
    let seriesItems = ["1 SERIES", "2 SERIES", "3 SERIES", "4 SERIES", "1M", "M2", "M3", "M4"]
    /*
    1ser http://www.bimmerfile.com/section/bmw_models/1-series/feed/
         http://www.bmwblog.com/category/models/bmw-1-series/feed/
         http://www.bimmerpost.com/1-series/feed/
    
    2ser http://www.bmwblog.com/category/models/2-series/feed/
         http://www.bimmerpost.com/2-series/feed/
         http://www.bimmerfile.com/section/bmw_models/2-series-2/feed/
    
    3ser http://www.bmwblog.com/category/models/bmw-3-series/feed/
         http://www.bimmerfile.com/section/bmw_models/bmw-3-series/feed/
         http://www.bimmerpost.com/3-series/feed/
    
    4ser http://www.bmwblog.com/category/models/bmw-4-series/feed/
         http://www.bimmerfile.com/section/bmw_models/4-series/feed/
         http://www.bimmerpost.com/4-series/feed/
    
    
    1M http://www.bmwblog.com/category/models/1-series-m-coupe/feed/
    1M http://www.bimmerpost.com/1m/feed/
    http://www.bimmerfile.com/section/bmw_models/m/1m/feed/

    
    M2 http://www.bmwblog.com/category/models/bmw-m2/feed/
       http://www.bimmerfile.com/section/bmw_models/m/m2/feed/
       http://www.bimmerpost.com/m2/feed/
    
    M3 http://www.bmwblog.com/category/models/bmw-m3/feed/
       http://www.bimmerfile.com/section/bmw_models/m/m3/feed/
       http://www.bimmerpost.com/m3/feed/
    
    M4 http://www.bmwblog.com/category/models/bmw-m4/feed/
       http://www.bimmerfile.com/section/bmw_models/m/m4/feed/
       http://www.bimmerpost.com/m4/feed/


    */
    //var feedUrl = "http://www.bmwblog.com/category/models/bmw-1-series/feed/"
    var feedUrl = "http://www.bimmerfile.com/section/bmw_models/1-series/feed/"
    var feedArray = [NewsItem]()
    var selMenu = ""
    var selectedNewsIndex: Int!
    var searchableURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selMenu = self.seriesItems[0]
        
        
        
        // set row automatic height
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 180.0
        // set row height end
        
        //set navigation dropdown menu
        let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, title: seriesItems.first!, items: seriesItems)
        menuView.cellHeight = 40
        menuView.cellTextLabelFont = UIFont(name: "HelveticaNeue-Bold", size: 15)
        menuView.cellTextLabelAlignment = NSTextAlignment.Center
        menuView.arrowPadding = 15
        menuView.animationDuration = 0.5
        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            print("Did select item at index: \(indexPath)")
            self.selMenu = self.seriesItems[indexPath]
        }
        menuView.cellBackgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        
        self.navigationItem.titleView = menuView
        //set navigation dropdown menu end
        
        //check network status
        let reachability: Reachability
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            showNoNetWorkAlert()
            return
        }
        
        reachability.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            dispatch_async(dispatch_get_main_queue()) {
                self.requestFeed(self.feedUrl)
                
            }
        }
        reachability.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            dispatch_async(dispatch_get_main_queue()) {
                self.showNoNetWorkAlert()
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            self.showNoNetWorkAlert()
        }
        
                
        
        self.refreshControl?.addTarget(self, action: "refreshFeed:", forControlEvents: .ValueChanged)
    }
    
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable() {
            requestFeed(feedUrl)
            
        } else {
            showNoNetWorkAlert()
        }
    }
    
    func showNoNetWorkAlert(){
        let alertController = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func refreshFeed(refreshControl: UIRefreshControl) {
        requestFeed(feedUrl)
        refreshControl.endRefreshing()
    }
    
	func requestFeed(url: String) {
		
		let feed = Alamofire.request(.GET, url)
		
		feed.responseString {response in
			let response = response.result.value
			
			if response?.isEmpty != true {
				let xml = SWXMLHash.parse(response!)
				self.feedArray = [NewsItem]()
				for item in xml["rss"] ["channel"] ["item"] {
					let description = item["description"].element?.text
					let content = item["content:encoded"].element?.text
					var imgsrc = ""
					if let doc = Kanna.HTML(html: content!, encoding: NSUTF8StringEncoding) {
						if doc.xpath("//img").count > 0 {
							for img in doc.xpath("//img") {
								imgsrc = img["src"]!
								break
							}
						}
					}
					
					if let newstitle = item["title"].element!.text, newsurl = item["link"].element!.text, pubdate = item["pubDate"].element!.text {
                        let feed = NewsItem.init(newstitle: newstitle, newslink: newsurl, newssource: "BMW BLOG", newsimage: imgsrc, newsdate: pubdate, newsContent: content!,desc: description!)
						self.feedArray.append(feed)
					}
					
				}
				
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
                self.setupSearchableContent()
            }
				
				self.tableView.reloadData()
			}
		}
		
	}
    
    func setupSearchableContent(){
        var searchableItems = [CSSearchableItem]()
        
        for i in 0...(self.feedArray.count - 1) {
            let news = self.feedArray[i]
            
            let searchableItemAttributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
            searchableItemAttributeSet.title = news.title!
            
            let newsImagePath = news.image!
            if let url = NSURL(string: newsImagePath) {
                if let data = NSData(contentsOfURL: url){
                    searchableItemAttributeSet.thumbnailData = data
                }
            }
            searchableItemAttributeSet.contentDescription = news.description?.stripHTML()
            searchableItemAttributeSet.contentURL = NSURL(string: news.link!)
            searchableItemAttributeSet.contentType = self.selMenu
            let keywords = news.title?.componentsSeparatedByString(" ")
            
            searchableItemAttributeSet.keywords = keywords
            
            let searchableItem = CSSearchableItem(uniqueIdentifier: "com.app.b14news.\(i)", domainIdentifier: "bmw", attributeSet: searchableItemAttributeSet)
            searchableItems.append(searchableItem)
        }
        
        CSSearchableIndex.defaultSearchableIndex().indexSearchableItems(searchableItems) {(error) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            }
        }
    }
    
    override func restoreUserActivityState(activity: NSUserActivity) {
        if activity.activityType == CSSearchableItemActionType {
            if let searchURL = activity.webpageURL?.absoluteString {
                self.searchableURL = searchURL
                
            }else{
                if self.feedArray.count > 0 {
                    if let userInfo = activity.userInfo {
                        let selectedNews = userInfo[CSSearchableItemActivityIdentifier] as! String
                        selectedNewsIndex = Int(selectedNews.componentsSeparatedByString(".").last!)
                        
                    }
                }
            }
            performSegueWithIdentifier("showNews", sender: self)
            
        }
    }
    
    /*
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedNewsIndex = indexPath.row
        performSegueWithIdentifier("showNews", sender: self)
    }
    */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return feedArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! NewsCell
        let item = self.feedArray[indexPath.row]
        cell.newsTitle.text = item.title!
        //cell.newsSource.text = item.source!
        cell.pubDate.text = item.pubdate!
        cell.newsImage.image = nil
        if item.image?.isEmpty == false{
            let imgRequest =  Alamofire.request(.GET, item.image!)
            imgRequest.responseData{ response in
                cell.newsImage.image = UIImage(data: response.data!)
            }
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showNews" {
            let destinationController = segue.destinationViewController as! NewsDetailViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                self.selectedNewsIndex = indexPath.row
                let selItem = feedArray[self.selectedNewsIndex]
                destinationController.link = selItem.link
                // set back button text
                navigationItem.title = self.selMenu
            }else{
                navigationItem.title = ""
                destinationController.link = self.searchableURL
            }
            
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
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
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
