//
//  CustomTableViewCell.swift
//  Expandable-TableViewCell-StackView
//
//  Created by Akash Malhotra on 7/8/16.
//  Copyright © 2016 Akash Malhotra. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var subtitleLabel : UILabel!
    @IBOutlet weak var descriptionLabel : UILabel!
    @IBOutlet weak var icon : UIImageView!
    @IBOutlet weak var lbl_Line : UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setValues(_ lyrics: Lyrics) {
        
        
       
        
        
        self.titleLabel.text = lyrics.song
        self.subtitleLabel.text = lyrics.artist
        
        self.descriptionLabel.text = lyrics.lyricsSample
        let lyricsShown = lyrics.lyricsShown
        self.descriptionLabel.isHidden = !lyricsShown
        
        self.icon.image = lyricsShown ? UIImage(named: "icn_up_green") : UIImage(named: "icn_down_green")
        
     
       
//        self.icon.frame = CGRect(x: self.icon.frame.origin.x, y: titleY, width: self.icon.frame.size.width, height: self.icon.frame.size.height)
        
        
        
    }
    
    
    func setValuesLastRow(_ lyrics: Lyrics) {
        
        
         let str_LastRowtext = lyrics.song
        
    
        var myMutableString = NSMutableAttributedString()
        
        myMutableString = NSMutableAttributedString(string: str_LastRowtext!, attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 15, weight: .semibold)])
        myMutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.blue, range: NSRange(location:21,length:10))
        // set label Attribute
        self.titleLabel.attributedText = myMutableString
        
        
        
      //  self.titleLabel.attributedText = attributedString1
        //self.titleLabel.text = lyrics.song
        self.subtitleLabel.text = lyrics.artist
        
        self.descriptionLabel.text = lyrics.lyricsSample
        let lyricsShown = lyrics.lyricsShown
        self.descriptionLabel.isHidden = !lyricsShown
        
        self.icon.image = lyricsShown ? UIImage(named: "icn_up_green") : UIImage(named: "icn_down_green")
        
        
        
        //        self.icon.frame = CGRect(x: self.icon.frame.origin.x, y: titleY, width: self.icon.frame.size.width, height: self.icon.frame.size.height)
        
        
        
    }
}
