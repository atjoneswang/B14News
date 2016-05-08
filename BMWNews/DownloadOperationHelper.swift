//
//  DownloadBaseOperation.swift
//  B14News
//
//  Created by jones wang on 2016/3/23.
//  Copyright © 2016年 DevJW. All rights reserved.
//

import Foundation
import Alamofire

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