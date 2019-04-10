//
//  VDG_SmartLogin_ViewController.swift
//  VeriDocG
//
//  Created by Bhavdip Patel on 06/12/18.
//  Copyright © 2018 SevenBits. All rights reserved.
//

import UIKit
import FlagPhoneNumber
import MessageUI
import SwiftKeychainWrapper
import PasswordTextField

import Firebase
import FirebaseAuth
import FirebaseDatabase
 
import Branch
import FirebaseMessaging
import PKHUD
import AVFoundation
import NVActivityIndicatorView

class VDG_SmartLogin_ViewController: UIViewController {
   
    
    
    // MARK: - QRScan Screen
    @IBOutlet var btn_SmartLogin: UIButton!
    @IBOutlet var btn_QR: UIButton!
    @IBOutlet var btn_ScanNow: UIButton!
    @IBOutlet var vw_QR: UIView!
    @IBOutlet var lbl_QR_Title: UILabel!
  
    var str_OldFCMToken: String!
    var str_NewFCMToken: String!
    var str_InviterName: String = ""
    
    
    // Log Out
    
    // Scratch Hand
    @IBOutlet var btn_ScratchHand: UIButton!
    @IBOutlet var vw_Main_BK: UIView!
    // Others
    
    var currnetViewIndex: Int!
    var str_GUD_InviterUser: String!
    
    var dic_SignUp: NSDictionary!
    var isFromSignUp: Bool! = false
    var isFromSignIn: Bool!
    var vw_Load_BK: UIView!
    var activityIndicatorView: NVActivityIndicatorView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        // Do any additional setup after loading the view.
//        self.view.isUserInteractionEnabled = true
//        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
//        swipeDown.direction = UISwipeGestureRecognizerDirection.right
//        self.view.addGestureRecognizer(swipeDown)
        str_NewFCMToken = UserDefaults.standard.value(forKey: "FCMToken") as! String
        
        
        
        let userdefaults = UserDefaults.standard
        if userdefaults.string(forKey: "SecondPageController") != nil{
            
            let isSecondPage = UserDefaults.standard.bool(forKey: "SecondPageController")
            
            if isSecondPage == true {
                btn_ScanNow(btn_ScanNow)
            }
        }else {
        
        }
        
       
      
        
    }

    override func viewDidAppear(_ animated: Bool) {
        
         FirstTimeVerifyNumber()
        
    }
    
    func FirstTimeVerifyNumber() {
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        
        print(userDetail as Any)
        
        var userDetailTmp = userDetail as! Dictionary<String,Any>
        
        userDetailTmp.mapValues { $0 is NSNull ? nil : $0 }
        
        print(userDetailTmp)
        
        if userDetailTmp["contact"] != nil {
            
            
            
            if var actionString = userDetailTmp["contact"] as? String  {
                
                actionString = ((userDetailTmp["contact"] as? String)?.trimmingCharacters(in: .whitespaces))!
                
                let isMobileVerified = UserDefaults.standard.value(forKey:"isMobileVerified") as! Bool
                
                if actionString.count > 0 {
                    
                    if isMobileVerified == false {
                        
                        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Phone_ViewController") as! VDG_Phone_ViewController
                        
                        self.present(secondViewController, animated: false)
                    }
                    
                } else {
                    let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Phone_ViewController") as! VDG_Phone_ViewController
                    
                    self.present(secondViewController, animated: false)
                    
                }
                
                
            }else {
                let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Phone_ViewController") as! VDG_Phone_ViewController
                
                self.present(secondViewController, animated: false)
                
            }
        }else {
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Phone_ViewController") as! VDG_Phone_ViewController
            self.present(secondViewController, animated: false)
        }

    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
                let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut, animations: {
                    self.vw_Main_BK.transform = CGAffineTransform(translationX: self.vw_Main_BK.frame.width, y: 0)
                    self.vw_Main_BK.alpha = 0.8
                })
                animator.startAnimation()
                
                animator.addCompletion { _ in
                    kConstantObj.SetIntialMainViewController("VDG_ScanNowLoading_ViewController")
                }
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
                
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
                
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
                
            default:
                break
            }
        }
    }
    // MARK: - Button IBAction Click Event
    
    @IBAction func btn_LeftMenu(_ sender: UIButton) {
        
        sideMenuVC.toggleMenu()
        
    }
   
    
    @IBAction func btn_ScanNow(_ sender: UIButton) {
        
//        let scanner = QRCodeScannerController(cameraImage: UIImage(named: "camera"), cancelImage: UIImage(named: "icn_back_camera"), flashOnImage: UIImage(named: "flash-on"), flashOffImage: UIImage(named: "flash-off"))
//        scanner.delegate = self
//        self.present(scanner, animated: true, completion: nil)
        
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            print("Denied, request permission from settings")
            presentCameraSettings()
        case .restricted:
            print("Restricted, device owner must approve")
        case .authorized:
            print("Authorized, proceed")
            OpenCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success {
                    self.OpenCamera()
                } else {
                    print("Permission denied")
                }
            }
        }
      
    }

    func OpenCamera() {
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        
        if let str_App_Salt = UserDefaults.standard.string(forKey: "API_Salt") {
            
            if (str_App_Salt.count) > 0 {
                
                let isLogin = UserDefaults.standard.bool(forKey: "isSmartLogin")
                
                if isLogin == true {
                    
                    let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_SmartLogout_ViewController") as! VDG_SmartLogout_ViewController
                    
                    
                    self.present(newViewController, animated: false, completion: nil)
                    
                }else {
                    
                    let scanner = QR_Scanning_Camera(cameraImage: UIImage(named: "camera"), cancelImage: UIImage(named: "icn_camera_back"), flashOnImage: UIImage(named: "flash-on"), flashOffImage: UIImage(named: "flash-off"))
                    scanner.delegate = self
                    scanner.restorationIdentifier = "smartlogin"
                    self.present(scanner, animated: true, completion: nil)
                    
                }
            }else{
                
                let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Suggestion_ViewController") as! VDG_Suggestion_ViewController
                self.navigationController?.present(newViewController, animated: false, completion: nil)
            }
            
        }else {
            
            let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Suggestion_ViewController") as! VDG_Suggestion_ViewController
            
            self.navigationController?.present(newViewController, animated: false, completion: nil)
            
        }
    }
    func presentCameraSettings() {
        
        let alertController = UIAlertController(title: "Permissions Required",
                                                message: "Please grant camera permission from your phone's settings.",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                    // Handle
                })
            }
        })
        
        present(alertController, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}



