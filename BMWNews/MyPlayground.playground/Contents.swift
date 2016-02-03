//: Playground - noun: a place where people can play

import UIKit
import Alamofire
import SWXMLHash
import XCPlayground

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

var str = "Hello, playground"

var feedUrl = "http://www.bmwblog.com/category/models/bmw-1-series/feed/"
let identifier = NSLocale.currentLocale().localeIdentifier
