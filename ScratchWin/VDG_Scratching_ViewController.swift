//
//  VDG_Scratching_ViewController.swift
//  VeriDocG
//
//  Created by Bhavdip Patel on 11/10/18.
//  Copyright © 2018 SevenBits. All rights reserved.
//

import UIKit

import SwiftKeychainWrapper
import Firebase
import FirebaseAuth
import FirebaseDatabase
import ScratchCard
import PKHUD
import NVActivityIndicatorView
import AVFoundation

class VDG_Scratching_ViewController: UIViewController, ScratchUIViewDelegate, AVAudioPlayerDelegate {

    var isScratchDone: Bool!
    @IBOutlet var btn_Close: UIButton!
    @IBOutlet var btn_Help: UIButton!
    @IBOutlet var vw_Scraching: UIView!
    @IBOutlet var img_RandomImg: UIImageView!
    var scratchCard: ScratchUIView!
    var window: UIWindow?
    var old_is_today_win: Bool!
    var totalscratchPerDay = Int()
    var totalUsedscratch = Int()
    var str_ImgName = String()
    var img_ScreenShot: UIImage!
    var NumberForRandomImage = Int()
    var isWin: Bool = false
    var isScratchUpdated: Bool = false
    var TokenWon = Int()
    var ispendingToken: Bool = false
    var isMainAppInstalled: Bool = false
    var audioPlayer: AVAudioPlayer!
    var coinSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "scratch_sound", ofType: "mp3")!)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        
        
       self.navigationController?.navigationBar.isHidden = true
        if (scratchCard != nil) {
            scratchCard.removeFromSuperview()
        }
        
        
       
        TokenWon = self.randomWinToken()
        
     
        
       let dice1 = randomImage()
       str_ImgName = String(dice1)
        
       gettingImg()
        
        let soundURL = Bundle.main.url(forResource: "scratch_sound", withExtension: "mp3")
        do {
            // setting up audio player to play your sound
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL!)
        } catch  {
            // in case any errors occur
            print(error)
        }
        
       
        // Do any additional setup after loading the view.
    }
    
    func gettingImg() {
        
        let imgBK = imageforBackScratch()
        
        if imgBK == nil {
            
            gettingImg()
           
        }else {
            
            img_RandomImg.image = imgBK
            
            if img_RandomImg.image == nil {
                gettingImg()
            }
        }
    }
    
    func imageforBackScratch() -> UIImage {
        
        print("Image number" + str_ImgName)
        
        return UIImage(named: str_ImgName)!
    }
    override func viewDidAppear(_ animated: Bool) {
        
 
 
            self.navigationController?.navigationBar.isHidden = true
            
            if (scratchCard != nil) {
                scratchCard.removeFromSuperview()
            }
            print("img number:" + str_ImgName)
            img_RandomImg.image = imageforBackScratch()

            // scratchCard.coupponPath = "rewerre"
            
            NumberForRandomImage = randomNumber()
            print(self.totalscratchPerDay)
            
           
            
            UpdateScratches()
            
            self.img_ScreenShot = self.takeScreenshot(false)
        
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
       
        
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
                
               // if str_Tmp == str_Date {
                    
                    
                    
                    
                    let old_total_level_scratch = dic_Info["total_level_scratch"] as! Int
                    
                    
                    let old_total_used_scratch = dic_Info["total_used_scratch"] as! Int
                    let currentLevel = dic_Info["current_level"] as! Int
                    //  let old_TotalScratch = dic_Info["remaining_level_scratch"] as! Int
                    
                    
                    
                    
                    if currentLevel == 1 {
                        
                        let trackStep = old_total_used_scratch
                        
                        if trackStep <= Constant.GlobalConstants.str_ScratchforFirstStep {
                            
                            if trackStep == Constant.GlobalConstants.str_ScratchforFirstStep {
                                
                                let old_isVDGmainAppInstall = dic_Info["isVDGmainAppInstall"] as! Bool
                                
                                if old_isVDGmainAppInstall == false {
                                    
                                    
                                    let isMainAppInstalledInDevice = ConstantsModel.isMainAppInstalledonDevice()
                                    
                                    if isMainAppInstalledInDevice == true {
                                        
                                        self.AddScratchOnInstalledMainApp()
                                        
                                    }
                                }
                            }
                        }
                        
                    }
                    
              //  }
                
                
                
            }
            
        })
        
    }
    
    func AddScratchOnInstalledMainApp() {
        
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
                
                
                
                let str_NewRemaining = Constant.GlobalConstants.str_addScratchonMainAppDownloaded + old_TotalScratch
                
                let str_Newold_total_level_scratch = Constant.GlobalConstants.str_addScratchonMainAppDownloaded +  old_total_level_scratch
                
                dic_Info["remaining_level_scratch"] = str_NewRemaining as AnyObject
                dic_Info["total_level_scratch"] = str_Newold_total_level_scratch as AnyObject
                dic_Info["isVDGmainAppInstall"] = true as AnyObject
                
                
                Database.database().reference().child("Scratch&Win").child(userID).child((userID)+"-Scratch&Win").updateChildValues(dic_Info){ (error, ref) -> Void in
                    
                    if error != nil {
                        
                        Toast(text: error?.localizedDescription).show()
                        
                        return
                    }else {
                        
                    }
                    
                    
                    
                    
                    
                }
            }
        })
        
    }
    
    
    func randomImage(range: ClosedRange<Int> = 1...15) -> Int {
        
        let min = range.lowerBound
        let max = range.upperBound
        return Int(arc4random_uniform(UInt32(1 + max - min))) + min
        
    }
    func randomNumber(range: ClosedRange<Int> = 1...10) -> Int {
        let min = range.lowerBound
        let max = range.upperBound
        return Int(arc4random_uniform(UInt32(1 + max - min))) + min
    }
    
    //Scratch Began Event(optional)
    func scratchBegan(_ view: ScratchUIView) {
        
        print("scratchBegan")
        // Get the Scratch Position in ScratchCard(coordinate origin is at the lower left corner)
        let position = Int(view.scratchPosition.x).description + "," + Int(view.scratchPosition.y).description
        print(position)
        
    }
    
    
