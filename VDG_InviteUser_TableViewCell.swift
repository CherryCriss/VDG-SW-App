//
//  VDG_InviteUser_TableViewCell.swift
//  VeriDocG
//
//  Created by Bhavdip Patel on 21/08/18.
//  Copyright © 2018 SevenBits. All rights reserved.
//

import UIKit



protocol VDG_InviteUser_TableViewCellDelegate : class {
    func didPressButton(_ tag: Int)
}

class VDG_InviteUser_TableViewCell: UITableViewCell {

    @IBOutlet weak  var lbl_Title: UILabel!
    @IBOutlet weak var btn_Select: UIButton!
    @IBOutlet weak var img_Profile: UIImageView!
    
    
    weak var cellDelegate: VDG_InviteUser_TableViewCellDelegate?
    
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        cellDelegate?.didPressButton(sender.tag)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

   
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
