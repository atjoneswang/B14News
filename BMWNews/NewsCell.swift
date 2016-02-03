//
//  NewsCell.swift
//  BMWNews
//
//  Created by jones wang on 2015/12/9.
//  Copyright © 2015年 DevJW. All rights reserved.
//

import UIKit

class NewsCell: UITableViewCell {

    @IBOutlet weak var newsImage: UIImageView!
    
    @IBOutlet weak var newsTitle: UILabel!
    
    @IBOutlet weak var newsSource: UILabel!
    
    @IBOutlet weak var pubDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.layoutMargins = UIEdgeInsets(top: <#T##CGFloat#>, left: <#T##CGFloat#>, bottom: <#T##CGFloat#>, right: <#T##CGFloat#>)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
