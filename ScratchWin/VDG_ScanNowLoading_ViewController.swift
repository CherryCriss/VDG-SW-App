//
//  VDG_ScanNowLoading_ViewController.swift
//  VeriDocG
//
//  Created by Bhavdip Patel on 04/10/18.
//  Copyright © 2018 SevenBits. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

import MessageUI
import SwiftKeychainWrapper
import PasswordTextField


import Firebase
import FirebaseAuth
import FirebaseDatabase
import NVActivityIndicatorView
import Branch
import FirebaseMessaging
import PKHUD


class VDG_ScanNowLoading_ViewController: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet var vw_Indicator: UIView!
    
    // MARK: - QRScan Screen
    @IBOutlet var btn_SmartLogin: UIButton!
    @IBOutlet var btn_QR: UIButton!
    @IBOutlet var btn_ScanNow: UIButton!
    @IBOutlet var vw_QR: UIView!
    @IBOutlet var lbl_QR_Title: UILabel!
    
    
    
    
    var str_OldFCMToken: String!
    var str_NewFCMToken: String!
    var str_InviterName: String = ""
 
    // Scratch Hand
    @IBOutlet var btn_ScratchHand: UIButton!
    // Others
    
    var currnetViewIndex: Int!
    var str_GUD_InviterUser: String!
    
    var dic_SignUp: NSDictionary!
    var isFromSignUp: Bool! = false
    var isFromSignIn: Bool!
    
    
    var activityIndicatorView: NVActivityIndicatorView!
    
    override func viewDidAppear(_ animated: Bool) {
        
        (NVActivityIndicatorType.circleStrokeSpin.rawValue ... NVActivityIndicatorType.circleStrokeSpin.rawValue).forEach {
            
            activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: vw_Indicator.frame.width, height: vw_Indicator.frame.height),
                                                                type: NVActivityIndicatorType(rawValue: $0)!)
            
            
            
            vw_Indicator.addSubview(activityIndicatorView)
            
            activityIndicatorView.startAnimating()
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
          self.navigationController?.navigationBar.isHidden = true
        // Do any additional setup after loading the view.
        
        let userDetail1: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        
        print("userInfo: \(userDetail1)")
    

        
        
    
        NotificationCenter.default.removeObserver(self, name:  Notification.Name("FCMToken"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.GettingFCMToken), name: Notification.Name("FCMToken"), object: nil)
        
        if Connectivity.isConnectedToInternet {

            serverTimeReturn { (getResDate) -> Void in

                let dateFormatterPrint = DateFormatter()
                dateFormatterPrint.dateFormat = "dd-MM-yyyy"

                let date = dateFormatterPrint.string(from: getResDate!)
                print(date)

                UserDefaults.standard.set(date, forKey: "C_D")
                UserDefaults.standard.synchronize()
                let isLogin = UserDefaults.standard.object(forKey: "isLogin") as! Bool?

                if isLogin == true {
                    self.checkUserExit()
                }

            }
           
            
            
            isFromSignUp = UserDefaults.standard.bool(forKey: "loginfrom")
            
            if isFromSignUp == true {
                
                // latest
                let sessionParams = Branch.getInstance().getLatestReferringParams()! as NSDictionary
                
                print(sessionParams)
                // first
                let installParams = Branch.getInstance().getFirstReferringParams()! as NSDictionary
                
                if installParams["~stage"] != nil {
                    print(installParams)
                    let val = installParams["~stage"] as! String
                    
                    let dict = convertToDictionary(text: val)
                    
                    let userId = dict!["UserID"]
                    if let actionString = dict!["Name"] as? String {
                        str_InviterName = (dict!["Name"] as! String)
                    }
                    
                    
                    str_GUD_InviterUser = userId as! String
                    
                    if str_GUD_InviterUser.count  > 0 {
                     ///   FireBasePushNotification(str_InviterGUID: str_GUD_InviterUser as String)
                    }
                }else {
                    
                }
            }else {
                
                
                
            }
            
        }else{
            Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
        }
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    

    @objc func GettingFCMToken(notfication: NSNotification) {
        
        let dicInfo = notfication.userInfo
        
        str_NewFCMToken = dicInfo?["token"] as! String
        print(str_NewFCMToken)
        UserDefaults.standard.setValue(dicInfo?["token"], forKey:"FCMToken")
        UserDefaults.standard.synchronize()
        
        self.UpdateUserInfo()
        //self.UpdateUserInfo_Mainapp()
    }
    
    // called every time interval from the timer
    @objc func timerAction() {
        
        
        activityIndicatorView.stopAnimating()
        activityIndicatorView.removeFromSuperview()
        
      //  let vc = self.storyboard?.instantiateViewController(withIdentifier: "VDG_ScratchWinHome_ViewController") as? VDG_ScratchWinHome_ViewController
     //   self.navigationController?.pushViewController(vc!, animated: true)
        
        kConstantObj.SetMainViewController("VDG_ScratchWinHome_ViewController")
        
        
        
    }
    
    

    
    func checkUserExit(){
        
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        
        ref.child("Scratch&Win").observeSingleEvent(of: .value, with: { (snapshot) in
            let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
            
            let userID = userDetail!["customerguid"] as! String
            
            if snapshot.hasChild(userID){
                
               
                
                
                print("User Exit")
                self.UpdateFirebase(isUserExit: true)
                
                let dic_Info = snapshot.value as! NSDictionary
                
                //  if self.isFromSignIn == true {
                self.LogOutFromOtherDevice(dic_Info: dic_Info)
                //  }
                
                
            }else{
                
                print("User Not Exit")
                self.UpdateFirebase(isUserExit: false)
                
            }
        })
        
    }
    
    func serverTimeReturn(completionHandler:@escaping (_ getResDate: Date?) -> Void){
        
        let url = URL(string: "http://www.google.com")
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            if error == nil {
            let httpResponse = response as? HTTPURLResponse
            
            
                        if let contentType = httpResponse!.allHeaderFields["Date"] as? String {
                            
                            let dFormatter = DateFormatter()
                            dFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
                            
                            let serverTime = dFormatter.date(from: contentType)
                            completionHandler(serverTime)
                        }
            }
        }
        
        task.resume()
    
    }
    
    
    
    func UpdateFirebase(isUserExit: Bool){
        
        
        var ref = Database.database().reference() // undeclared
        
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        
        let userID = userDetail!["customerguid"] as! String
        let str_Date = UserDefaults.standard.object(forKey: "C_D") as! String
        
        var ImageDataDictionary: Dictionary = [String: AnyObject]()
        var dic_Histrory: Dictionary = [String: AnyObject]()
        
        
        if isUserExit == true {
            
            ref = Database.database().reference().child("Scratch&Win").child(userID).child(userID+"-Scratch&Win")
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
                
               
                
                if snapshot.exists() {
                    
                    
                 //   self.AddingNewFields()
                    
                    print(snapshot.value as Any)
                    let dic_Info1 = snapshot.value as! NSDictionary
                   
                    let str_Tmp = dic_Info1["today_date"] as! String
                    
                    let whichDay = dic_Info1["whichDay"] as! Int
                    let old_today_avialble_scracth = dic_Info1["today_avialble_scracth"] as! Int
                    let old_remaining_level_scratch = dic_Info1["remaining_level_scratch"] as! Int
                    let old_today_use_scratch = dic_Info1["today_use_scratch"] as! Int
                    print(str_Tmp)
                    
                     self.AddingNewFields(oldInfo: dic_Info1)
                    
                    if str_Tmp != str_Date {
                        
                        var dic_Info: Dictionary = [String: AnyObject]()
                        
                     
                            dic_Info["today_date"] = str_Date as AnyObject
                          //  dic_Info["today_avialble_scracth"] = Constant.GlobalConstants.str_TotalScratchesPerDay as AnyObject
                           dic_Info["today_use_scratch"] = 0 as AnyObject
                            dic_Info["is_today_win"] = false as AnyObject
                            dic_Info["whichDay"] = whichDay + 1 as AnyObject
                        
                        if old_remaining_level_scratch >= Constant.GlobalConstants.str_TotalScratchesPerDay {
                            
                            dic_Info["today_avialble_scracth"] = Constant.GlobalConstants.str_TotalScratchesPerDay as AnyObject
                            
                        }else {
                            
                           // dic_Info["today_use_scratch"] = old_today_use_scratch as AnyObject
                            dic_Info["today_avialble_scracth"] = old_remaining_level_scratch as AnyObject
                            
                        }
                        
                        
                        
                        Database.database().reference().child("Scratch&Win").child(userID).child((userID)+"-Scratch&Win").updateChildValues(dic_Info){ (error, ref) -> Void in
                            
                            if error != nil {
                                
                                Toast(text: error?.localizedDescription).show()
                                
                                return
                            }else {
                                
                                self.updateHistory()
                                
                            }
                            
                        }
                        
                    }
                    
                   Timer.scheduledTimer(timeInterval: 2.10, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: false)
                }else{
                    
                }
                
                if let refreshedToken = InstanceID.instanceID().token() {
                    
                    print("InstanceID token: \(refreshedToken)")
                    
                    UserDefaults.standard.setValue(refreshedToken, forKey:"FCMToken")
                    UserDefaults.standard.synchronize()
                    
                    let dataDict:[String: String] = ["token": refreshedToken]
                    NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
                    
                }
                
                
            })
            
        }else {
            
            
            
            ImageDataDictionary["current_level"] = 1 as AnyObject
            ImageDataDictionary["isTodayBlogShare"] = false as AnyObject
            ImageDataDictionary["is_today_invite"] = false as AnyObject
            ImageDataDictionary["is_today_share"] = false as AnyObject
            ImageDataDictionary["is_today_win"] = false as AnyObject
            ImageDataDictionary["remaining_level_scratch"] = Constant.GlobalConstants.str_RemainingScratch as AnyObject
            ImageDataDictionary["today_avialble_scracth"] = Constant.GlobalConstants.str_TotalScratchesPerDay as AnyObject
            ImageDataDictionary["today_date"] = str_Date as AnyObject
            ImageDataDictionary["today_use_scratch"] = 0 as AnyObject
            ImageDataDictionary["totalWinningAmount"] = 0 as AnyObject
            ImageDataDictionary["total_level_scratch"] = Constant.GlobalConstants.str_TotalScratchesPerLevel as AnyObject
            ImageDataDictionary["whichDay"] = 0 as AnyObject
            ImageDataDictionary["isVDGmainAppInstall"] = false as AnyObject
            ImageDataDictionary["total_used_scratch"] = 0 as AnyObject
            
            
            
            ref.child("Scratch&Win").child(userID).child((userID)+"-Scratch&Win").setValue(ImageDataDictionary)
            
            
            dic_Histrory["day"] = 1 as AnyObject
            dic_Histrory["totalDayScratch"] = Constant.GlobalConstants.str_TotalScratchesPerDay as AnyObject
            dic_Histrory["usedDayScratch"] = 0 as AnyObject
            dic_Histrory["winAmount"] = "" as AnyObject
            
            ref.child("Scratch&Win").child(userID).child((userID)+"-Scratch&Win_history").child("Day1").setValue(dic_Histrory)
            
            
            Timer.scheduledTimer(timeInterval: 1.10, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: false)
            
            
            
            
            if let refreshedToken = InstanceID.instanceID().token() {
                
                print("InstanceID token: \(refreshedToken)")
                
                UserDefaults.standard.setValue(refreshedToken, forKey:"FCMToken")
                UserDefaults.standard.synchronize()
                
                let dataDict:[String: String] = ["token": refreshedToken]
                NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
                
            }
        }
        
        
        
        
        
        
    }
    func isOldUser() {
        
        let ref = Database.database().reference() // undeclared
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        let userID = userDetail!["customerguid"] as! String
        let str_Date = UserDefaults.standard.object(forKey: "C_D") as! String
        
        
        var ImageDataDictionary: Dictionary = [String: AnyObject]()
        var dic_Histrory: Dictionary = [String: AnyObject]()
        
        
        ImageDataDictionary["current_level"] = 1 as AnyObject
        ImageDataDictionary["isTodayBlogShare"] = false as AnyObject
        ImageDataDictionary["is_today_invite"] = false as AnyObject
        ImageDataDictionary["is_today_share"] = false as AnyObject
        ImageDataDictionary["is_today_win"] = false as AnyObject
        ImageDataDictionary["remaining_level_scratch"] = Constant.GlobalConstants.str_RemainingScratch as AnyObject
        ImageDataDictionary["today_avialble_scracth"] = Constant.GlobalConstants.str_TotalScratchesPerDay as AnyObject
        ImageDataDictionary["today_date"] = str_Date as AnyObject
        ImageDataDictionary["today_use_scratch"] = 0 as AnyObject
        ImageDataDictionary["totalWinningAmount"] = 0 as AnyObject
        ImageDataDictionary["total_level_scratch"] = Constant.GlobalConstants.str_TotalScratchesPerLevel as AnyObject
        ImageDataDictionary["whichDay"] = 0 as AnyObject
        ImageDataDictionary["isVDGmainAppInstall"] = false as AnyObject
        ImageDataDictionary["total_used_scratch"] = 0 as AnyObject
        
        
        
        ref.child("Scratch&Win").child(userID).child((userID)+"-Scratch&Win").setValue(ImageDataDictionary)
        
        
        dic_Histrory["day"] = 1 as AnyObject
        dic_Histrory["totalDayScratch"] = Constant.GlobalConstants.str_TotalScratchesPerDay as AnyObject
        dic_Histrory["usedDayScratch"] = 0 as AnyObject
        dic_Histrory["winAmount"] = "" as AnyObject
        
        ref.child("Scratch&Win").child(userID).child((userID)+"-Scratch&Win_history").child("Day1").setValue(dic_Histrory)
        
    }
    func AddingNewFields(oldInfo: NSDictionary) {
        
        
        let remaining_level_scratch = oldInfo["remaining_level_scratch"] as! Int
        
        var ImageDataDictionary: Dictionary = [String: AnyObject]()
        
        if oldInfo["current_level"] == nil {
           ImageDataDictionary["current_level"] = 1 as AnyObject
        }
        
       
        
        if oldInfo["isVDGmainAppInstall"] == nil {
            ImageDataDictionary["isVDGmainAppInstall"] = false as AnyObject
        }
        
        //if oldInfo["total_used_scratch"] == nil {
        
        let total_level_scratch = oldInfo["total_level_scratch"] as! Int
       // let remaining_level_scratch = oldInfo["remaining_level_scratch"] as Int
      
        
        ImageDataDictionary["total_used_scratch"] = total_level_scratch - remaining_level_scratch as AnyObject
        //}

      
       
       

        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        
        let userID = userDetail!["customerguid"] as! String
        
        
        let ref = Database.database().reference()
        
        ref.child("Scratch&Win").child(userID).child((userID)+"-Scratch&Win").updateChildValues(ImageDataDictionary)
        
    }
    
    func UpdateUserInfo(){
        
        
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        
        let userID = userDetail!["customerguid"] as! String
        
        
        let ref1 = Database.database().reference().child("Scratch&Win").child(userID).child(userID+"-user_info")
        
        ref1.observeSingleEvent(of: .value, with: { (snapshot) in
            
            
            
            if snapshot.exists() {
                
                var ref = Database.database().reference() // undeclared
                
                let str_FCMToken = UserDefaults.standard.object(forKey: "FCMToken") as! String
                
                var ImageDataDictionary: Dictionary = [String: String]()
                
                ImageDataDictionary["emailID"] = (userDetail!["email"] as! String)
                ImageDataDictionary["fcmToken"] = str_FCMToken
                
                ref.child("Scratch&Win").child(userID).child((userID)+"-user_info").updateChildValues(ImageDataDictionary)
              
            }else {
                
                var ref = Database.database().reference() // undeclared
                
                let str_FCMToken = UserDefaults.standard.object(forKey: "FCMToken") as! String
                
                var ImageDataDictionary: Dictionary = [String: String]()
                
                ImageDataDictionary["emailID"] = (userDetail!["email"] as! String)
                ImageDataDictionary["fcmToken"] = str_FCMToken
                
                ref.child("Scratch&Win").child(userID).child((userID)+"-user_info").setValue(ImageDataDictionary)
                ref.child("Scratch&Win").child(userID).child((userID)+"-user_info_mainapp").setValue(ImageDataDictionary)
                
                let ref2 = Database.database().reference().child("Scratch&Win").child(userID).child(userID+"-user_info")
                
                ref2.observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        
                        print(snapshot.value as Any)
                        
                        if snapshot.hasChild("profileurl"){
                            
                            print("true rooms exist")
                            
                            
                            
                        }else{
                            
                            var ImageDataDictionary: Dictionary = [String: String]()
                            
                            
                            ImageDataDictionary["profileurl"] = ""
                            
                            UserDefaults.standard.set("", forKey: "profile")
                            UserDefaults.standard.synchronize()
                            
                            var refUpdate = Database.database().reference()
                            
                            refUpdate.child("Scratch&Win").child(userID).child((userID)+"-user_info").updateChildValues(ImageDataDictionary)
                           
                            
                            
                            
                        }
                        
                        
                        
                        
                        
                        
                    }
                    
                    
                })
                
                
            }
            
        })
        
        
        
        
    }
    
    
    
    func updateHistory() {
        
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
                
                
                
                
                
                var PreviousDay = dic_LastDayInfo["day"]
                var tmp = Int(PreviousDay as! Int) + 1
                // PreviousDay = PreviousDay + 1
                dic_Histrory["day"] = tmp as! AnyObject
                dic_Histrory["totalDayScratch"] = Constant.GlobalConstants.str_TotalScratchesPerDay as! AnyObject
                dic_Histrory["usedDayScratch"] = 0 as! AnyObject
                dic_Histrory["winAmount"] = "" as! AnyObject
                
                
                let str_Days = "Day"+String(tmp)
                let refT = Database.database().reference()
                refT.child("Scratch&Win").child(userID).child((userID)+"-Scratch&Win_history").child(str_Days).setValue(dic_Histrory)
                
                
                
                
                
            }
            
            
        })
        
    }
    
    func FireBasePushNotification(str_InviterGUID: String){
        
        if str_InviterGUID.count  > 0 {
            
            var ref = Database.database().reference() // undeclared
            
            let userID = str_InviterGUID
            
            ref = Database.database().reference().child("Scratch&Win").child(userID).child(userID+"-user_info")
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    
                    print(snapshot.value as Any)
                    
                    let dic_Info = snapshot.value as! NSDictionary
                    let str_Email = dic_Info["emailID"] as! String
                    let str_FCMToken = dic_Info["fcmToken"] as! String
                    
                    print(str_Email)
                    print(str_FCMToken)
                    
                    let strMsg = str_Email + " has install VeriDoc Global, so you get \(Constant.GlobalConstants.str_TotalScratchesPerInvited) scratches."
                    
                    self.sendRequestPush(str_FCMToken: str_FCMToken, NotificationMsg: strMsg, guid: str_InviterGUID)
                    
                    
                }
                
            })
            
        }else {
            Toast(text: "GUID does not found from Inviter User.").show()
        }
        
        
    }
    
    func sendRequestPush(str_FCMToken: String, NotificationMsg: String, guid: String)  {
        // create the request
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("key=" + Constant.GlobalConstants.str_FCMserverKey, forHTTPHeaderField: "authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //        let parameters = ["to": str_FCMToken,
        //                          "priority": "high",
        //                          "notification": ["body":"VDG", "title":NotificationMsg, "sound":"default"]] as [String : Any]
        
        let parameters = ["to": str_FCMToken,
                          "priority": "high",
                          "notification": ["body":"VDG", "title":NotificationMsg, "sound":"default"],
                          "content_available": true,  "data":["uid":guid, "title": "Invitation scratches", "message" : "Please logout.."] as NSDictionary] as NSDictionary
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let dataTask = session.dataTask(with: request as URLRequest) { data,response,error in
            let httpResponse = response as? HTTPURLResponse
            if (error != nil) {
                print(error!)
            } else {
                print(httpResponse!)
                
               // self.UpdateScratches_InvitationAccepted(str_guid: guid)
                
                
            }
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            do {
                guard let responseDictionary = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        print("error trying to convert data to JSON")
                        return
                }
                print("The responseDictionary is: " + responseDictionary.description)
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
            DispatchQueue.main.async {
                //Update your UI here
            }
        }
        dataTask.resume()
    }
    
    
    func LogOutFromOtherDevice(dic_Info: NSDictionary) {
        
        
        var ref = Database.database().reference() // undeclared
        
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        
        let userID = userDetail!["customerguid"] as! String
        
        
        //HUD.show(.progress)
        // HUD.show(HUDContentType.rotatingImage(UIImage(named: "icn_spinner")))
        
        // Add Activity Indicatore
//        let vw_Load_BK = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
//        vw_Load_BK.backgroundColor = UIColor.white
//        vw_Load_BK.alpha = 0.6
//        self.view.addSubview(vw_Load_BK)
//        let frame = CGRect(x: (self.view.frame.width/2)-30, y: (self.view.frame.height/2)-30, width: 60, height: 60)
//        let activityIndicatorView = NVActivityIndicatorView(frame: frame,
//                                                            type: NVActivityIndicatorType.ballScale)
//
//        activityIndicatorView.color = UIColor.darkGray
//        self.view.addSubview(activityIndicatorView)
//        activityIndicatorView.startAnimating()
//
        
        ref = Database.database().reference().child("Scratch&Win").child(userID).child(userID+"-user_info")
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            PKHUD.sharedHUD.hide()
            // remove Indicator
//            activityIndicatorView.stopAnimating()
//            activityIndicatorView.removeFromSuperview()
//            vw_Load_BK.removeFromSuperview()
            
            if snapshot.exists() {
                
                print(snapshot.value as Any)
                
                let dic_Info = snapshot.value as! NSDictionary
                
                self.str_OldFCMToken = dic_Info["fcmToken"] as! String
                
                print(self.str_OldFCMToken)
                print(self.str_NewFCMToken)
                print(self.isFromSignIn)
                
                if self.str_NewFCMToken != nil {
                    
                    print("NewFCMToken is not Null", self.str_NewFCMToken)
                    
                    if self.str_OldFCMToken != self.str_NewFCMToken {
                        self.isFromSignIn = UserDefaults.standard.bool(forKey: "loginfrom")
                        
                        //if self.isFromSignIn == true {
                            self.sendRequestlogOutFromAnotherDevice(str_FCMToken: self.str_OldFCMToken)
                        //}
                    }
                }else {
                    print("NewFCMToken is Null", self.str_NewFCMToken)
                }
                
                
                
            }
            
        })
        
    }
    func sendRequestlogOutFromAnotherDevice(str_FCMToken: String)  {
        // create the request
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("key=" + Constant.GlobalConstants.str_FCMserverKey, forHTTPHeaderField: "authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters = ["to": str_FCMToken,
                          "priority": "high",
                          "content_available": true,  "data":["uid":str_FCMToken, "title": "NewDeviceLoginForceLogout", "message" : "Please logout.."] as NSDictionary] as NSDictionary
        
        print(parameters)
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let dataTask = session.dataTask(with: request as URLRequest) { data,response,error in
            let httpResponse = response as? HTTPURLResponse
            if (error != nil) {
                print(error!)
            } else {
                print(httpResponse!)
            }
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            do {
                guard let responseDictionary = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        print("error trying to convert data to JSON")
                        return
                }
                print("The responseDictionary is: " + responseDictionary.description)
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
            DispatchQueue.main.async {
                //Update your UI here
            }
        }
        dataTask.resume()
    }
    
    func UpdateScratches_InvitationAccepted(str_guid: String) {
        
        
        var ref = Database.database().reference() // undeclared
        
        
        
        let userID = str_guid
        
        
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
                
                
                
                let str_NewRemaining = Constant.GlobalConstants.str_TotalScratchesPerInvited + old_TotalScratch
                
                let str_Newold_total_level_scratch = Constant.GlobalConstants.str_TotalScratchesPerInvited +  old_total_level_scratch
                
                dic_Info["remaining_level_scratch"] = str_NewRemaining as AnyObject
                dic_Info["total_level_scratch"] = str_Newold_total_level_scratch as AnyObject
               
                
                Database.database().reference().child("Scratch&Win").child(userID).child((userID)+"-Scratch&Win").updateChildValues(dic_Info){ (error, ref) -> Void in
                    
                    if error != nil {
                        
                        Toast(text: error?.localizedDescription).show()
                        
                        return
                    }else {
                        
                        // let str_ReferredName = "XYZ"
                        
                        let str_Msg =  "Thanks for downloading the VeriDoc Global QR code reading app. \(self.str_InviterName) has referred you will shortly receive their reward!"
                        
                        
                        let alert = UIAlertController(title: "Alert", message: str_Msg, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                            switch action.style{
                            case .default:
                                print("default")
                                
                            case .cancel:
                                print("cancel")
                                
                            case .destructive:
                                print("destructive")
                                
                                
                            }}))
                        self.present(alert, animated: true, completion: nil)
                        
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
