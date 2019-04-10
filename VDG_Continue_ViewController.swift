//
//  VDG_Continue_ViewController.swift
//  VeriDocG
//
//  Created by Bhavdip Patel on 05/11/18.
//  Copyright © 2018 SevenBits. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import FlagPhoneNumber
import NVActivityIndicatorView

class VDG_Continue_ViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet var vw_Continue: UIView!
    @IBOutlet var vw_UpdateEmail: UIView!
    @IBOutlet var btn_LetsGo: UIButton!
    @IBOutlet var lbl_TitleEmail: UILabel!
    
    @IBOutlet var btn_Resend: UIButton!
    @IBOutlet var btn_UpdateMail: UIButton!
    @IBOutlet var btn_ShowUpdateMail: UIButton!
    @IBOutlet var btn_Cancel: UIButton!
    var isFromSignUp: Bool! = false
    
    @IBOutlet var txt_Update_Email: UITextField!
    @IBOutlet var lbl_Title: UILabel!
    
    var str_Email: String!
    var dic_SignUp: NSDictionary!
     var keyboardH = 0 as Int
    
    

    override func viewWillAppear(_ animated: Bool) {
       self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btn_LetsGo.layer.cornerRadius = 8
       
        btn_UpdateMail.layer.cornerRadius = 8
        btn_ShowUpdateMail.layer.cornerRadius = 8
        btn_Cancel.layer.cornerRadius = 8
        txt_Update_Email.delegate = self
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
  
        self.view.frame.origin.y = 0
        
        vw_UpdateEmail.isHidden = true
        vw_Continue.isHidden = false
      
       
        btn_Resend.isHidden = false
        
        
        self.title = "Verify Email"
        
        txt_Update_Email.placeholder = "E-mail Address"
        
        
         let userInfo: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        lbl_TitleEmail.text = (userInfo!["email"] as! String)
        
        btn_LetsGo.layer.cornerRadius = 8
        btn_LetsGo.clipsToBounds = true
        
        btn_UpdateMail.layer.cornerRadius = 8
        btn_UpdateMail.clipsToBounds = true
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHideShow), name: .UIKeyboardWillHide, object: nil)
        
        txt_Update_Email.delegate = self
        
        
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            print(keyboardHeight)
            //self.view.frame.origin.y = 0
            keyboardH = Int(keyboardHeight)
        }
    }
    
    @objc func keyboardHideShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            print(keyboardHeight)
            keyboardH = 0
        }
    }
    
    // set textview delegate methods and it use for manage placholder on textview
    func textFieldDidBeginEditing(_ textView: UITextField) {
     
        
        self.view.frame.origin.y -= CGFloat(keyboardH+100)
    }
    func textFieldDidEndEditing(_ textView: UITextField) {
      
        self.view.endEditing(true)
        
        self.view.frame.origin.y = 0
    }
    @IBAction func btn_LetsGo(_ sender: UIButton) {
        
         if Connectivity.isConnectedToInternet {
        
        let userInfo: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        
        
        let dictParams: [String: AnyObject] = ["customerguid" : userInfo!["customerguid"] as AnyObject]
        
        lbl_TitleEmail.text = userInfo!["email"] as! String
        
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
        
        Webservices_Alamofier.postWithURLVerify(serverlink: ConstantsModel.WebServiceUrl.API_IsEmailValidate, methodname: "", param:dictParams as NSDictionary, key: "key") { (bool, dictionary) in
           
            // remove Indicator
            activityIndicatorView.stopAnimating()
            activityIndicatorView.removeFromSuperview()
            vw_Load_BK.removeFromSuperview()
            
            if bool == true {
            
                let returnCode = dictionary["returncode"] as! Int
                
                if returnCode == 15 {
                    
                    Toast(text: "Please Verify your email id first.").show()
                    
                } else if returnCode == 14 {
                    
                    if dictionary["API_Salt"] != nil {
                        UserDefaults.standard.set(String(dictionary["API_Salt"] as! String), forKey:"API_Salt")
                    }else {
                        UserDefaults.standard.set(String(""), forKey:"API_Salt")
                    }
                    UserDefaults.standard.set("1", forKey: "tooltipmyrewards")
                    UserDefaults.standard.synchronize()
                    UserDefaults.standard.set("1", forKey: "tooltipscratch")
                    UserDefaults.standard.synchronize()
                    
                    
                     UserDefaults.standard.set(Bool(true), forKey:"isLogin")
                     UserDefaults.standard.set(Bool(false), forKey:"isMobileVerified")
                     UserDefaults.standard.synchronize()
                    
                    
                    Toast(text: (dictionary["returnmessage"] as! String)).show()
                   
                    UserDefaults.standard.set(Bool(self.isFromSignUp), forKey:"loginfrom")
                    UserDefaults.standard.synchronize()
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "VDG_ScanNowLoading_ViewController") as? VDG_ScanNowLoading_ViewController
                    //vc?.dic_SignUp = dictionary
                  //  vc?.isFromSignUp = self.isFromSignUp
                    self.navigationController?.pushViewController(vc!, animated: true)
                    
                }else {
                    Toast(text: (dictionary["returnmessage"] as! String)).show()
                }
                
                
            }else {
                Toast(text: "Something went to wrong").show()
            }
            
        }
    }else{
    Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
    }
        
    }
    
    @IBAction func btn_Resend(_ sender: UIButton) {
        
         if Connectivity.isConnectedToInternet {
        let userInfo: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        
        
        let dictParams: [String: AnyObject] = ["email" : userInfo!["email"] as AnyObject]
        
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
        
        
        Webservices_Alamofier.postWithURLVerify(serverlink: ConstantsModel.WebServiceUrl.API_ResendEmail, methodname: "", param:dictParams as NSDictionary, key: "key") { (bool, dictionary) in
            
            // remove Indicator
            activityIndicatorView.stopAnimating()
            activityIndicatorView.removeFromSuperview()
            vw_Load_BK.removeFromSuperview()
            
            if bool == true {
                
                let returnCode = dictionary["returncode"] as! Int
                 if returnCode == 1 {
                
                    self.vw_UpdateEmail.isHidden = true
                    self.vw_Continue.isHidden = false
                    self.btn_Resend.isHidden = true
                    
                }else if returnCode == 15 {
                    Toast(text: "Please Verify your email id first.").show()
                } else if returnCode == 16 {
                    Toast(text: (dictionary["returnmessage"] as! String)).show()
                }else {
                    Toast(text: (dictionary["returnmessage"] as! String)).show()
                }
                
                
            }else {
                Toast(text: "Something went to wrong").show()
            }
            
        }
        }else{
            Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
        }
        
    }
    
     @IBAction func btn_ShowUpdateView(_ sender: UIButton) {
        
        vw_UpdateEmail.isHidden = false
        vw_Continue.isHidden = true
        

     }
    
     @IBAction func btn_Cancel(_ sender: UIButton) {
        
        vw_UpdateEmail.isHidden = true
        vw_Continue.isHidden = false
        
     }
    
     @IBAction func btn_UpdateEmail(_ sender: UIButton) {
        
        if Connectivity.isConnectedToInternet {
        
        let providedEmailAddress = txt_Update_Email.text
        
        let isEmailAddressValid = isValidEmailAddress(emailAddressString: providedEmailAddress!)
        
        
        if (txt_Update_Email.text?.removingWhitespaces(txt_Update_Email.text).isEmpty)! {
            Toast(text: "Please enter email").show()
        }else if !(isEmailAddressValid){
            Toast(text: "Please enter valid email").show()
        }else {
        
            let userInfo: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
            
            
            let dictParams: [String: AnyObject] = ["customerguid" : userInfo!["customerguid"] as AnyObject,"email" : txt_Update_Email.text as AnyObject]
            
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
            
            Webservices_Alamofier.postWithURLVerify(serverlink: ConstantsModel.WebServiceUrl.API_UpdateEmail, methodname: "", param:dictParams as NSDictionary, key: "key") { (bool, dictionary) in
                
                // remove Indicator
                activityIndicatorView.stopAnimating()
                activityIndicatorView.removeFromSuperview()
                vw_Load_BK.removeFromSuperview()
                
                if bool == true {
                    
                    let saveSuccessful: Bool = KeychainWrapper.standard.set(dictionary, forKey: ConstantsModel.KeyDefaultUser.userData)
                    print("Save was successful: \(saveSuccessful)")
                    
                    
                    let returnCode = dictionary["returncode"] as! Int
                    
                    if returnCode == 1 {
                        
                        self.lbl_TitleEmail.text = self.txt_Update_Email.text
                        
                        Toast(text: (dictionary["returnmessage"] as! String)).show()
                        
                       // self.vw_UpdateEmail.isHidden = true
                        self.txt_Update_Email.text = nil
                        
                        self.vw_UpdateEmail.isHidden = true
                        self.vw_Continue.isHidden = false
                        self.btn_Resend.isHidden = false
                        
                        
                    } else {
                        Toast(text: (dictionary["returnmessage"] as! String)).show()
                    }
                    
                    
                }else {
                    Toast(text: "Something went to wrong").show()
                }
                
            }
        }
        
    }else{
    Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
    }
        
    }
    @IBAction func btn_Back(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       
        self.view.endEditing(true)
        return false
    }
    
    func isValidEmailAddress(emailAddressString: String) -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
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


