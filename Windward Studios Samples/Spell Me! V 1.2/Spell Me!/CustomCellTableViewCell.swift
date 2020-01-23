//
//  CustomCellTableViewCell.swift
//  Spell Me!
//
//  Created by Etash Kalra on 6/22/16.
//  Copyright © 2016 Kalra. All rights reserved.
//

import UIKit

class CustomCellTableViewCell: UITableViewCell {

    @IBOutlet var label1: UILabel! //score
    @IBOutlet var label2: UILabel! //list
    @IBOutlet var label3: UILabel! //date
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
