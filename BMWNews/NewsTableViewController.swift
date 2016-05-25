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
import SwiftyJSON

class NewsTableViewController: UITableViewController {
    
    var seriesItems = ["1 SERIES", "2 SERIES", "3 SERIES", "4 SERIES", "1M", "M2", "M3", "M4"]
    
    var feedArray = [NewsItem]()
    var selMenu = ""
    var selectedNewsIndex: Int!
    var searchableURL = ""
    
    var feedJson: JSON = []
    var feedList = [String]()
    
    var tableTopY: Float = 0
    
    private let networkHelper = NetworkHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableTopY = Float(tableView.contentOffset.y)
        
        loadJsonData()
        //init navbar menu
        self.seriesItems = self.feedJson["feedmenu"].arrayValue.map{ $0.string!}
        selMenu = self.seriesItems[0]
        
        //load feed url list
        self.feedList = self.feedJson[self.selMenu].arrayValue.map{ $0.string!}
        
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
            //print("Did select item at index: \(indexPath)")
            self.selMenu = self.seriesItems[indexPath]
            self.feedList = self.feedJson[self.selMenu].arrayValue.map{ $0.string!}
            
            self.requestFeeds(self.feedList)
        }
        menuView.cellBackgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        
        self.navigationItem.titleView = menuView
        //set navigation dropdown menu end
        
        checkNetWork()
        
        self.refreshControl?.addTarget(self, action: #selector(NewsTableViewController.refreshFeed(_:)), forControlEvents: .ValueChanged)
    }
    
    func loadJsonData() {
        if let path = NSBundle.mainBundle().pathForResource("feed", ofType: "json") {
            if let data = NSData(contentsOfFile: path) {
                feedJson = JSON(data: data)
            }
        }
    }
    
    func checkNetWork(){
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
            //dispatch_async(dispatch_get_main_queue()) {
            
            self.requestFeeds(self.feedList)
            //}
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

    }
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable() {
            
            requestFeeds(self.feedList)
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
        requestFeeds(self.feedList)
        refreshControl.endRefreshing()
        
        
    }
    
    
    
    func requestFeeds(urls: [String]) {
		self.feedArray.removeAll()
        
        let notified = dispatch_semaphore_create(0)
        let group = dispatch_group_create()
        let globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        
        
        //networkHelper = NetworkHelper()
        var feedsdata = [String]()
        /**
        dispatch_group_enter(group)
        dispatch_group_async(group, globalQueue) { () -> Void in
            NSLog("test")
            
            self.networkHelper.getRSSXml(urls[0]){(result) ->Void in
                //dispatch_sync(globalQueue){
                
                feedsdata.append(result)
                dispatch_group_leave(group)
                //}
            }
            
 
        }
        dispatch_group_enter(group)
        dispatch_group_async(group, globalQueue) { () -> Void in
            
            NSLog("test 2")
            
            self.networkHelper.getRSSXml(urls[1]){(result) ->Void in
                //dispatch_sync(globalQueue){
                feedsdata.append(result)
                dispatch_group_leave(group)
                //}
            }
            
        }
        **/
        
		for url in urls {
            dispatch_group_enter(group)
            dispatch_group_async(group, globalQueue) { () -> Void in
                self.networkHelper.getRSSXml(url){(result) ->Void in
                    
                    feedsdata.append(result)
                    dispatch_group_leave(group)
                    
                }
            }
        }
 
        
        
        dispatch_group_notify(group, globalQueue) { () -> Void in
            dispatch_semaphore_signal(notified)
            NSLog("Finished")
            NSLog("feed xml count: \(feedsdata.count)")
            
            //let imagenotified = dispatch_semaphore_create(0)
            //let imagegroup = dispatch_group_create()
            //let imageglobalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            
            for feed in feedsdata {
                if !(feed.isEmpty) {
                    
                    let xml = SWXMLHash.parse(feed)
                    NSLog("xml item count: \(xml["rss"] ["channel"] ["item"].all.count)")
                    
                    
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
                        
                        if !(imgsrc.isEmpty) {
                            if let newstitle = item["title"].element!.text, newsurl = item["link"].element!.text, pubdate = item["pubDate"].element!.text {
                                let news = NewsItem(newstitle: newstitle, newslink: newsurl, newssource: "", newsimage: imgsrc, newsdate: pubdate, newsContent: content!, desc: description!)
                                self.feedArray.append(news)
                            }
                        }
                        /**
                        var imageData: NSData? = nil
                        
                        if !(imgsrc.isEmpty) {
                            dispatch_group_enter(imagegroup)
                            
                            dispatch_group_async(imagegroup, imageglobalQueue) { () -> Void in
                                
                                let imgrequest = Alamofire.request(.GET, imgsrc.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
                                imgrequest.responseData { response in
                                    if let data = response.data {
                                        imageData = data
                                        if let newstitle = item["title"].element!.text, newsurl = item["link"].element!.text, pubdate = item["pubDate"].element!.text {
                                            let feed = NewsItem(newstitle: newstitle, newslink: newsurl, newssource: "", newsimage: imgsrc, newsdate: pubdate, newsContent: content!, desc: description!, newsimageData: imageData!)
                                            self.feedArray.append(feed)
                                            
                                            dispatch_group_leave(imagegroup)
                                        }
                                        
                                    }
                                }
                                
                            }
                            
                            
                            
                        }
                        **/
                    }
                }
                
            }
            /**
            dispatch_group_notify(imagegroup, imageglobalQueue) { () -> Void in
                dispatch_semaphore_signal(imagenotified)
                NSLog("Image download Finished")
                
                
            }
            
            dispatch_group_wait(imagegroup, DISPATCH_TIME_FOREVER)
            dispatch_semaphore_wait(imagenotified, DISPATCH_TIME_FOREVER)
            **/
            
            NSLog("array count: \(self.feedArray.count)")
            //dispatch_async(dispatch_get_main_queue()){
            
            //}
            self.feedArray.sortInPlace({ $0.date!.compare($1.date!) == NSComparisonResult.OrderedDescending })
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    // print("start setup searchable content")
                self.setupSearchableContent(self.feedArray)
            }
            
            self.tableView.reloadData()
                
                // self.tableView.setContentOffset(CGPointMake(0, 0 - self.tableView.contentInset.top), animated: true)
                
            
            
        }
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
        dispatch_semaphore_wait(notified, DISPATCH_TIME_FOREVER)
	}
    
    func setupSearchableContent(feeds: [NewsItem]){
        var searchableItems = [CSSearchableItem]()
        
        var itemIdex = 0
        for news in feeds {
            
            
            let searchableItemAttributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
            searchableItemAttributeSet.title = news.title!
            
            let newsImagePath = news.image!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
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
            
            let searchableItem = CSSearchableItem(uniqueIdentifier: "com.app.b14news.\(itemIdex)", domainIdentifier: "bmw", attributeSet: searchableItemAttributeSet)
            searchableItems.append(searchableItem)
            itemIdex += 1
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
        cell.newsTitle.text = ""
		cell.newsTitle.text = item.title!
		// cell.newsSource.text = item.source!
		cell.pubDate.text = ""
        cell.pubDate.text = item.pubdate!
		cell.newsImage.image = nil
        if item.imageData != nil {
            cell.newsImage.image = UIImage(data: item.imageData!)
        }else{
            self.networkHelper.getImage(item.image!){(result) ->Void in
                item.imageData = result
                cell.newsImage.image = UIImage(data: item.imageData!)
            }
        }
        
		/*
        if let imagePath = item.image {
			let imgrequest = Alamofire.request(.GET, imagePath.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
			imgrequest.responseData { response in
				if let data = response.data {
					cell.newsImage.image = UIImage(data: data)
				}
			}
		}
        */
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
