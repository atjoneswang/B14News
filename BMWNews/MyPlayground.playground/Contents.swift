//: Playground - noun: a place where people can play

import UIKit
import Alamofire
import SWXMLHash
import XCPlayground

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true


var str = "Hello, playground"

var feedUrl = "http://www.bmwblog.com/category/models/bmw-1-series/feed/"
var feed2Url = "http://www.bmwblog.com/category/models/2-series/feed/"
let identifier = NSLocale.currentLocale().localeIdentifier
var feedURLs = [String]()
feedURLs.append(feedUrl)
feedURLs.append(feed2Url)

class DownloadBaseOperation : NSOperation {
    var result:String!
}
var downloads = [String]()
let globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
let group = dispatch_group_create()

let session = NSURLSession.sharedSession()
for i in 0..<feedURLs.count {
    
        
        NSLog("proc task \(i) start")
        let task = session.dataTaskWithURL(NSURL(string: feedURLs[i])!){(data, response, err) -> Void in
            NSLog("\(i) task done.")
            let rss = NSString(data: data!, encoding: NSUTF8StringEncoding)!
            //NSLog(rss as String)
        //objc_sync_enter(downloads)
            downloads.append(rss as String)
        //objc_sync_exit(downloads)
            
        }
    
        task.resume()
    
        NSLog("proc task \(i) end")
    //}
}





