//
//  VDG_ScratchWinNow_ViewController.swift
//  VeriDocG
//
//  Created by Bhavdip Patel on 09/10/18.
//  Copyright © 2018 SevenBits. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase
import FirebaseAuth
import FirebaseDatabase
import NVActivityIndicatorView
import PKHUD
import ZAlertView

class VDG_ScratchWinNow_ViewController: UIViewController {

    // out of scratch per day
    @IBOutlet var vw_outofSctach_BK: UIView!
    @IBOutlet var scroll_outofscratchperDay: UIScrollView!
    @IBOutlet var img_outofscratches: UIImageView!
    
    // available scratch for the day
    @IBOutlet var vw_AvailableScratch_BK: UIView!
    @IBOutlet var btn_ScratchNow: UIButton!
    @IBOutlet var scroll_AvailablescratchperDay: UIScrollView!
    @IBOutlet var img_ScratchAndWin: UIImageView!
    
    
    
    // out of total scratch
    @IBOutlet var vw_outoftotalscratch_BK: UIView!
    @IBOutlet var btn_download: UIButton!
    @IBOutlet var scroll_outoftotalscratch: UIScrollView!
    @IBOutlet var img_outoftotalscratch: UIImageView!
    
    @IBOutlet var vw_RemainScratches: UIView!
   
    @IBOutlet var lbl_availableToday: UILabel!
    @IBOutlet var lbl_guideInfo: UILabel!
    @IBOutlet var lbl_RemainTS: UIButton!
    @IBOutlet var lbl_AvailableScratch: UILabel!
    @IBOutlet var img_ImgView: UIImageView!
   
    @IBOutlet var btn_Invite : UIButton!
    @IBOutlet var btn_Share : UIButton!
    var isOutOfScratch : Bool = false
   // @IBOutlet var img_Hand: UIImageView!
    @IBOutlet var btn_Share_Facus : UIButton!
    var isFinishedScratchForDay : Bool = false
    
    var totalscratchPerDay = Int()
    var totalscratchPerLevel = Int()
    var totalUsedscratch = Int()
    var today_avialble_scracth = Int()
    
    @IBOutlet var vw_BK_OutPerDay : UIView!
    @IBOutlet var btn_BuyNow : UIButton!
    @IBOutlet var lbl_Msg1 : UILabel!
    
    
    
    // Share View
    var isShareView: Bool = false
    
    var window: UIWindow?

    
    
    var img_ScreenShot: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
          self.navigationController?.navigationBar.isHidden = true
        // Do any additional setup after loading the view.
        
         NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ani"), object: nil)
        
       
         lbl_RemainTS.addShadow()
        
        
        NotificationCenter.default.removeObserver(self, name:  Notification.Name("UpdateScreen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.UpdateScreen), name: Notification.Name("UpdateScreen"), object: nil)
        
       
       
       
        
    }
    @objc func UpdateScreen(notfication: NSNotification) {
        
        
        
        get_Scratches_Info()
        
        
    }
  
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        
       
            UserDefaults.standard.set("2", forKey: "tooltipscratch")
            UserDefaults.standard.synchronize()
       
       

        
        
      self.vw_BK_OutPerDay.isHidden = true
      self.vw_AvailableScratch_BK.isHidden = true
      self.vw_outoftotalscratch_BK.isHidden = true
      
      get_Scratches_Info()
      
        
    }
  
    override func viewDidDisappear(_ animated: Bool) {
       
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        
       
       
      
    }
 
    
   

