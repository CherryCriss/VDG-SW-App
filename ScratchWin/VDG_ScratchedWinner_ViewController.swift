//
//  VDG_ScratchedWin_ViewController.swift
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
import AVFoundation


enum Images {
    
    static let box = UIImage(named: "coin-1")!
    static let triangle = UIImage(named: "coin-2")!
    static let circle = UIImage(named: "coin-3")!
    static let swirl = UIImage(named: "coin-4")!
    static let img_fifth = UIImage(named: "coin-5")!
    
}

class VDG_ScratchedWinner_ViewController: UIViewController {

    @IBOutlet var btn_Close : UIButton!
    @IBOutlet var btn_Help : UIButton!
    @IBOutlet var vw_Coins : UIView!
    @IBOutlet var vw_Tshirt : UIView!
    @IBOutlet var btn_Invite : UIButton!
    @IBOutlet var btn_Share : UIButton!
    @IBOutlet var lbl_RemainTS: UIButton!
    @IBOutlet var lbl_WonTokens: UILabel!
    @IBOutlet var btn_TryAgain: UIButton!
    var TokenWon = Int()
    var img_ScreenShot: UIImage!
    
     var window: UIWindow?
    
    
    @IBOutlet var img_shareursuccess : UIImageView!
    @IBOutlet var lbl_shareursuccess : UILabel!
    @IBOutlet var vw_shareursuccess : UIView!
 
    
    var emitter = CAEmitterLayer()
    
    
    
    var images:[UIImage] = [
        Images.box,
        Images.triangle,
        Images.circle,
        Images.swirl
    ]
    
    var velocities:[Int] = [
        100,
        100,
        100
    ]
    
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        vw_Coins.isHidden = true
        vw_Tshirt.isHidden = true
        
     //   TokenWon = self.randomWinToken()
        
        let dice1 = randomNumber()
        
        if dice1 % 2 == 0 {
            vw_Coins.isHidden = false
            vw_Tshirt.isHidden = true
        }else {
            vw_Coins.isHidden = true
            vw_Tshirt.isHidden = false
        }
        
        vw_Coins.isHidden = false
        vw_Tshirt.isHidden = true
        
        
        lbl_RemainTS.addShadow()
        
        //lbl_RemainTS.isHidden = true
        btn_TryAgain.layer.shadowRadius = 10
        btn_TryAgain.layer.shadowOpacity = 0.4
        btn_TryAgain.layer.shadowColor = UIColor.black.cgColor
        btn_TryAgain.layer.shadowOffset = CGSize.zero
 
