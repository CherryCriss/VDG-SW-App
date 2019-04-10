//
//  VDG_Finished_LevelUp_ViewController.swift
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
import AudioToolbox


class VDG_Finished_LevelUp_ViewController: UIViewController {
    
    @IBOutlet var btn_Rule: UIButton!
    @IBOutlet var btn_Close: UIButton!
    @IBOutlet var btn_Share: UIButton!
    @IBOutlet var img_BKView: UIImageView!
    var img_ScreenShot: UIImage!
    @IBOutlet var lbl_RemainTS: UILabel!
    
    var img_BK: UIImage!
    
    var window: UIWindow?

    override func viewDidLoad() {
        super.viewDidLoad()
      self.navigationController?.navigationBar.isHidden = true
        img_BKView.image = img_BK
        img_ScreenShot = self.takeScreenshot(false)
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        
         self.navigationController?.navigationBar.isHidden = true
        
        img_ScreenShot = self.takeScreenshot(false)
        
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        
    }
    @IBAction func btn_Rule(_ sender: UIButton){
   //     dismiss(animated: false, completion: nil)
        
//        let mainVcIntial = kConstantObj.SetIntialMainViewController("VDG_ScanNowLoading_ViewController")
//        self.window?.rootViewController = mainVcIntial
    }
    @IBAction func btn_Close(_ sender: UIButton){
        UserDefaults.standard.set(true, forKey: "detectLevelupScreen")
        UserDefaults.standard.synchronize()
        self.dismiss(animated: false, completion: nil)

    }
    @IBAction func btn_Share(_ sender: UIButton){
        
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Share_ViewController") as! VDG_Share_ViewController
        secondViewController.img_Bk = img_ScreenShot
        self.present(secondViewController, animated: true)
        
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
               
                self.lbl_RemainTS.text = dic_Info["remaining_level_scratch"] as! String + " scratches remaining"
                
                if (dic_Info["remaining_level_scratch"] as! Int) >= 2 {
                    self.lbl_RemainTS.text = (String(dic_Info["remaining_level_scratch"] as! Int) + " scratches remaining")
                }else {
                    self.lbl_RemainTS.text = (String(dic_Info["remaining_level_scratch"] as! Int) + " scratch remaining")
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
