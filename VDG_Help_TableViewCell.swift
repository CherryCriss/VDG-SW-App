//
//  VDG_Help_TableViewCell.swift
//  VeriDocG
//
//  Created by Bhavdip Patel on 10/07/18.
//  Copyright © 2018 SevenBits. All rights reserved.
//

import UIKit

class VDG_Help_TableViewCell: UITableViewCell {

    @IBOutlet weak  var vw_cellBk: UIView!
    @IBOutlet weak  var lbl_HelpDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