extension VDG_SmartLogin_ViewController: QR_Scanning_CameraDelegate {
    
    
    func qrCodeScanningDidCompleteWithResult(result: String) {
        
    }
    
    func qrCodeScanningFailedWithError(error: String) {
        
    }
    
    
    
    
    func qrScanner(_ controller: UIViewController, scanDidComplete result: String) {
        
        
        //        print("result:\(result)")
        //
        //        let webViewController = ABWebViewController()
        //
        //        print(result)
        //        // Configure WebViewController
        //        webViewController.title = " "
        //
        //        webViewController.URLToLoad = result
        //
        //        webViewController.str_Text = result
        //
        //        // Customize UI of progressbar
        //        webViewController.progressTintColor = Constant.GlobalConstants.kColor_Theme
        //        webViewController.trackTintColor = UIColor.white
        //        webViewController.webView.navigationDelegate = webViewController
        //
        //        navigationController?.pushViewController(webViewController, animated: true)
        
        
        print(controller.restorationIdentifier as Any)
        if controller.restorationIdentifier == "smartlogin" {
            
            print("SmartLogin")
            print(result)
            
            
            
            Smart_Login(result)
            
        }else {
            
            let isURL = canOpenURL(string: result)
            
            if isURL == true {
                
                print("No SmartLogin")
                
                let substring = "https://veridocglobal.com"
                
                if result.contains(substring) {
                    
                    print("I found: \(substring)")
                    
                    let webViewController = ABWebViewController()
                    
                    webViewController.title = " "
                    
                    webViewController.URLToLoad = result
                    
                    webViewController.str_Text = result
                    
                    // Customize UI of progressbar
                    webViewController.progressTintColor = Constant.GlobalConstants.kColor_Theme
                    webViewController.trackTintColor = UIColor.white
                    
                    webViewController.webView.navigationDelegate = webViewController
                    navigationController?.pushViewController(webViewController, animated: true)
                    
                }else {
                    guard let url = URL(string: result) else { return }
                    UIApplication.shared.open(url)
                }
            }else {
                
                let webViewController = ABWebViewController()
                
                print(result)
                // Configure WebViewController
                webViewController.title = " "
                
                webViewController.URLToLoad = result
                
                webViewController.str_Text = result
                
                // Customize UI of progressbar
                webViewController.progressTintColor = Constant.GlobalConstants.kColor_Theme
                webViewController.trackTintColor = UIColor.white
                
                webViewController.webView.navigationDelegate = webViewController
                navigationController?.pushViewController(webViewController, animated: true)
                
            }
        }
        
    }
    
    
    func canOpenURL(string: String?) -> Bool {
        
        var str_Main = string
        
        
        let str_tmp = str_Main?.last
        
        if str_tmp == "/" {
            str_Main = String((str_Main?.dropLast())!)  // "d"
        }
        
        
        
        
        guard let urlString = str_Main else {return false}
        guard let url = NSURL(string: urlString) else {return false}
        if !UIApplication.shared.canOpenURL(url as URL) {return false}
        
        
        
        //
        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: str_Main)
        
    }
    
    func qrScannerDidFail(_ controller: UIViewController, error: String) {
        print("error:\(error)")
    }
    
    func qrScannerDidCancel(_ controller: UIViewController) {
        print("SwiftQRScanner did cancel")
    }
    
    
    // MARK:- Push Notification
    
    func Smart_Login(_ strQr: String) {
        
        print(strQr)
        
        //   let newArr = strQr.components(separatedBy: ["(", ")"]).filter { $0 != "" }
        
        
        var str_WebFCMToken =  ""
        var str_WebName = ""
        
        let newArr = strQr.components(separatedBy: ["\n"])
        
        if newArr.count >= 1 {
            str_WebFCMToken = newArr[0]
        }
        
        if newArr.count >= 2 {
            str_WebName = newArr[1]
        }
        
        if str_WebFCMToken.count > 0 {
            if str_WebName.count > 0 {
                Login_PushNoti(str_WebFCMToken, str_WebName: str_WebName)
            }else {
                Toast(text: "Invalid QR code").show()
            }
        }else {
            Toast(text: "Invalid QR code").show()
        }
    }
    
    func Login_PushNoti(_ str_WebFCMToken: String, str_WebName: String) {
        
        
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        
        // print(userDetail)
        let str_App_Salt = UserDefaults.standard.string(forKey: "API_Salt")
    
        var str_Hash1 = (userDetail!["customerguid"] as! String) + "login" + (str_App_Salt!)
        
        str_Hash1 = str_Hash1.lowercased()
        
        let strReturn = str_WebFCMToken + "\n" + str_WebName
        
        print(str_Hash1)
        let data = str_Hash1.data(using: String.Encoding.utf8)!
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        
        let str_Hash2 = hexBytes.joined()
    
        print(str_NewFCMToken)
     
        let parameters: [String: AnyObject] = ["to" : str_WebFCMToken as AnyObject ,
                                               "priority": "high" as AnyObject,
                                               "content_available": true as AnyObject, "data": ["hash": str_Hash2 as AnyObject, "uid": userDetail!["customerguid"] as AnyObject,"token": str_NewFCMToken as AnyObject,"title": userDetail!["customerguid"] as AnyObject,"action": "login" as AnyObject,"returntoken": strReturn as AnyObject,"text": (userDetail!["email"] as! String)as AnyObject] as AnyObject]
        
        print(parameters)
        
        UserDefaults.standard.set(parameters, forKey: ConstantsModel.KeyDefaultUser.smartlogindetail)
        UserDefaults.standard.synchronize()
        
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name(Constant.GlobalConstants.noti_EULAPending), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.messagereceivedEULAPending(notification:)), name: NSNotification.Name(rawValue: Constant.GlobalConstants.noti_EULAPending), object: nil)
        
        
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name(Constant.GlobalConstants.noti_Id_Login), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.messagereceived(notification:)), name: NSNotification.Name(rawValue: Constant.GlobalConstants.noti_Id_Login), object: nil)
        
        
        
        
        //HUD.show(.progress)
        
       // HUD.show(HUDContentType.labeledRotatingImage(image: UIImage(named: "icn_spinner_icon"), title: "Please check your web browser and accept the T&C's to continue...", subtitle: nil))

        // Add Activity Indicatore
         vw_Load_BK = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        vw_Load_BK.backgroundColor = UIColor.white
        vw_Load_BK.alpha = 0.6
        self.view.addSubview(vw_Load_BK)
        let frame = CGRect(x: (self.view.frame.width/2)-30, y: (self.view.frame.height/2)-30, width: 60, height: 60)
        activityIndicatorView = NVActivityIndicatorView(frame: frame,
                                                            type: NVActivityIndicatorType.ballScale)
        
        activityIndicatorView.color = UIColor.darkGray
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
   
        
        
        API_FCMPUSH.pushNotification(parameters as NSDictionary) { (strRepose: String) in
            print(strRepose)
            // HUD.show(HUDContentType.rotatingImage(UIImage(named: "icn_spinner")))
            
           
            
        }
        
    }
    
    
    @objc func messagereceivedEULAPending(notification: Notification) {
        
        if activityIndicatorView !== nil {
            activityIndicatorView.stopAnimating()
            activityIndicatorView.removeFromSuperview()
            vw_Load_BK.removeFromSuperview()
        }
        
       
        
        
       HUD.show(HUDContentType.labeledRotatingImage(image: UIImage(named: "icn_spinner_icon"), title: "Please check your web browser and accept the T&C's to continue...", subtitle: nil))
        
        
    }
    
    @objc func messagereceived(notification: Notification) {
        
        if activityIndicatorView !== nil {
            activityIndicatorView.stopAnimating()
            activityIndicatorView.removeFromSuperview()
            vw_Load_BK.removeFromSuperview()
        }
        
        PKHUD.sharedHUD.hide()
       
        print(notification.userInfo as Any)
        
        UserDefaults.standard.set(Bool(true), forKey:"isSmartLogin")
        UserDefaults.standard.synchronize()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "VDG_SmartLogout_ViewController") as! VDG_SmartLogout_ViewController
        
        self.present(newViewController, animated: false, completion: nil)
        
        
    }
    
    
    
}






