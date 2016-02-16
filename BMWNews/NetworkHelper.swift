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
    
}
