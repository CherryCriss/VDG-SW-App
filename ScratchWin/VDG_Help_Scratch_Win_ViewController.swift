//
//  VDG_Help_Scratch&Win_ViewController.swift
//  VeriDocG
//
//  Created by Bhavdip Patel on 05/11/18.
//  Copyright © 2018 SevenBits. All rights reserved.
//

import UIKit

class VDG_Help_Scratch_Win_ViewController: UIViewController {

    @IBOutlet var vw_BK_View: UIView!
    @IBOutlet var img_BK_View: UIImageView!
    @IBOutlet var txt_HelpDesc: UITextView!
    
    
    var img_Bk: UIImage!
    var str_Descptn: String!
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        img_BK_View.image = img_Bk
        
        // Do any additional setup after loading the view.
 
        vw_BK_View.layer.cornerRadius = 8
        txt_HelpDesc.text = str_Descptn
        txt_HelpDesc.textAlignment = .justified
     
    }
    
    @IBAction func btn_Okay(_ sender: UIButton){
        dismiss(animated: true, completion: nil)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
