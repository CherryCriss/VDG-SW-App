//
//  VDG_Scratch_Sorry_ViewController.swift
//  VeriDocG
//
//  Created by Bhavdip Patel on 12/10/18.
//  Copyright © 2018 SevenBits. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase
import FirebaseAuth
import FirebaseDatabase
import NVActivityIndicatorView
import PKHUD


class VDG_Scratch_Sorry_ViewController: UIViewController {

    
    @IBOutlet var btn_Close : UIButton!
    @IBOutlet var btn_Help : UIButton!
    @IBOutlet var vw_Coins : UIView!
    @IBOutlet var vw_Tshirt : UIView!
    @IBOutlet var btn_Invite : UIButton!
    @IBOutlet var btn_Share : UIButton!
    @IBOutlet var btn_RemainTS: UIButton!
    @IBOutlet var btn_TryAgain: UIButton!
    @IBOutlet var img_SorryFace: UIImageView!
    var img_ScreenShot: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      // UpdateScratches()
        // Do any additional setup after loading the view.
        
        
        
        btn_TryAgain.layer.shadowRadius = 10
        btn_TryAgain.layer.shadowOpacity = 0.4
        btn_TryAgain.layer.shadowColor = UIColor.black.cgColor
        btn_TryAgain.layer.shadowOffset = CGSize.zero
        
        
       
