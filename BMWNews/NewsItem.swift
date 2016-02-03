//
//  NewsItem.swift
//  BMWNews
//
//  Created by jones wang on 2015/12/23.
//  Copyright © 2015年 DevJW. All rights reserved.
//

import Foundation



class NewsItem{
    var title: String?
    var link: String?
    var source: String?
    var image: String?
    var pubdate: String?
    var content: String?
    var description: String?
    
    
    init(newstitle: String, newslink:String, newssource: String, newsimage:String, newsdate:String, newsContent:String, desc:String){
        title = newstitle
        link = newslink
        source = newssource
        image = newsimage
        content = newsContent
        description = desc
        // MARK: - check locale time identifier
        //let identifier = NSLocale.currentLocale().localeIdentifier
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss ZZZZ"
        let r_date = dateFormatter.dateFromString(newsdate)
        var dateString = ""
        if let d = r_date {
            
            dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
            dateFormatter.dateFormat = "YYYY-MM-dd"
            dateString = dateFormatter.stringFromDate(d)
        }
        
        pubdate = dateString
        
    }
}
