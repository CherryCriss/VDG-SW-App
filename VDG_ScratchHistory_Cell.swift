//
//  VDG_ScratchHistory_Cell.swift
//  VeriDocG
//
//  Created by Bhavdip Patel on 30/10/18.
//  Copyright © 2018 SevenBits. All rights reserved.
//

import UIKit

class VDG_ScratchHistory_Cell: UITableViewCell {
    
    
    @IBOutlet var lbl_DayNumber: UILabel!
    @IBOutlet var vw_BK: UIView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