//    func playAudio()
//    {
//        // this is to set the url of the audio
//        let audioURL = URL(fileURLWithPath: Bundle.main.path(forResource: "scratch_sound", ofType: "mp3")!)
//        do
//        {
//             audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
//            audioPlayer.delegate = self
//            if (audioPlayer.prepareToPlay())
//            {
//                audioPlayer.play()
//            }
//        }
//        catch
//        { }
//    }
    
    func playAudioFile() {
        
        
        if audioPlayer.isPlaying == false {
          audioPlayer.play()
        }
    }
    //Scratch Moved Event(optional)
    func scratchMoved(_ view: ScratchUIView) {
    
        if Connectivity.isConnectedToInternet {
            
            playAudioFile()
            
            if isScratchDone == false {
                
                let scratchPercent: Double = self.scratchCard.getScratchPercent()
                
                // self.textField.text = String(format: "%.2f", scratchPercent * 100) + "%"
                print("scratchMoved")
                
                let str_Percentage = String(format: "%.2f", scratchPercent * 100) + "%"
                
                let Percentage = (str_Percentage as NSString).floatValue
                
                if isScratchUpdated == false {
                    
                    
                    
                    if Percentage >= 1.00 {
                        
                        
                        isScratchUpdated = true
                        
                        
                        // let isUnusedLast = self.totalscratchPerDay - 1
                        if ispendingToken == true {
                            isWin = true
                        }else {
                            
                            if NumberForRandomImage <= 5 {
                                
                                isWin = false
                                
                            }else {
                                isWin = true
                                
                            }
                        }
                        
                        if isWin == true {
                            UpdateScratchesWinner()
                        }else {
                            UpdateScratches_Loss()
                        }
                    }
                }
                
                if Percentage >= 70.00 {
                    
                    isScratchDone = true
                    
                    // isWin = true
                    
                    if isWin == false {
                        
                        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Scratch_Sorry_ViewController") as! VDG_Scratch_Sorry_ViewController
                        self.navigationController?.pushViewController(secondViewController, animated: false)
                        
                        
                    }else if isWin == true  {
                        
                        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_ScratchedWinner_ViewController") as! VDG_ScratchedWinner_ViewController
                        secondViewController.TokenWon = TokenWon
                        
                        self.navigationController?.pushViewController(secondViewController, animated: false)
                        
                    }
                }
                
                print(str_Percentage)
                ////Get the Scratch Position in ScratchCard(coordinate origin is at the lower left corner)
                let position = Int(view.scratchPosition.x).description + "," + Int(view.scratchPosition.y).description
                print(position)
            }
            
           
        }else {
            
            if let currentToast = ToastCenter.default.currentToast {
                
            }else {
               Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
                
            }
            
            
        }
       
        
        
       
        
    }
    
    @IBAction func btn_RulePopUp(_ sender: UIButton)  {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Help_Scratch_Win_ViewController") as! VDG_Help_Scratch_Win_ViewController
        secondViewController.img_Bk = img_ScreenShot
        secondViewController.str_Descptn = "- Move your finger on the scratch card for your chance to win.\n\n- Keep scratching until the scratch screen is clearly visible."
        self.navigationController?.present(secondViewController, animated: true)
    }
    @IBAction func btn_Close(_ sender: UIButton)  {
        
      
    // _ = navigationController?.popToRootViewController(animated: false)
        if Connectivity.isConnectedToInternet {
            
            kConstantObj.SetMainViewController("VDG_ScratchWinNow_ViewController")
            
        }else {
            
            if let currentToast = ToastCenter.default.currentToast {
                
            }else {
                Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
            }
        }
    }

    func UpdateScratches() {
        
        var ref = Database.database().reference() // undeclared
        
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        
        let userID = userDetail!["customerguid"] as! String
        let str_Date = UserDefaults.standard.object(forKey: "C_D") as! String
        
        
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
                
             //   if str_Tmp == str_Date {
                   
                    self.old_is_today_win = dic_Info["is_today_win"] as! Bool
                    self.totalscratchPerDay = dic_Info["today_avialble_scracth"] as! Int
                    self.totalUsedscratch = dic_Info["today_use_scratch"] as! Int
                    
                    
                  
          
                    let old_total_level_scratch = dic_Info["total_level_scratch"] as! Int
                     let old_total_used_scratch = dic_Info["total_used_scratch"] as! Int
                    
                    
                    let currentLevel = dic_Info["current_level"] as! Int
                    //  let old_TotalScratch = dic_Info["remaining_level_scratch"] as! Int
                    
                    let old_totalWinningAmount = dic_Info["totalWinningAmount"] as! Int
             
                    
                    if currentLevel == 1 {
                       
                        let trackStep = old_total_used_scratch + 1
                        
                        if trackStep <= Constant.GlobalConstants.str_ScratchforFirstStep {
                            
                            if trackStep == Constant.GlobalConstants.str_ScratchforFirstStep {
                                
                                if old_totalWinningAmount <= Constant.GlobalConstants.str_tokenforFirstStep {
                                    
                                    self.ispendingToken = true
                                    
                                    let temp =  Constant.GlobalConstants.str_tokenforFirstStep - old_totalWinningAmount
                                    self.TokenWon = temp
                                    
                                }
                            }
                            
                        }else if trackStep <= Constant.GlobalConstants.str_ScratchforSecondStep {
                            
                            if trackStep == Constant.GlobalConstants.str_ScratchforSecondStep {
                                
                                if old_totalWinningAmount <= (Constant.GlobalConstants.str_tokenforSecondStep + Constant.GlobalConstants.str_tokenforFirstStep) {
                                    
                                  self.ispendingToken = true
                                    
                                }
                                
                            }
                            
                        }else if trackStep <= Constant.GlobalConstants.str_ScratchforThirdStep {
                            
                            if trackStep == Constant.GlobalConstants.str_ScratchforThirdStep {
                                
                                if old_totalWinningAmount <= (Constant.GlobalConstants.str_tokenforSecondStep + Constant.GlobalConstants.str_tokenforFirstStep + Constant.GlobalConstants.str_tokenforThirdStep) {
                                    
                                    self.ispendingToken = true
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
        
                }
                
                
                var str_ImgStatus: String!
                
             
                
                let isUnusedLast = self.totalscratchPerDay - 1
                
                if self.ispendingToken == true {
                    str_ImgStatus = "icn_winner_screen.png"
                }else {
                    
                    if self.NumberForRandomImage <= 5 {
                        
                            str_ImgStatus = "icn_sorry_screen.png"
                        
                    }else {
                        
                        str_ImgStatus = "icn_winner_screen.png"
                    }
                }
                
                print(str_ImgStatus)
                
                self.self.scratchCard = ScratchUIView(frame: CGRect(x:0, y:0, width:self.vw_Scraching.frame.size.width, height:self.vw_Scraching.frame.size.height), Coupon: str_ImgStatus, MaskImage: "", ScratchWidth: CGFloat(60))
                
                self.scratchCard.delegate = self
                self.vw_Scraching.addSubview(self.scratchCard)
                
                self.isScratchDone = false
           // }
        })
    }
    
    
    func UpdateScratchesWinner() {
        
        
        var ref = Database.database().reference() // undeclared
        
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        
        let userID = userDetail!["customerguid"] as! String
    //    let str_Date = UserDefaults.standard.object(forKey: "C_D") as! String
        
      //  HUD.show(HUDContentType.rotatingImage(UIImage(named: "icn_spinner")))
        
        ref = Database.database().reference().child("Scratch&Win").child(userID).child(userID+"-Scratch&Win")
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            PKHUD.sharedHUD.hide()
            
            if snapshot.exists() {
                
                print(snapshot.value as Any)
                var dic_Info = snapshot.value as! [String: AnyObject]
                
                let str_Tmp = dic_Info["today_date"] as! String
                
                print(str_Tmp)
                
              //  if str_Tmp == str_Date {
                    
                    //let old_total_scratch = Int(dic_Info["a"]!)!
                    
                    // let str_RemainScratches = String(old_total_scratch - 1)
                
                    let currentLevel = dic_Info["current_level"] as! Int
                    let old_TotalScratch = dic_Info["remaining_level_scratch"] as! Int
                    let old_today_avialble_scracth = dic_Info["today_avialble_scracth"] as! Int
                    let old_today_used_scratch = dic_Info["today_use_scratch"] as! Int
                    let old_is_today_win = dic_Info["is_today_win"] as! Bool
                    let old_total_level_scratch = dic_Info["total_level_scratch"] as! Int
                    let old_totalWinningAmount = dic_Info["totalWinningAmount"] as! Int
                    let old_total_used_scratch = dic_Info["total_used_scratch"] as! Int
                  //  let old_tisVDGmainAppInstall = dic_Info["isVDGmainAppInstall"] as! Bool
                    
                  
                        let new_today_avialble_scracth = old_today_avialble_scracth - 1
                        let str_NewTS = old_TotalScratch-1
                        let new_total_used_scratch = old_total_used_scratch + 1
                        let str_NewS_PerDay = old_today_used_scratch + 1
                        let new_total_level_scratch = old_total_level_scratch + 1
                        
                        var new_totalWinningAmount = 00
                        
                
                            
                            
                            
                          let trackStep = old_total_used_scratch + 1
                            
                            
                                 if trackStep <= Constant.GlobalConstants.str_ScratchforFirstStep {
                                    
                                        if trackStep == Constant.GlobalConstants.str_ScratchforFirstStep {
                                            
                                                if old_totalWinningAmount <= Constant.GlobalConstants.str_tokenforFirstStep {
                                                    new_totalWinningAmount = Constant.GlobalConstants.str_tokenforFirstStep
                                                }else {
                                                    new_totalWinningAmount = (self.TokenWon) + old_totalWinningAmount
                                                }
                                
                                        }else {
                                            new_totalWinningAmount = (self.TokenWon) + old_totalWinningAmount
                                        }
                                  }else if trackStep <= Constant.GlobalConstants.str_ScratchforSecondStep {

                                        if trackStep == Constant.GlobalConstants.str_ScratchforSecondStep {

                                            if old_totalWinningAmount <= (Constant.GlobalConstants.str_tokenforSecondStep + Constant.GlobalConstants.str_tokenforFirstStep) {
                                               new_totalWinningAmount = (Constant.GlobalConstants.str_tokenforSecondStep + Constant.GlobalConstants.str_tokenforFirstStep)
                                            }else {
                                                new_totalWinningAmount = (self.TokenWon) + old_totalWinningAmount
                                            }

                                        }else {
                                            new_totalWinningAmount = (self.TokenWon) + old_totalWinningAmount
                                        }

                                  }else if trackStep <= Constant.GlobalConstants.str_ScratchforThirdStep {

                                        if trackStep == Constant.GlobalConstants.str_ScratchforThirdStep {

                                            if old_totalWinningAmount <=  (Constant.GlobalConstants.str_tokenforSecondStep + Constant.GlobalConstants.str_tokenforFirstStep + Constant.GlobalConstants.str_tokenforThirdStep) {
                                                new_totalWinningAmount = (Constant.GlobalConstants.str_tokenforSecondStep + Constant.GlobalConstants.str_tokenforFirstStep + Constant.GlobalConstants.str_tokenforThirdStep  + Constant.GlobalConstants.str_BonusToken_FinishFirstLevel)
                                                
                                            }else {
                                                new_totalWinningAmount = (self.TokenWon) + old_totalWinningAmount
                                            }

                                        }else {
                                            new_totalWinningAmount = (self.TokenWon) + old_totalWinningAmount
                                        }

                                 }
                    
                    
                        
                       
                        
                        
                        
                        
                        dic_Info["remaining_level_scratch"] = str_NewTS as AnyObject
                        dic_Info["today_use_scratch"] = str_NewS_PerDay as AnyObject
                        dic_Info["today_avialble_scracth"] = new_today_avialble_scracth as AnyObject
                        dic_Info["is_today_win"] = false as Bool as AnyObject
                      //  dic_Info["total_level_scratch"] = new_total_level_scratch  as AnyObject
                        dic_Info["totalWinningAmount"] = new_totalWinningAmount as AnyObject
                        dic_Info["total_used_scratch"] = new_total_used_scratch as AnyObject
                            
                            
                        Database.database().reference().child("Scratch&Win").child(userID).child((userID)+"-Scratch&Win").updateChildValues(dic_Info){ (error, ref) -> Void in
                            
                            if error != nil {
                                
                                Toast(text: error?.localizedDescription).show()
                                
                                return
                            }else {
                                self.get_Scratches_Info()
                                self.Update_History_Winner()
                            }
                            
                            
                        }
                    
                }
            //}
        })
    }
    func randomWinToken(range: ClosedRange<Int> = 50...277) -> Int {
        let min = range.lowerBound
        let max = range.upperBound
        return Int(arc4random_uniform(UInt32(1 + max - min))) + min
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
    
    func Update_History_Winner(){
        
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
                
                let dic_LastDayInfo = sortedResults.last! as [String: AnyObject]
                print(arr_Days)
                print(sortedResults)
                print(dic_LastDayInfo)
                
                let Day = dic_LastDayInfo["day"] as! Int
                
                
                var total_usedDayScratch = dic_LastDayInfo["usedDayScratch"] as! Int
                var str_winAmount = dic_LastDayInfo["winAmount"] as! String
                total_usedDayScratch += 1
                
                
                
                let str_Token = String(self.TokenWon)
                
                if str_winAmount.count == 0 {
                    str_winAmount = str_winAmount + str_Token
                }else {
                    str_winAmount = str_winAmount + ","+str_Token
                }
                
                
                var dic_UpdateInfo: Dictionary = [String: AnyObject]()
                
                
                dic_UpdateInfo["usedDayScratch"] = total_usedDayScratch as AnyObject
                dic_UpdateInfo["winAmount"] = str_winAmount as AnyObject
                
                
                dic_Histrory["day"] = Day as AnyObject
                dic_Histrory["totalDayScratch"] = Constant.GlobalConstants.str_TotalScratchesPerDay  as AnyObject
                
                let str_Day = "Day"+String(Day)
                
                
                
                Database.database().reference().child("Scratch&Win").child(userID).child((userID)+"-Scratch&Win_history").child(str_Day).updateChildValues(dic_UpdateInfo){ (error, ref) -> Void in
                    
                    PKHUD.sharedHUD.hide()
                    
                    if error != nil {
                        Toast(text: error?.localizedDescription).show()
                        return
                    }else {
                        //Toast(text: "Your document is successfully updated.").show()
                        //self.checkMainAppInstalled()
                    }
                }
                
                
                
            }
            
            
        })
    }
    
    
    
    func UpdateScratches_Loss() {
        
        
        var ref = Database.database().reference() // undeclared
        
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        
        let userID = userDetail!["customerguid"] as! String
        let str_Date = UserDefaults.standard.object(forKey: "C_D") as! String
        
       // HUD.show(HUDContentType.rotatingImage(UIImage(named: "icn_spinner")))
        
        ref = Database.database().reference().child("Scratch&Win").child(userID).child(userID+"-Scratch&Win")
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            PKHUD.sharedHUD.hide()
            
            if snapshot.exists() {
                
                print(snapshot.value as Any)
                var dic_Info = snapshot.value as! [String: AnyObject]
                
                let str_Tmp = dic_Info["today_date"] as! String
                
                print(str_Tmp)
                
             //   if str_Tmp == str_Date {
                    
                    let old_total_scratch = dic_Info["remaining_level_scratch"] as! Int
                    
                    let str_RemainScratches = old_total_scratch - 1
                    let old_total_used_scratch = dic_Info["total_used_scratch"] as! Int
                    let old_today_used_scratch = dic_Info["today_use_scratch"] as! Int
                    let old_total_level_scratch = dic_Info["total_level_scratch"] as! Int
                    let old_today_avialble_scracth = dic_Info["today_avialble_scracth"] as! Int
                
                
                
                
                    let new_today_avialble_scracth = old_today_avialble_scracth - 1
                    let str_NewS_PerDay = old_today_used_scratch + 1
                    let New_total_level_scratch = old_total_level_scratch + 1
                    let new_total_used_scratch = old_total_used_scratch + 1
                    
                    
                    
                    let currentLevel = dic_Info["current_level"] as! Int
                  //  let old_TotalScratch = dic_Info["remaining_level_scratch"] as! Int
                
                    let old_totalWinningAmount = dic_Info["totalWinningAmount"] as! Int
                    //  let old_tisVDGmainAppInstall = dic_Info["isVDGmainAppInstall"] as! Bool
                   
                    var new_totalWinningAmount = 00
                    
                    if currentLevel == 1 {
                        
                         let trackStep = old_total_used_scratch + 1
                        
                        if trackStep <= Constant.GlobalConstants.str_ScratchforFirstStep {
                            
                            if trackStep == Constant.GlobalConstants.str_ScratchforFirstStep {
                                
                                if old_totalWinningAmount <= Constant.GlobalConstants.str_tokenforFirstStep {
                                    new_totalWinningAmount = Constant.GlobalConstants.str_tokenforFirstStep
                                }else {
                                    new_totalWinningAmount = (self.TokenWon) + old_totalWinningAmount
                                }
                                
                            }else {
                                new_totalWinningAmount = (self.TokenWon) + old_totalWinningAmount
                            }
                        }else if trackStep <= Constant.GlobalConstants.str_ScratchforSecondStep {
                            
                            if trackStep == Constant.GlobalConstants.str_ScratchforSecondStep {
                                
                                if old_totalWinningAmount <= (Constant.GlobalConstants.str_tokenforSecondStep + Constant.GlobalConstants.str_tokenforFirstStep) {
                                    new_totalWinningAmount = (Constant.GlobalConstants.str_tokenforSecondStep + Constant.GlobalConstants.str_tokenforFirstStep)
                                }else {
                                    new_totalWinningAmount = (self.TokenWon) + old_totalWinningAmount
                                }
                                
                            }else {
                                new_totalWinningAmount = (self.TokenWon) + old_totalWinningAmount
                            }
                            
                        }else if trackStep <= Constant.GlobalConstants.str_ScratchforThirdStep {
                            
                            if trackStep == Constant.GlobalConstants.str_ScratchforThirdStep {
                                
                                if old_totalWinningAmount <=  (Constant.GlobalConstants.str_tokenforSecondStep + Constant.GlobalConstants.str_tokenforFirstStep + Constant.GlobalConstants.str_tokenforThirdStep) {
                                    new_totalWinningAmount = (Constant.GlobalConstants.str_tokenforSecondStep + Constant.GlobalConstants.str_tokenforFirstStep + Constant.GlobalConstants.str_tokenforThirdStep + Constant.GlobalConstants.str_BonusToken_FinishFirstLevel   + Constant.GlobalConstants.str_BonusToken_FinishFirstLevel)
                                    
                                    
                                    
                                }else {
                                    new_totalWinningAmount = (self.TokenWon) + old_totalWinningAmount
                                }
                                
                            }else {
                                new_totalWinningAmount = (self.TokenWon) + old_totalWinningAmount
                            }
                            
                        }
                        
                    }
                    
                    
                    dic_Info["remaining_level_scratch"] = str_RemainScratches as AnyObject
                    dic_Info["today_use_scratch"] = str_NewS_PerDay  as AnyObject
                    //dic_Info["total_level_scratch"] = New_total_level_scratch  as AnyObject
                    dic_Info["total_used_scratch"] = new_total_used_scratch as AnyObject
                    dic_Info["today_avialble_scracth"] = new_today_avialble_scracth as AnyObject
                    
                    Database.database().reference().child("Scratch&Win").child(userID).child((userID)+"-Scratch&Win").updateChildValues(dic_Info){ (error, ref) -> Void in
                        
                        if error != nil {
                            
                            Toast(text: error?.localizedDescription).show()
                            
                            return
                        }else {
                            self.get_Scratches_Info()
                            self.Update_History_Loss()
                        }
                    }
                    
                }
            //}
        })
    }
    
    
    func Update_History_Loss(){
        
        
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
                        // self.checkMainAppInstalled()
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
      //  HUD.show(HUDContentType.rotatingImage(UIImage   (named: "icn_spinner")))
        
        ref = Database.database().reference().child("Scratch&Win").child(userID).child(userID+"-Scratch&Win")
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            PKHUD.sharedHUD.hide()
            
            if snapshot.exists() {
                
                print(snapshot.value as Any)
                let dic_Info = snapshot.value as! NSDictionary
                
                let str_Tmp = dic_Info["today_date"] as! String
                
                print(str_Tmp)
                
                
                
                let str_Scratch = String(dic_Info["remaining_level_scratch"] as! Int) + " scratches remaining"
                
              //  self.btn_RemainTS.setTitle(str_Scratch, for: .normal)
                
                
                
                
                
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
