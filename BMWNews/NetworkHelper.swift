//
//  NetworkHelper.swift
//  B14News
//
//  Created by jones wang on 2016/2/13.
//  Copyright © 2016年 DevJW. All rights reserved.
//

import Foundation
import Alamofire

class NetworkHelper {
    
    func getResponseString(url: String, complate:(result: String) -> Void) {
        Alamofire.request(.GET, url).responseString { response in
            let feedData = response.result.value
            if feedData?.isEmpty == false {
                
                complate(result: feedData!)
            }
        }
        
    }
    
    func getRSSXml(url: String, complate:(result: String) -> Void) {
        if let url = NSURL(string: url) {
            NSURLSession.sharedSession().dataTaskWithURL(url){data, response, err in
                if data != nil {
                    let rss = NSString(data: data!, encoding: NSUTF8StringEncoding)?.description
                    complate(result: rss!)
                }
            }.resume()
        }
    }
    
    func getImage(url: String, complate:(result: NSData) -> Void) {
        let imgrequest = Alamofire.request(.GET, url.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
        imgrequest.responseData { response in
            if let data = response.data {
                let imageData = data
                complate(result: imageData)
                
            }
        }
    }
}
