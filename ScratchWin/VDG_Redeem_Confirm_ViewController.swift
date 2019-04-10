//
//  VDG_Redeem_Confirm_ViewController.swift
//  VeriDocG
//
//  Created by Bhavdip Patel on 16/10/18.
//  Copyright © 2018 SevenBits. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase
import FirebaseAuth
import FirebaseDatabase
import NVActivityIndicatorView
import PKHUD

class VDG_Redeem_Confirm_ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet var tbl_Prizes: UITableView!
    @IBOutlet var btn_Close : UIButton!
    @IBOutlet var btn_Help : UIButton!
    @IBOutlet var btn_Confirm : UIButton!
    @IBOutlet var btn_Edit : UIButton!
    @IBOutlet var btn_check : UIButton!
    @IBOutlet var lbl_RemainTS: UILabel!
    @IBOutlet var txt_Address: UITextView!
    @IBOutlet var txt_Contact : UITextView!
    @IBOutlet var lbl_RedeemStatus: UILabel!
    
    
    var img_ScreenShot: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib.init(nibName: "VDG_MY_REWARD_LIST_TableViewCell", bundle: nil)
        tbl_Prizes.register(nib, forCellReuseIdentifier: "VDG_MY_REWARD_LIST_TableViewCell")
        img_ScreenShot = self.takeScreenshot(false)
        // Do any additional setup after loading the view.
        
        
        
    }
    
    func takeScreenshot(_ shouldSave: Bool = true) -> UIImage? {
        
        var screenshotImage :UIImage?
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        guard let context = UIGraphicsGetCurrentContext() else {return nil}
        layer.render(in:context)
        screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let image = screenshotImage, shouldSave {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        return screenshotImage
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "VDG_MY_REWARD_LIST_TableViewCell"
        var cell: VDG_MY_REWARD_LIST_TableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? VDG_MY_REWARD_LIST_TableViewCell
        if cell == nil {
            tableView.register(UINib(nibName: "VDG_MY_REWARD_LIST_TableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? VDG_MY_REWARD_LIST_TableViewCell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 70.0
    }
    
    @IBAction func btn_Close(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: false)
    }
    @IBAction func btn_Help(_ sender: UIButton) {
        
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Help_Scratch_Win_ViewController") as! VDG_Help_Scratch_Win_ViewController
        secondViewController.img_Bk = img_ScreenShot
        secondViewController.str_Descptn = "- Inspect the complete Points WON during SCRATCH AND WIN.\n\n- Using more SCRATCH CARDS will increase the LEVEL and the chances of winning VALUABLES will be also increased.\n\n- The CIRCULAR PROGRESS BAR and the HORIZONTAL PROGRESS BAR is used to track the LEVEL for level up and required Points for redemption.\n\n- The Point can be used to redeem once the horizontal progress bar is MATURE.\n\n- Available rewards can be viewed in the PRIZES SECTION."
        self.navigationController?.present(secondViewController, animated: true)
    }
    @IBAction func btn_Confirm(_ sender: UIButton) {
        
    }
    @IBAction func btn_Edit(_ sender: UIButton) {
        
        if txt_Address.isEditable == true {
            txt_Address.isEditable = false
            txt_Contact.isEditable = false
            btn_Edit.setTitle("Edit", for: .normal) 
            
        }else {
            
            txt_Address.isEditable = true
            txt_Contact.isEditable = true
            btn_Edit.setTitle("Save", for: .normal)
            
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.05
            animation.repeatCount = 4
            animation.autoreverses = true
            animation.fromValue = NSValue(cgPoint: CGPoint(x: txt_Address.center.x - 10, y: txt_Address.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: txt_Address.center.x + 10, y: txt_Address.center.y))
            
            txt_Address.layer.add(animation, forKey: "position")
            
            
            let animation1 = CABasicAnimation(keyPath: "position")
            animation1.duration = 0.05
            animation1.repeatCount = 4
            animation1.autoreverses = true
            animation1.fromValue = NSValue(cgPoint: CGPoint(x: txt_Contact.center.x - 10, y: txt_Contact.center.y))
            animation1.toValue = NSValue(cgPoint: CGPoint(x: txt_Contact.center.x + 10, y: txt_Contact.center.y))
            txt_Contact.layer.add(animation1, forKey: "position")
            
            
        }
    }
    
    @IBAction func btn_check(_ sender: UIButton) {
        
        btn_check.tintColor = UIColor.clear
        
        
        if btn_check.isSelected == true {
            btn_check.isSelected = false
            btn_check.setBackgroundImage(UIImage(named: "icn_unchecked"), for: .normal)
            
        }else {
            btn_check.isSelected = true
            btn_check.setBackgroundImage(UIImage(named: "icn_checked"), for: .normal)
        }
        
    }
   
    func get_Scratches_Info() {
        
        var ref = Database.database().reference() // undeclared
        
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        
        let userID = userDetail!["customerguid"] as! String
        
        let str_Date = UserDefaults.standard.object(forKey: "C_D") as! String
        
        //HUD.show(.progress)
        // HUD.show(HUDContentType.rotatingImage(UIImage(named: "icn_spinner")))
        
        // Add Activity Indicatore
        let vw_Load_BK = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        vw_Load_BK.backgroundColor = UIColor.white
        vw_Load_BK.alpha = 0.6
        self.view.addSubview(vw_Load_BK)
        let frame = CGRect(x: (self.view.frame.width/2)-30, y: (self.view.frame.height/2)-30, width: 60, height: 60)
        let activityIndicatorView = NVActivityIndicatorView(frame: frame,
                                                            type: NVActivityIndicatorType.ballScale)
        
        activityIndicatorView.color = UIColor.darkGray
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        
        ref = Database.database().reference().child("Scratch&Win").child(userID).child(userID+"-Scratch&Win")
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            PKHUD.sharedHUD.hide()
            // remove Indicator
            activityIndicatorView.stopAnimating()
            activityIndicatorView.removeFromSuperview()
            vw_Load_BK.removeFromSuperview()
            
            if snapshot.exists() {
                
                print(snapshot.value as Any)
                let dic_Info = snapshot.value as! NSDictionary
                
                let str_Tmp = dic_Info["today_date"] as! String
                
                print(str_Tmp)
                
                
                
                
                
                
            }
            
        })
        
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