        img_SorryFace.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        img_SorryFace.layer.shadowOffset = CGSize(width: 0, height: 6)
        img_SorryFace.layer.shadowOpacity = 1.0
        img_SorryFace.layer.shadowRadius = 15.0
        img_SorryFace.layer.masksToBounds = false
       // img_SorryFace.layer.cornerRadius = 4.0
        
    }
   
    override func viewDidAppear(_ animated: Bool) {
        //createParticles()
        
        get_Scratches_Info()
        img_ScreenShot = self.takeScreenshot(false)
         
        btn_RemainTS.backgroundColor = UIColor.white
        
        btn_RemainTS.addShadow()
    }
    

    @IBAction func btn_Close(_ sender: UIButton) {
        //_ = navigationController?.popToRootViewController(animated: false)
        
       
        if Connectivity.isConnectedToInternet {
            kConstantObj.SetMainViewController("VDG_ScratchWinNow_ViewController")
        }else {
            if let currentToast = ToastCenter.default.currentToast {
                
            }else {
                Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
                
            }
        }
    }
    @IBAction func btn_Help(_ sender: UIButton) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Help_Scratch_Win_ViewController") as! VDG_Help_Scratch_Win_ViewController
        secondViewController.img_Bk = img_ScreenShot
        secondViewController.str_Descptn = "- Move your finger on the scratch card for your chance to win\n\n- Keep scratching until your win prize is clearly visible"
        self.navigationController?.present(secondViewController, animated: true)
    }
    @IBAction func btn_Invite(_ sender: UIButton) {
        
        GenerateInviteURL.GetURLTemp { (reponse : String) in
            
            if reponse.count > 0 {
                
                let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Invite_ViewController") as! VDG_Invite_ViewController
                secondViewController.img_Bk = self.img_ScreenShot
                secondViewController.str_Invite_URL = reponse
                secondViewController.str_Invite_Title = "VeriDoc Global"
                self.navigationController?.present(secondViewController, animated: true)
            }
        }
    }
    @IBAction func btn_Share(_ sender: UIButton) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Share_ViewController") as! VDG_Share_ViewController
        secondViewController.img_Bk = img_ScreenShot;       self.navigationController?.present(secondViewController, animated: true)
    }
    
    
    @IBAction func btn_TryAgain(_ sender: UIButton) {
        
       // _ = navigationController?.popToRootViewController(animated: false)
        kConstantObj.SetMainViewController("VDG_ScratchWinNow_ViewController")
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
    
    func UpdateScratches() {
        
        
        var ref = Database.database().reference() // undeclared
        
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        
        let userID = userDetail!["customerguid"] as! String
        let str_Date = UserDefaults.standard.object(forKey: "C_D") as! String
        
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
                var dic_Info = snapshot.value as! [String: AnyObject]
                
                let str_Tmp = dic_Info["today_date"] as! String
                
                print(str_Tmp)
                
              //  if str_Tmp == str_Date {
                    
                     let old_total_scratch = dic_Info["remaining_level_scratch"] as! Int
                    
                     let str_RemainScratches = old_total_scratch - 1
                    
                     let old_today_used_scratch = dic_Info["today_use_scratch"] as! Int
                     let old_total_level_scratch = dic_Info["total_level_scratch"] as! Int
                   
                     let str_NewS_PerDay = old_today_used_scratch + 1
                     let New_total_level_scratch = old_total_level_scratch + 1
                        
                    dic_Info["remaining_level_scratch"] = str_RemainScratches as AnyObject
                    dic_Info["today_use_scratch"] = str_NewS_PerDay  as AnyObject
                    dic_Info["total_level_scratch"] = New_total_level_scratch  as AnyObject
                    
                    
                        
                    Database.database().reference().child("Scratch&Win").child(userID).child((userID)+"-Scratch&Win").updateChildValues(dic_Info){ (error, ref) -> Void in
                            
                            if error != nil {
                                
                                Toast(text: error?.localizedDescription).show()
                                
                                return
                            }else {
                                self.get_Scratches_Info()
                                self.Update_History()
                            }
                        }
              
                }
            //}
        })
    }
    
    func Update_History(){
        
        
        var ref = Database.database().reference() // undeclared
        
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        
        let userID = userDetail!["customerguid"] as! String
        let str_Date = UserDefaults.standard.object(forKey: "C_D") as! String
        
        
        var dic_Histrory: Dictionary = [String: AnyObject]()
        
        
        
        ref = Database.database().reference().child("Scratch&Win").child(userID).child(userID+"-Scratch&Win_history")
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            
            
            
            if snapshot.exists() {
                
                print(snapshot.value as Any)
                
                let dict = snapshot.value as! Dictionary<String, AnyObject>
                
                var arr_Days = Array<AnyObject>()
                
                dict.forEach { item in
                    print(item.value)
                    arr_Days.append(item.value)
                }
                
                let sortedResults = (arr_Days as NSArray).sortedArray(using: [NSSortDescriptor(key: "day", ascending: true)]) as! [[String:AnyObject]]
                
                let dic_LastDayInfo = sortedResults.last! as NSDictionary
                print(arr_Days)
                print(sortedResults)
                print(dic_LastDayInfo)
                
                let Day = dic_LastDayInfo["day"] as! Int
                
                var total_usedDayScratch = dic_LastDayInfo["usedDayScratch"] as! Int
                var str_winAmount = dic_LastDayInfo["winAmount"] as! String
                total_usedDayScratch += 1
                
                if str_winAmount.count == 0 {
                    str_winAmount = str_winAmount + "0"
                }else {
                    str_winAmount = str_winAmount + ",0"
                }
                
                
                var dic_UpdateInfo: Dictionary = [String: AnyObject]()
                
             
                dic_UpdateInfo["usedDayScratch"] = total_usedDayScratch as AnyObject
                dic_UpdateInfo["winAmount"] = str_winAmount as AnyObject
                dic_Histrory["day"] = Day as AnyObject
                dic_Histrory["totalDayScratch"] = Constant.GlobalConstants.str_TotalScratchesPerDay as AnyObject
           
                
                let str_Day = "Day"+String(Day)


                
                Database.database().reference().child("Scratch&Win").child(userID).child((userID)+"-Scratch&Win_history").child(str_Day).updateChildValues(dic_UpdateInfo){ (error, ref) -> Void in
                    
                    PKHUD.sharedHUD.hide()
                    
                    if error != nil {
                        Toast(text: error?.localizedDescription).show()
                        return
                    }else {
                        //Toast(text: "Your document is successfully updated.").show()
                        
                    }
                }
                
                
                
            }
            
            
        })
    }
    
    func get_Scratches_Info() {
        
        var ref = Database.database().reference() // undeclared
        
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        
        let userID = userDetail!["customerguid"] as! String
        
        let str_Date = UserDefaults.standard.object(forKey: "C_D") as! String
        
        //HUD.show(.progress)
        //HUD.show(HUDContentType.rotatingImage(UIImage   (named: "icn_spinner")))
        
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
                
                
                
                let str_Scratch = String(dic_Info["remaining_level_scratch"] as! Int) + " scratches remaining"
        
                self.btn_RemainTS.setTitle(str_Scratch, for: .normal)
                
                if (dic_Info["remaining_level_scratch"] as! Int) >= 2 {
                    self.btn_RemainTS.setTitle(String(dic_Info["remaining_level_scratch"] as! Int) + " scratches remaining", for: .normal)
                }else {
                    self.btn_RemainTS.setTitle(String(dic_Info["remaining_level_scratch"] as! Int) + " scratch remaining", for: .normal)
                }
                
                
                 let trackStep = dic_Info["total_used_scratch"]  as! Int
                
                 if  trackStep == Constant.GlobalConstants.str_ScratchforThirdStep {
                      self.btn_TryAgain.setTitle("CONTINUE", for: .normal)
                 }else{
                       self.btn_TryAgain.setTitle("TRY AGAIN", for: .normal)
                 }
                
                
                
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
