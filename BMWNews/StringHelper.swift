//
//  StringHelper.swift
//  B14News
//
//  Created by jones wang on 2016/2/3.
//  Copyright © 2016年 DevJW. All rights reserved.
//

import Foundation


let htmlReplaceString   :   String  =   "<[^>]+>"

extension String{
    func stripHTML() -> String {
        return self.stringByReplacingOccurrencesOfString(htmlReplaceString, withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
    }
}