    override func viewDidAppear(_ animated: Bool) {
      
        self.navigationController?.navigationBar.isHidden = true
    
    }
    
    
    @objc func runTimedCode() {
        // Something cool
        
        if isOutOfScratch == true {
            
            vw_outofSctach_BK.isHidden = false
            lbl_guideInfo.isHidden = false
            lbl_availableToday.isHidden = false
            scroll_outofscratchperDay.isHidden = false
            img_ImgView.isHidden = true
            btn_ScratchNow.isHidden = true
           
           
//            // specify the property you want to animate
//            let zoomInAndOut = CABasicAnimation(keyPath: "transform.scale")
//            // starting from the initial value 1.0
//            zoomInAndOut.fromValue = 1.0
//            // to scale down you set toValue to 0.5
//            zoomInAndOut.toValue = 0.5
//            // the duration for the animation is set to 1 second
//            zoomInAndOut.duration = 16.0
//            // how many times you want to repeat the animation
//            zoomInAndOut.repeatCount = .infinity
//            // to make the one animation(zooming in from 1.0 to 0.5) reverse to two animations(zooming back from 0.5 to 1.0)
//            zoomInAndOut.autoreverses = true
//            // because the animation consists of 2 steps, caused by autoreverses, you set the speed to 2.0, so that the total duration until the animation stops is 5 seconds
//            zoomInAndOut.speed = 5.0
//            // add the animation to your button
//            img_ImgView.layer.add(zoomInAndOut, forKey: nil)
            
            img_ImgView.zoomFirst1()
         
            let pulseEffect = LFTPulseAnimation(repeatCount: Float.infinity, radius:120, position:btn_Share_Facus.center)
            vw_outofSctach_BK.layer.insertSublayer(pulseEffect, below: btn_Share_Facus.layer)
        }
        else {
            
            vw_outofSctach_BK.isHidden = true
            lbl_guideInfo.isHidden = true
            lbl_availableToday.isHidden = false
            scroll_outofscratchperDay.isHidden = false
            img_ImgView.isHidden = false
            btn_ScratchNow.isHidden = false
        }
        
        self.img_ScreenShot = self.takeScreenshot(false)
    }
  
    
    @IBAction func btn_BackButton(_ sender: UIButton)  {
       

        if Connectivity.isConnectedToInternet {
            
             kConstantObj.SetMainViewController("VDG_ScratchWinHome_ViewController")
            
        }else {
            
            if let currentToast = ToastCenter.default.currentToast {
                
            }else {
                Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
            }
        }
    }
    
    
    @IBAction func btn_Help(_ sender: UIButton)  {
        
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Help_Scratch_Win_ViewController") as! VDG_Help_Scratch_Win_ViewController
        secondViewController.img_Bk = img_ScreenShot
        secondViewController.str_Descptn = "- Click SCRATCH NOW to begin.\n\n- You can only scratch 3 times per day.\n\n- Scratches Remaining are the total number of scratches you have before you need a refill"
        self.present(secondViewController, animated: true)
        
    }
    
