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

class DownloadBaseOperation : NSOperation {
    var result:String!
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
let queue = NSOperationQueue()
let downloadOp = DownloadOperation(url: feedUrl)
let download2p = DownloadOperation(url: feed2Url)
queue.addOperation(downloadOp)
queue.addOperation(download2p)
downloadOp.waitUntilFinished()
download2p.waitUntilFinished()
queue.waitUntilAllOperationsAreFinished()

for operation in queue.operations {
    let result = operation as! DownloadOperation
    print(result.result)
}