        //createParticles1()
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.tap_vw_Zooming(_:)))
        vw_shareursuccess.addGestureRecognizer(tap2)
        vw_shareursuccess.isUserInteractionEnabled = true
        
        
        
    }
    @objc func tap_vw_Zooming(_ sender: UITapGestureRecognizer) {
     
     
        
        let attributedString = NSAttributedString(string: "Share Your Success" , attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 22),
                                                                               NSAttributedStringKey.foregroundColor : ConstantsModel.ColorCode.kColor_Theme])
        
        let alert = UIAlertController(title: "", message: "Celebrate your winning with your friends now, so they can start winning as well!!",  preferredStyle: .alert)
        alert.setValue(attributedString, forKey: "attributedTitle")
        alert.view.tintColor = UIColor.black
        
        let btn_share = UIAlertAction(title: "Share",
                                         style: .default) { (action: UIAlertAction!) -> Void in
                                            
                                            self.shareDialogue()
                                            
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default) { (action: UIAlertAction!) -> Void in
        }
        alert.addAction(btn_share)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
   
    func shareDialogue() {
        
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        
        let userFirst = userDetail!["firstname"] as! String
     
        
        let name = userFirst
        let strMsg = "\(name) is scratching to win Points everyday!\n\nHave you tried your luck yet? Now available on android and app store.\n\nDownload from the links below.\n\nPlay Store: https://play.google.com/store/apps/details?id=com.veridocscratch.android\n\nApp Store: \(ConstantsModel.BasePath.url_appstorescratchandwinapp)"
        
        let someText:String = strMsg
     
        let sharedObjects:[AnyObject] = [someText as AnyObject]
        let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.copyToPasteboard,UIActivityType.saveToCameraRoll,UIActivityType.addToReadingList,UIActivityType.airDrop,UIActivityType.openInIBooks]
        
        
        
        
        activityViewController.completionWithItemsHandler = { (activity, success, items, error) in
            print(success ? "SUCCESS!" : "FAILURE")
        }
        // self.present(activityViewController, animated: true, completion: nil)
        
        self.present(activityViewController, animated: true, completion: {
            
            activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
                // react to the completion
                if completed {
                    // user shared an item
                  
                    
                    print("We used activity type ",returnedItems as Any)
                    
                    print("We used activity type\(activityType ?? UIActivityType(rawValue: ""))")
                    
                } else {
                    print("We didn't want to share anything after all.")
                    
                }
                
                if error != nil {
                    
                    print("An Error occured: \(error?.localizedDescription ?? ""), \((error as NSError?)?.localizedFailureReason ?? "")")
                    
                    
                }
            }
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        //createParticles()
        
        let str_Token = String(self.TokenWon)
        
        self.lbl_WonTokens.text = str_Token + " Points"

        
         get_Scratches_Info()
        
        img_ScreenShot = self.takeScreenshot(false)
    
        
        
         vw_shareursuccess.zoomFirst()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        
        emitter.emitterPosition = CGPoint(x: self.view.frame.size.width / 2, y: -10)
        emitter.emitterShape = kCAEmitterLayerLine
        emitter.emitterSize = CGSize(width: self.view.frame.size.width, height: 2.0)
        emitter.emitterCells = generateEmitterCells()
        self.view.layer.addSublayer(emitter)
        
    }
    

    @IBAction func btn_Close(_ sender: UIButton) {
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
        
        
        
    }
    
    @IBAction func btn_TryAgain(_ sender: UIButton) {
        
        //  _ = navigationController?.popToRootViewController(animated: false)
        kConstantObj.SetMainViewController("VDG_ScratchWinNow_ViewController")
        
        
    }
    
    
    func randomNumber(range: ClosedRange<Int> = 1...10) -> Int {
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
                
                let dic_LastDayInfo = sortedResults.last! as [String: AnyObject]
                print(arr_Days)
                print(sortedResults)
                print(dic_LastDayInfo)
                
                let Day = dic_LastDayInfo["day"] as! Int
                
                
                var total_usedDayScratch = dic_LastDayInfo["usedDayScratch"] as! Int
                var str_winAmount = dic_LastDayInfo["winAmount"] as! String
                total_usedDayScratch += 1
                
               
                
                let str_Token = String(self.TokenWon)
                
                self.lbl_WonTokens.text = str_Token
                
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
                        
                    }
                }
                
                
                
            }
            
            
        })
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
                
               
                    
                    //let old_total_scratch = Int(dic_Info["a"]!)!
                    
                   // let str_RemainScratches = String(old_total_scratch - 1)
                   
                    
                    let old_TotalScratch = dic_Info["remaining_level_scratch"] as! Int
                    let old_today_used_scratch = dic_Info["today_use_scratch"] as! Int
                    let old_is_today_win = dic_Info["is_today_win"] as! Bool
                    let old_total_level_scratch = dic_Info["total_level_scratch"] as! Int
                    let old_totalWinningAmount = dic_Info["totalWinningAmount"] as! Int
                    
                    
                    if old_is_today_win == false {
                        
                        let str_NewTS = old_TotalScratch-1
                        
                        let str_NewS_PerDay = old_today_used_scratch + 1
                        let new_total_level_scratch = old_total_level_scratch + 1
                      
                        let new_totalWinningAmount = (self.TokenWon) + old_totalWinningAmount
                        
                        dic_Info["remaining_level_scratch"] = str_NewTS as AnyObject
                        dic_Info["today_use_scratch"] = str_NewS_PerDay as AnyObject
                        dic_Info["is_today_win"] = true as AnyObject
                        dic_Info["total_level_scratch"] = new_total_level_scratch  as AnyObject
                        dic_Info["totalWinningAmount"] = new_totalWinningAmount as AnyObject
                        
                        
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
                
                }
           
        })
    }
    
    func randomWinToken(range: ClosedRange<Int> = 1000...2000) -> Int {
        let min = range.lowerBound
        let max = range.upperBound
        return Int(arc4random_uniform(UInt32(1 + max - min))) + min
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
                
               
                    
                  // self.lbl_RemainTS.text = String(dic_Info["remaining_level_scratch"] as! Int) + " Scratches Remain"
                   
               // self.lbl_RemainTS.setTitle(String(dic_Info["remaining_level_scratch"] as! Int) + " scratches remaining", for: .normal)
                
                self.lbl_RemainTS.setTitle("", for: .normal)
                
                let trackStep = dic_Info["total_used_scratch"]  as! Int
                
                if  trackStep == Constant.GlobalConstants.str_ScratchforThirdStep {
                    self.btn_TryAgain.setTitle("CONTINUE", for: .normal)
                }else{
                    self.btn_TryAgain.setTitle("TRY AGAIN", for: .normal)
                }
                    
    
            }
            
        })
        
    }

    private func generateEmitterCells() -> [CAEmitterCell] {
        var cells:[CAEmitterCell] = [CAEmitterCell]()
        for index in 0..<4 {
            
            let cell = CAEmitterCell()
            
            cell.birthRate = 3.5
            cell.lifetime = 24.0
            cell.lifetimeRange = 0
            cell.velocity = CGFloat(getRandomVelocity())
            cell.velocityRange = 0
            cell.emissionLongitude = CGFloat(Double.pi)
            cell.emissionRange = 0.3
            cell.spin = 0
            cell.spinRange = 10.2
            // cell.color = getNextColor(i: index)
            cell.contents = getNextImage(i: index)
            cell.scaleRange = 0.17
            cell.scale = 0.17
            cells.append(cell)
            
        }
        
        return cells
        
    }
    
    private func getRandomVelocity() -> Int {
        return velocities[getRandomNumber()]
    }
    
    private func getRandomNumber() -> Int {
        return Int(arc4random_uniform(3))
    }
    
    
    
    private func getNextImage(i:Int) -> CGImage {
        return images[i % 4].cgImage!
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