    func CreatingScratchedButton_OutOfScratch(btn_totalScratche: Int) {
        
        scroll_outofscratchperDay.isScrollEnabled = true
        scroll_outofscratchperDay.isUserInteractionEnabled = true
        
        let totalButton = btn_totalScratche
        
        let numberOfButtons = Constant.GlobalConstants.str_TotalScratchesPerDay*2
        let numberofRows = 1
        
        var count = 0
        var px = 0
        var py = 0
        
        for _ in 1...numberofRows {
            
        let D_W = self.view.frame.size.width
        print(D_W)
        var spaceValue = 0
        if D_W == 375.0 {
            
            spaceValue = 140
            
        }else if D_W == 320.0 {
            
           spaceValue = 110
            
        }else if D_W == 414.0 {
            spaceValue = 160
        }
            
        px = Int(scroll_outofscratchperDay.frame.width)/2 - ((50*numberOfButtons/2)/2)
            
            if count < numberOfButtons/2 {
                
                for j in 1...numberOfButtons/2 {
                    
                    count += 1
                    
                    let Button = UIButton()
                    Button.tag = count
                    Button.frame = CGRect(x: px+10, y: py, width: 45, height: 45)
                    
                 
                        
                        Button.setBackgroundImage(UIImage(named: "out-of-scrach-icon"), for: .normal)
                        Button.isUserInteractionEnabled = false
                        
                    
               
                    
                    Button.addTarget(self, action: #selector(scrollButtonAction), for: .touchUpInside)
                   
                    scroll_outofscratchperDay.addSubview(Button)
                    px = px + Int(scroll_outofscratchperDay.frame.width)/2 - spaceValue
                }
            }
            
            py =  Int(scroll_outofscratchperDay.frame.height)-70
        }
        scroll_outofscratchperDay.contentSize = CGSize(width: px, height: py)
    }
    
    func CreatingAvailableScratchButton(btn_TmptotalScratche: Int) {
        
        
        var btn_totalScratche = btn_TmptotalScratche
        var isLast = false
        if  totalscratchPerLevel >= btn_totalScratche {
            isLast = false
        }else {
            btn_totalScratche = totalscratchPerLevel
            isLast = true
        }
        
        let tmpT = Constant.GlobalConstants.str_TotalScratchesPerDay - totalscratchPerDay
        
        scroll_AvailablescratchperDay.isScrollEnabled = true
        scroll_AvailablescratchperDay.isUserInteractionEnabled = true
        
        let totalButton = btn_totalScratche
        
        let numberOfButtons =  Constant.GlobalConstants.str_TotalScratchesPerDay*2
        let numberofRows = 1
        
        var count = 0
        var px = 0
        var py = 0
        
        for _ in 1...numberofRows {
            
            let D_W = self.view.frame.size.width
            print(D_W)
            var spaceValue = 0
            if D_W == 375.0 {
                
                spaceValue = 140
                
            }else if D_W == 320.0 {
                
                spaceValue = 110
                
            }else if D_W == 414.0 {
                spaceValue = 160
            }
            
            px = Int(scroll_AvailablescratchperDay.frame.width)/2 - ((50*numberOfButtons/2)/2)
            
            if count < numberOfButtons/2 {
                
                for j in 1...numberOfButtons/2 {
                    
                    count += 1
                    
                    let Button = UIButton()
                    Button.tag = count
                    Button.frame = CGRect(x: px+10, y: py, width: 45, height: 45)
                    
                   // if isLast == false {
                        
                        if count <= tmpT {
                            
                            Button.setBackgroundImage(UIImage(named: "icn_used_scratches"), for: .normal)
                            Button.isUserInteractionEnabled = false
                         
                        }else {
                            
                            Button.setBackgroundImage(UIImage(named: "icn_pending_scratches"), for: .normal)
                            Button.isUserInteractionEnabled = true
                        }
                        
                  //  }else{
                  //      Button.setBackgroundImage(UIImage(named: "icn_pending_scratches"), for: .normal)
                  //      Button.isUserInteractionEnabled = true
                  //  }
                    
                    
                    Button.addTarget(self, action: #selector(scrollButtonAction), for: .touchUpInside)
                    
                    scroll_AvailablescratchperDay.addSubview(Button)
                    px = px + Int(scroll_AvailablescratchperDay.frame.width)/2 - spaceValue
                }
            }
            
            py =  Int(scroll_AvailablescratchperDay.frame.height)-70
        }
        scroll_AvailablescratchperDay.contentSize = CGSize(width: px, height: py)
    }
    
  
        
    @objc func scrollButtonAction(sender: UIButton) {
        print("Hello \(sender.tag) is Selected")
    }
    
    
    @IBAction func btn_BuyhNow(_ sender: UIButton) {
        
    
       if Connectivity.isConnectedToInternet {
    
        let alertController = UIAlertController(title: "Alert", message: "Coming Soon", preferredStyle: UIAlertControllerStyle.alert)
        
        
        let saveAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: { alert -> Void in
            
            
            
        })
        
        
        alertController.addAction(saveAction)
        
        
        self.present(alertController, animated: true, completion: nil)
        
        
       }else{
           Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
       }
        
    }
    
    @IBAction func btn_ScratchNow(_ sender: UIButton) {
        
        
   
        if Connectivity.isConnectedToInternet {
        
                if self.totalscratchPerLevel > 0 {
                
                if isFinishedScratchForDay == true {
                    
                    
                    
                    let alertController = UIAlertController(title: "Coming Soon", message: "", preferredStyle: UIAlertControllerStyle.alert)
                   
                    
                    let saveAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: { alert -> Void in
                       
                        
                        
                    })
                
                    
                    alertController.addAction(saveAction)
                   
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                }else {
                    self.navigationController?.navigationBar.isHidden = false
                    

                    
                    kConstantObj.SetMainViewController("VDG_Scratching_ViewController")
                }
                }
       
        
        }else {
            Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
        }

       
        
    }
    
