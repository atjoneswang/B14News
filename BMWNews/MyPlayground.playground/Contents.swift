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
let group: dispatch_group_t = dispatch_group_create()

for i in 0..<feedURLs.count {
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
        
        NSLog("proc start")
        Alamofire.request(.GET, feedURLs[i]).responseString { response in
            let feedData = response.result.value
            if feedData?.isEmpty == false {
                downloads.append(feedData!)
            }
        }
        NSLog("proc end")
    }
}

dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
    NSLog("notify")
    NSLog("\(downloads.count)")
}
NSLog("before wait")

dispatch_group_wait(group, DISPATCH_TIME_FOREVER)

NSLog("after wait")

class DownLoadHelper{
    static func downLoadRSS(url:String){
        Alamofire.request(.GET, url).responseString { response in
            let feedData = response.result.value
            if feedData?.isEmpty == false {
                downloads.append(feedData!)
            }
        }
    }

}

class DownloadOperation: DownloadBaseOperation {
    let url:String
    
    init(url:String) {
        self.url = url
    }
    
    override func main() {
        Alamofire.request(.GET, url).responseString { response in
            let feedData = response.result.value
            if feedData?.isEmpty == false {
                self.result = feedData
            }
        }
    }
}

/*
let queue = NSOperationQueue()
let downloadOp = DownloadOperation(url: feedUrl)
let download2p = DownloadOperation(url: feed2Url)
queue.addOperation(downloadOp)
queue.addOperation(download2p)
queue.waitUntilAllOperationsAreFinished()

var feeds = [String]()

for operation in queue.operations {
    let downloadresult = operation as! DownloadOperation
    NSLog(downloadresult.result!)
    feeds.append(downloadresult.result)
    NSLog(feeds.description)
}
queue.addOperationWithBlock({
    NSOperationQueue.mainQueue().addOperationWithBlock({
        NSLog("finish")
    })
})
var xmllist = feeds
*/