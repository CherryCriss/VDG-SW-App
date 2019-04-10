//
//  Rules_App_Cell.swift
//  VeriDocG
//
//  Created by Bhavdip Patel on 19/03/19.
//  Copyright © 2019 SevenBits. All rights reserved.
//

import UIKit

class Rules_App_Cell: UITableViewCell {

    
    @IBOutlet weak var lbl_Number: UILabel!
    @IBOutlet weak var lbl_Details: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