    @IBAction func btn_DownloadNow(_ sender: UIButton) {
      if Connectivity.isConnectedToInternet {
        if isShareView == true {
            


        
            let attributedString = NSAttributedString(string: "Update Required", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 22),
                                                                                    NSAttributedStringKey.foregroundColor : ConstantsModel.ColorCode.kColor_Theme])
            
            let alert = UIAlertController(title: "", message: "\nThere is a new version of this application ready for download in App Store.\nPlease update your application to keep winning by clicking the button below",  preferredStyle: .alert)
            alert.setValue(attributedString, forKey: "attributedTitle")
            alert.view.tintColor = UIColor.black
            
            let close = UIAlertAction(title: "Cancel",
                                      style: .default) { (action: UIAlertAction!) -> Void in
                                        
                                        
                                        
                                        self.dismiss(animated: true, completion: nil)
                                        
                                        
                                        
            }
            
            // close.setValue(Constant.GlobalConstants.kColor_Theme, forKey: "titleTextColor")
            
            alert.addAction(close)
            
            let update = UIAlertAction(title: "Update",
                                       style: .default) { (action: UIAlertAction!) -> Void in
                                        
                                        self.dismiss(animated: true, completion: nil)
                                        
                                        let str_LINK = ConstantsModel.BasePath.url_appstoreVDGmainapp
                                        guard let url = URL(string: str_LINK) else { return }
                                        UIApplication.shared.open(url)
                                        
            }
            
            update.setValue(Constant.GlobalConstants.kColor_Theme, forKey: "titleTextColor")
            
            alert.addAction(update)
            
            self.present(alert, animated: true,
                         completion: nil)
            
            
        }else {
            
            checkMainAppInstalled()
            
           
        }
    }else {
        Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
    }
        
    }
    
    
    @IBAction func btn_Invite(_ sender: UIButton) {
        
        
        GenerateInviteURL.GetURLTemp { (reponse : String) in
            
            if reponse.count > 0 {
            
                let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Invite_ViewController") as! VDG_Invite_ViewController
                secondViewController.img_Bk = self.img_ScreenShot
                secondViewController.str_Invite_URL = reponse
                    secondViewController.str_Invite_Title = "VeriDoc Global"
                self.present(secondViewController, animated: true)
            }
        }
        
        
        
        
    }
    @IBAction func btn_Share(_ sender: UIButton) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Share_ViewController") as! VDG_Share_ViewController
        secondViewController.img_Bk = img_ScreenShot
        self.present(secondViewController, animated: false)
        
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
        //HUD.show(HUDContentType.rotatingImage(UIImage(named: "icn_spinner")))
        
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
                
                
                let dic_Info = snapshot.value as! [String : AnyObject]
                
                let str_Tmp = dic_Info["today_date"] as! String
                
                print(str_Tmp)
                
                
              if str_Tmp == str_Date {
                
                                if (dic_Info["remaining_level_scratch"] as! Int) >= 2 {
                                    self.lbl_RemainTS.setTitle(String(dic_Info["remaining_level_scratch"] as! Int) + " scratches remaining", for: .normal)
                                }else {
                                     self.lbl_RemainTS.setTitle(String(dic_Info["remaining_level_scratch"] as! Int) + " scratch remaining", for: .normal)
                                }
                
                
                                print(dic_Info)
                                self.totalscratchPerLevel = dic_Info["remaining_level_scratch"]  as! Int
                                let total_used_scratch = dic_Info["total_used_scratch"]  as! Int
                                self.today_avialble_scracth = dic_Info["today_avialble_scracth"] as! Int
                                let isVDGmainAppInstall = dic_Info["isVDGmainAppInstall"]  as! Bool
                
                                //
                                self.totalscratchPerDay = dic_Info["today_avialble_scracth"] as! Int
                                self.totalUsedscratch = dic_Info["today_use_scratch"] as! Int
                                let total_level_scratch = dic_Info["total_level_scratch"] as! Int
                                let total_used_scratched = dic_Info["total_used_scratch"] as! Int
                
                                var perCent = (Float(total_level_scratch - self.totalscratchPerLevel) * 100.00) / Float(Constant.GlobalConstants.str_scratch_FirstLevel)
                
                                if perCent <= 1.0  {
                                    perCent  =  1.0
                                }else if perCent >= 100.00 {
                                    let mainVcIntial = kConstantObj.SetIntialMainViewController("VDG_ScanNowLoading_ViewController")
                                    self.window?.rootViewController = mainVcIntial
                                }
                
                
                                if self.totalscratchPerLevel <= 0  {
                                    
                                    
                                    if total_used_scratch == Constant.GlobalConstants.str_ScratchforFirstStep {
                                        
                                        if isVDGmainAppInstall == false {
                                            
                                            self.isShareView = false
                                            
                                          
                                            self.btn_download.setBackgroundImage(UIImage(named: ""), for: .normal)
                                             self.lbl_guideInfo.text = ""
                                            
                                            self.lbl_AvailableScratch.isHidden = true
                                            
                                     
                                            let attributedString = NSAttributedString(string: "Alert", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 24),
                                                                                                                      NSAttributedStringKey.foregroundColor : ConstantsModel.ColorCode.kColor_Theme])
                                            
                                            let alert = UIAlertController(title: "", message: "\nWould you like to download VeriDoc Global's QR Scanner which comes with brand new technology that can take QR code scanning to next level of possibilities?\n",  preferredStyle: .alert)
                                            alert.setValue(attributedString, forKey: "attributedTitle")
                                            alert.view.tintColor = UIColor.black
                                            
                                            let btn_Yes = UIAlertAction(title: " YES ",
                                                                           style: .default) { (action: UIAlertAction!) -> Void in
                                                                          
                                                                            if Connectivity.isConnectedToInternet {
                                                                                 self.dismiss(animated: true, completion: nil)
                                                                                 self.checkMainAppInstalled()
                                                                                
                                                                            }else {
                                                                                Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
                                                                            }
                                                                            
                                                                            
                                                                            
                                            }
                                            
                                            
                                            let btn_No = UIAlertAction(title: " NO ",
                                                                           style: .default) { (action: UIAlertAction!) -> Void in
                                                                            
                                                                          if Connectivity.isConnectedToInternet {
                                                                                 self.dismiss(animated: true, completion: nil)
                                                                                self.checkDeviceExit(isNo: true)
                                                                                
                                                                            }else {
                                                                                  Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
                                                                            }
                                                                            
                                                                            
                                            }
                                            
                                            
                                            btn_No.setValue(Constant.GlobalConstants.kColor_Theme, forKey: "titleTextColor")
                                            alert.addAction(btn_No)
                                            btn_Yes.setValue(Constant.GlobalConstants.kColor_Theme, forKey: "titleTextColor")
                                            alert.addAction(btn_Yes)
                                            
                                            self.present(alert, animated: true,
                                                         completion: nil)
                                        
                                        }
                                    }else  {
                                        
                                        self.isShareView = true
//                                        self.btn_download.setBackgroundImage(UIImage(named: "icn_sharenow_new"), for: .normal)
//                                        self.lbl_guideInfo.text = "Share blog to get more\n scratches and keep winning."
                                        
                                        self.lbl_AvailableScratch.isHidden = true
                                        
                                        self.btn_download.setBackgroundImage(UIImage(named: ""), for: .normal)
                                        self.lbl_guideInfo.text = ""
                                        
                                        if total_used_scratched < Constant.GlobalConstants.str_scratch_FirstLevel {
                                            
                                            let attributedString = NSAttributedString(string: "Alert", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 24),
                                                                                                                    NSAttributedStringKey.foregroundColor : ConstantsModel.ColorCode.kColor_Theme])
                                            
                                            let alert = UIAlertController(title: "", message: "\nWould you like to share a blog to your social media, to educate your friends about how to contribute to a safer and verified world of document sharing?\n",  preferredStyle: .alert)
                                            alert.setValue(attributedString, forKey: "attributedTitle")
                                            alert.view.tintColor = UIColor.black
                                            
                                            let btn_Yes = UIAlertAction(title: " YES ",
                                                                        style: .default) { (action: UIAlertAction!) -> Void in
                                                                            
                                                                            
                                                                            if Connectivity.isConnectedToInternet {
                                                                                self.img_ScreenShot = self.takeScreenshot(false)
                                                                                
                                                                                self.dismiss(animated: true, completion: nil)
                                                                                let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Share_ViewController") as! VDG_Share_ViewController
                                                                                secondViewController.img_Bk = self.img_ScreenShot
                                                                                self.present(secondViewController, animated: false)
                                                                            }else {
                                                                                Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
                                                                            }
                                                                            
                                                                            
                                            }
                                            
                                            
                                            let btn_No = UIAlertAction(title: " NO ",
                                                                       style: .default) { (action: UIAlertAction!) -> Void in
                                                                        
                                                                      
                                                                        if Connectivity.isConnectedToInternet {
                                                                           self.dismiss(animated: true, completion: nil)
                                                                            self.UpdateScratches(shareType: " ")
                                                                            
                                                                        }else {
                                                                            Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
                                                                        }
                                                                        
                                            }
                                            
                                            
                                            btn_No.setValue(Constant.GlobalConstants.kColor_Theme, forKey: "titleTextColor")
                                            alert.addAction(btn_No)
                                            btn_Yes.setValue(Constant.GlobalConstants.kColor_Theme, forKey: "titleTextColor")
                                            alert.addAction(btn_Yes)
                                            
                                            self.present(alert, animated: true,
                                                         completion: nil)
                                            
                                           
                                            
                                        }
                                     
                                       
                                        
                                    }
                                    
                                    
                                    
                                    self.totalscratchPerDay = dic_Info["today_avialble_scracth"] as! Int
                                    self.isOutOfScratch = true
                                    self.totalscratchPerDay = dic_Info["today_avialble_scracth"] as! Int
                                    self.totalUsedscratch = dic_Info["today_use_scratch"] as! Int
                                    
                                    
                                    if self.totalscratchPerDay == self.totalUsedscratch {
                                        self.isFinishedScratchForDay = true
                                    }else {
                                        self.isFinishedScratchForDay = false
                                    }
                                    
                                    
                                    self.vw_outoftotalscratch_BK.isHidden = false
                                    
                                    //  self.CreatingOutofTotalScratch(btn_totalScratche: self.totalscratchPerDay)
                                    
                                    _ =  Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.startZoomingAnimation), userInfo: nil, repeats: false)
                                    
                                    
                                    
                                }else {
                                    
                                    
                                    
                                    self.lbl_AvailableScratch.isHidden = false
                                    
                                    if self.totalscratchPerDay <= 0  {
                                        
                                        self.CreatingScratchedButton_OutOfScratch(btn_totalScratche: Constant.GlobalConstants.str_TotalScratchesPerDay)
                                        
                                        self.vw_BK_OutPerDay.isHidden = false
                                        
                                        self.isFinishedScratchForDay = true
                                        
                                        _ =  Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.startZoomingAnimation), userInfo: nil, repeats: false)
                                        
                                    }else {
                                        
                                        self.vw_AvailableScratch_BK.isHidden = false
                                        self.btn_ScratchNow.isHidden = false
                                        self.CreatingAvailableScratchButton(btn_TmptotalScratche: Constant.GlobalConstants.str_TotalScratchesPerDay)
                                        self.isFinishedScratchForDay = false
                                        
                                        _ =  Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.startZoomingAnimation), userInfo: nil, repeats: false)
                                        
                                    }
                                }
              }else {
                let mainVcIntial = kConstantObj.SetIntialMainViewController("VDG_ScanNowLoading_ViewController")
                self.window?.rootViewController = mainVcIntial
                }
                    
                }
