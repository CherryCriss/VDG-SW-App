//
//  VDG_MyRewards_Prize_Cell.swift
//  VeriDocG
//
//  Created by Bhavdip Patel on 15/10/18.
//  Copyright © 2018 SevenBits. All rights reserved.
//

import UIKit

class VDG_MyRewards_Prize_Cell: UITableViewCell {
    
    @IBOutlet var img_Prize: UIImageView!
    @IBOutlet var segment_Size: UISegmentedControl!
    @IBOutlet var lbl_Title: UILabel!
    @IBOutlet var btn_Remove: UIButton!
   
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