//          // }
            
        })
       
    }
    
    @objc func startZoomingAnimation() {
        

        // add the animation to your button
        self.img_ScratchAndWin.zoomFirst1()
        self.img_outofscratches.zoomFirst1()
        self.img_outoftotalscratch.zoomFirst1()
        
      
    }
    
    func isCratcheAvailable() {
        
        if isOutOfScratch == true {
            
            vw_outofSctach_BK.isHidden = true
            lbl_guideInfo.isHidden = false
            img_outofscratches.isHidden = false
            lbl_availableToday.isHidden = false
            scroll_outofscratchperDay.isHidden = false
            img_ImgView.isHidden = true
            btn_ScratchNow.isHidden = true
            
            let D_W = self.view.frame.size.width
            //
            if D_W != 320 {
                
                lbl_availableToday.transform = CGAffineTransform(translationX: 0,
                                                                 y: 60)
                scroll_outofscratchperDay.transform = CGAffineTransform(translationX: 0,
                                                          y: 60)
            }
            
            self.btn_ScratchNow.isHidden = true
            
            Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: false)
            
         
            
            
            
        }else {
            
            vw_outofSctach_BK.isHidden = true
            img_outofscratches.isHidden = true
            //lbl_guideInfo.isHidden = true
            lbl_availableToday.isHidden = false
            scroll_outofscratchperDay.isHidden = false
            img_ImgView.isHidden = false
            btn_ScratchNow.isHidden = false
       
        }
    }
    
    
    func checkMainAppInstalled() {
        
        var ref = Database.database().reference() // undeclared
        
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        
        let userID = userDetail!["customerguid"] as! String
        
        let str_Date = UserDefaults.standard.object(forKey: "C_D") as! String
        
        //HUD.show(.progress)
        //HUD.show(HUDContentType.rotatingImage(UIImage(named: "icn_spinner")))
        
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
                let dic_Info = snapshot.value as!  [String: AnyObject]
                
                let str_Tmp = dic_Info["today_date"] as! String
                
                print(str_Tmp)
                
                
                
                
                let old_total_level_scratch = dic_Info["total_level_scratch"] as! Int
                
                
                let old_total_used_scratch = dic_Info["total_used_scratch"] as! Int
                let currentLevel = dic_Info["current_level"] as! Int
                
                
                let trackStep = old_total_used_scratch
                
                if trackStep <= Constant.GlobalConstants.str_ScratchforFirstStep {
                    
                    if trackStep == Constant.GlobalConstants.str_ScratchforFirstStep {
                        
                        let old_isVDGmainAppInstall = dic_Info["isVDGmainAppInstall"] as! Bool
                        
                        if old_isVDGmainAppInstall == false {
                            
                            let isMainAppInstalledInDevice = ConstantsModel.isMainAppInstalledonDevice()
                            
                            if isMainAppInstalledInDevice == true {
                                
                                self.checkDeviceExit(isNo: false)
                                
                            }else {
                                
                                if let url = URL(string: ConstantsModel.BasePath.url_appstoreVDGmainapp),
                                    UIApplication.shared.canOpenURL(url){
                                    UIApplication.shared.open(url, options: [:]) { (opened) in
                                        if(opened){
                                            print("App Store Opened")
                                        }
                                    }
                                } else {
                                    print("Can't Open URL on Simulator")
                                }
                                
                            }
                        }
                    }
                }
                
            }
            
        })
        
    }
    
    func AddScratchOnInstalledMainApp(strMsg: String) {
        
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
                
                let old_TotalScratch = dic_Info["remaining_level_scratch"] as! Int
                let old_total_level_scratch = dic_Info["total_level_scratch"] as! Int
                let old_today_use_scratch = dic_Info["today_use_scratch"] as! Int
                
                
                let PendingScratch = Constant.GlobalConstants.str_TotalScratchesPerDay - old_today_use_scratch
                
                
                
                let str_NewRemaining = Constant.GlobalConstants.str_addScratchonMainAppDownloaded + old_TotalScratch
                
                let str_Newold_total_level_scratch = Constant.GlobalConstants.str_addScratchonMainAppDownloaded +  old_total_level_scratch
                
                dic_Info["remaining_level_scratch"] = str_NewRemaining as AnyObject
                dic_Info["total_level_scratch"] = str_Newold_total_level_scratch as AnyObject
                dic_Info["isVDGmainAppInstall"] = true as AnyObject
                dic_Info["today_avialble_scracth"] = PendingScratch as AnyObject
                
                Database.database().reference().child("Scratch&Win").child(userID).child((userID)+"-Scratch&Win").updateChildValues(dic_Info){ (error, ref) -> Void in
                    
                    if error != nil {
                        
                        Toast(text: error?.localizedDescription).show()
                        self.viewWillAppear(true)
                        
                        return
                    }else {
                        
                         let deviceID = UIDevice.current.identifierForVendor?.uuidString
                        
                        let ref1 = Database.database().reference() // undeclared
                        
                        var ImageDataDictionary: Dictionary = [String: AnyObject]()
                        ImageDataDictionary[deviceID!] = deviceID as AnyObject
                        ref1.child("Scratch&Win").child("device_unique_id").child(deviceID!).setValue(deviceID!)
                        
                        
                        let attributedString = NSAttributedString(string: "Congratulations", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 22),
                                                                                                          NSAttributedStringKey.foregroundColor : ConstantsModel.ColorCode.kColor_Theme])
                        
                        let alert = UIAlertController(title: "", message: strMsg,  preferredStyle: .alert)
                        alert.setValue(attributedString, forKey: "attributedTitle")
                        alert.view.tintColor = UIColor.black
                        
                        let LOGINAGAIN = UIAlertAction(title: " Continue ",
                                                       style: .default) { (action: UIAlertAction!) -> Void in
                                                        
                                                        
                                                        
                                                        self.dismiss(animated: true, completion: nil)
                                                        
                                                        
                                                        
                        }
                        
                        
                        
                        LOGINAGAIN.setValue(Constant.GlobalConstants.kColor_Theme, forKey: "titleTextColor")
                        
                        alert.addAction(LOGINAGAIN)
                        
                        self.present(alert, animated: true,
                                     completion: nil)
                        
                        
                         self.viewWillAppear(true)
                    }
                    
                }
            }
        })
        
    }
    
    func checkDeviceExit(isNo: Bool){
        
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        
        ref.child("Scratch&Win").child("device_unique_id").observeSingleEvent(of: .value, with: { (snapshot) in
            
            
            
            let deviceID = UIDevice.current.identifierForVendor?.uuidString
            
            if snapshot.hasChild(deviceID!){
                
                let attributedString = NSAttributedString(string: "Sorry!!", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 22),
                                                                                                  NSAttributedStringKey.foregroundColor : ConstantsModel.ColorCode.kColor_Theme])
                
                let alert = UIAlertController(title: "", message: "\nWe have found that you have already installed the VeriDoc Global application and have claimed the free scratches from this phone. \n As part of our terms and conditions, you can only register to play Scratch and Win once from a single device. \nPlease Re-Login this account in a different device which hasn\'t been used to win scratches yet, to keep winning more Points.\n",  preferredStyle: .alert)
                alert.setValue(attributedString, forKey: "attributedTitle")
                alert.view.tintColor = UIColor.black
                
                let LOGINAGAIN = UIAlertAction(title: " Close ",
                                               style: .default) { (action: UIAlertAction!) -> Void in
                                                
                                               
                                                
                                                self.dismiss(animated: true, completion: nil)
                                               kConstantObj.SetMainViewController("VDG_ScratchWinHome_ViewController")
                                                
                                                
                                                
                }
                
                
                
                LOGINAGAIN.setValue(Constant.GlobalConstants.kColor_Theme, forKey: "titleTextColor")
                
                alert.addAction(LOGINAGAIN)
                
                self.present(alert, animated: true,
                             completion: nil)
              
                
            }else{
                
                print("Device Not Exit")
                
               

                if isNo == true {
                    self.AddScratchOnInstalledMainApp(strMsg: "\nCongrats for winning more scratches.\n")
                }else {
                    self.AddScratchOnInstalledMainApp(strMsg: "\nWe have found that you have already installed the VeriDoc Global app. \n Congrats for winning more scratches.\n")
                }
                
                
               
                
                
            }
        })
        
    }
    
    func UpdateScratches(shareType: String) {
        
        var ref = Database.database().reference() // undeclared
        
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        
        let userID = userDetail!["customerguid"] as! String
        
        
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
                
                let str_Tmp = dic_Info["today_date"]
                
                print(str_Tmp)
                
                
                
                
                
                let old_TotalScratch = dic_Info["remaining_level_scratch"] as! Int
                let old_total_level_scratch = dic_Info["total_level_scratch"] as! Int
                let old_today_use_scratch = dic_Info["today_use_scratch"] as! Int
        
                
                let PendingScratch = Constant.GlobalConstants.str_TotalScratchesPerDay - old_today_use_scratch
                
                var scratchperShared = 0
                
                //if self.isBlogShare == true {
                scratchperShared = Constant.GlobalConstants.str_TotalScratchesPerShared
                
      
                
                let str_NewTS = scratchperShared + old_TotalScratch
                
                let str_Newtotal_level_scratch = scratchperShared + old_total_level_scratch
                
                dic_Info["remaining_level_scratch"] = str_NewTS as AnyObject
                dic_Info["total_level_scratch"] = str_Newtotal_level_scratch as AnyObject
                dic_Info["is_today_share"] = true as AnyObject
                dic_Info["today_avialble_scracth"] = PendingScratch as AnyObject
                
                Database.database().reference().child("Scratch&Win").child(userID).child((userID)+"-Scratch&Win").updateChildValues(dic_Info){ (error, ref) -> Void in
                    
                    if error != nil {
                        
                        Toast(text: error?.localizedDescription).show()
                        
                        return
                    }else {
                        
//                        let attributedString = NSAttributedString(string: "Congratulations", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 22),
//                                                                                                          NSAttributedStringKey.foregroundColor : ConstantsModel.ColorCode.kColor_Theme])
//                        
//                        let alert = UIAlertController(title: "", message: "This can remain same",  preferredStyle: .alert)
//                        alert.setValue(attributedString, forKey: "attributedTitle")
//                        alert.view.tintColor = UIColor.black
//                        
//                        let LOGINAGAIN = UIAlertAction(title: " Continue ",
//                                                       style: .default) { (action: UIAlertAction!) -> Void in
//                                                        
//                                                        
//                                                        
//                                                        self.dismiss(animated: true, completion: nil)
//                                                        
//                                                        
//                                                        
//                        }
//                        
//                        
//                        
//                        LOGINAGAIN.setValue(Constant.GlobalConstants.kColor_Theme, forKey: "titleTextColor")
//                        
//                        alert.addAction(LOGINAGAIN)
//                        
//                        self.present(alert, animated: true,
//                                     completion: nil)
                        
                        self.viewWillAppear(true)
                    }
                    
                    
                    
                    
                    
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
