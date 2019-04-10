//
//  VDG_Phone_ViewController.swift
//  VeriDocG
//
//  Created by Bhavdip Patel on 26/12/18.
//  Copyright © 2018 SevenBits. All rights reserved.
//

import UIKit
import FlagPhoneNumber
import MessageUI
import SwiftKeychainWrapper
import PasswordTextField
import KWVerificationCodeView
import PKHUD
import Firebase
import FirebaseAuth
import NVActivityIndicatorView


class VDG_Phone_ViewController: UIViewController {
    
    var window: UIWindow?
    
    // Ophone Verification
    var img_BK_screeen: UIImage!
    @IBOutlet var img_BK: UIImageView!
    @IBOutlet var vw_Phone_MainBK: UIView!
    @IBOutlet var lbl_TitleName: UILabel!
    @IBOutlet var lbl_Desc: UILabel!
    @IBOutlet var btn_Close: UIButton!
    @IBOutlet var btn_Privacy: UIButton!
    @IBOutlet var btn_Received: UIButton!
    @IBOutlet var txt_PhoneNumber: FPNTextField!
    var isValidMobile: Bool!
    var dotNumber: Int!
    @IBOutlet var vw_PhoneNumber: UIView!
    @IBOutlet var vw_VerificationPhone: UIView!
    @IBOutlet var vw_VerificationEmail: UIView!
    @IBOutlet var vw_RequestReceiveOTP: UIView!
    @IBOutlet var btn_RequestReceiveOTP: UIButton!
    @IBOutlet var lbl_RequestMobileNumber: UILabel!
    
    @IBOutlet weak var verificationCodeView: PinCodeTextField!
    @IBOutlet weak var lbl_Verification_Phone: UILabel!
    @IBOutlet weak var lbl_Verification_Email: UILabel!
    @IBOutlet weak var verificationEmailCodeView: PinCodeTextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var submitEmailButton: UIButton!
    
    var is_MobileAvailable: Bool!
    var is_SideMenu: Bool!
    var str_Code: String!
    var str_Mobile: String!
    var str_OTP: String!
    var str_verificationID: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        str_OTP = ""
        // Do any additional setup after loading the view.
        
        txt_PhoneNumber.layer.cornerRadius = 6.0
        txt_PhoneNumber.layer.borderColor = Constant.GlobalConstants.kColor_Theme.cgColor
        txt_PhoneNumber.layer.borderWidth = 0.7
        txt_PhoneNumber.keyboardType = .asciiCapableNumberPad
        // Comment this line to not have access to the country list
        txt_PhoneNumber.parentViewController = self
        txt_PhoneNumber.flagPhoneNumberDelegate =  self
        
        // Custom the size/edgeInsets of the flag button
        txt_PhoneNumber.flagSize = CGSize(width: 35, height: 35)
        txt_PhoneNumber.flagButtonEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        txt_PhoneNumber.hasPhoneNumberExample = true
        txt_PhoneNumber.layer.borderColor = Constant.GlobalConstants.kColor_Theme.cgColor
        txt_PhoneNumber.layer.borderWidth = 1.0
        txt_PhoneNumber.textColor = UIColor.black
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        
        lbl_TitleName.text = "Hello \(userDetail!["firstname"] as! String)"
        
        lbl_Desc.text = "Let's set you up! Please enter your mobile number where you will receive a One-Time Password (OTP) for authentication. \n \n We highly respect your privacy and your information is kept secure and never shared."
        
        btn_Received.layer.cornerRadius = 8
        
        
        print(dotNumber)
        
        vw_Phone_MainBK.layer.cornerRadius = 8
        
        
        vw_PhoneNumber.isHidden = false
        vw_VerificationPhone.isHidden = true
        vw_VerificationEmail.isHidden = true
        vw_RequestReceiveOTP.isHidden = true
        
        
        vw_PhoneNumber.layer.cornerRadius = 8
        vw_VerificationPhone.layer.cornerRadius = 8
        vw_VerificationEmail.layer.cornerRadius = 8
        vw_RequestReceiveOTP.layer.cornerRadius = 8
        
        
        vw_PhoneNumber.clipsToBounds = true
        vw_VerificationPhone.clipsToBounds = true
        vw_VerificationEmail.clipsToBounds = true
        vw_RequestReceiveOTP.clipsToBounds = true
        
        
    
        submitButton.isEnabled = true
        verificationCodeView.delegate = self
        submitButton.layer.cornerRadius = 8
        btn_RequestReceiveOTP.layer.cornerRadius = 8
        
        
        submitEmailButton.isEnabled = true
        verificationEmailCodeView.delegate = self
        submitEmailButton.layer.cornerRadius = 8
      
        
        
        
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
//            self.verificationEmailCodeView.becomeFirstResponder()
//        }
        
        verificationEmailCodeView.delegate = self
        verificationEmailCodeView.keyboardType = .asciiCapableNumberPad
    
        let toolbar = UIToolbar()
        let nextButtonItem = UIBarButtonItem(title: NSLocalizedString("Done",
                                                                      comment: ""),
                                             style: .done,
                                             target: self,
                                             action: #selector(pinCodeNextAction))
        toolbar.items = [nextButtonItem]
        toolbar.barStyle = .default
        toolbar.sizeToFit()
        verificationEmailCodeView.inputAccessoryView = toolbar
        
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
//            self.verificationCodeView.becomeFirstResponder()
//        }
        
        verificationCodeView.delegate = self
        verificationCodeView.keyboardType = .asciiCapableNumberPad
        
       
        verificationEmailCodeView.inputAccessoryView = toolbar
        verificationCodeView.inputAccessoryView = toolbar
        
        
        if is_SideMenu == true {
            
            vw_PhoneNumber.isHidden = true
            vw_VerificationPhone.isHidden = true
            vw_VerificationEmail.isHidden = false
            
             img_BK.image = img_BK_screeen
            
            let userDetailTmp = userDetail as! Dictionary<String,Any>
            userDetailTmp.mapValues { $0 is NSNull ? nil : $0 }
            let useremail = userDetailTmp["email"] as! String
            lbl_Verification_Email.text = useremail
            
            sendMail(strEmail: useremail)
            
            
            
        }else {
            
                img_BK.image = UIImage(named: "icn_smartlogin2")
            
                let userDetailTmp = userDetail as! Dictionary<String,Any>
                userDetailTmp.mapValues { $0 is NSNull ? nil : $0 }
            
                if userDetailTmp["contact"] != nil {
                    
                    var trimmedString = (userDetailTmp["contact"] as? String)?.trimmingCharacters(in: .whitespaces)
                    
                    if trimmedString?.count == 0 {
                        if UserDefaults.standard.string(forKey: "ContactNo") != nil {
                            trimmedString = UserDefaults.standard.string(forKey: "ContactNo")
                        }
                    }
                    
                    if trimmedString != nil  {
                        
                        let isMobileVerified = UserDefaults.standard.value(forKey:"isMobileVerified") as! Bool
                        
                        if isMobileVerified == false {
                            
                            str_Mobile = trimmedString
                           
                            lbl_RequestMobileNumber.text = str_Mobile
                            
                            self.vw_PhoneNumber.isHidden = true
                            self.vw_VerificationPhone.isHidden = true
                            self.vw_VerificationEmail.isHidden = true
                            self.vw_RequestReceiveOTP.isHidden = false
                            
                            
                        }else{
                            
                        }
                        
                    }else {
                        
                        vw_PhoneNumber.isHidden = false
                        vw_VerificationPhone.isHidden = true
                        vw_VerificationEmail.isHidden = true
                        
                       
                    }
                }else {
                    vw_PhoneNumber.isHidden = false
                    vw_VerificationPhone.isHidden = true
                    vw_VerificationEmail.isHidden = true
            }
        }
        
       
        btn_Received.layer.cornerRadius = 8
        btn_Received.clipsToBounds = true
        
        submitButton.layer.cornerRadius = 8
        submitButton.clipsToBounds = true
        
        submitEmailButton.layer.cornerRadius = 8
        submitEmailButton.clipsToBounds = true
        
        btn_RequestReceiveOTP.layer.cornerRadius = 8
        btn_RequestReceiveOTP.clipsToBounds = true
        
        

        
    }
    //function which is triggered when handleTap is called
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        //self.view.endEditing(true)
    }
    override public var prefersStatusBarHidden: Bool {
        return false
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @objc private func pinCodeNextAction() {
        print("next tapped")
        self.view.endEditing(true)
        
    }

    
    @IBAction func btn_Close(_ sender: UIButton) {
         if is_SideMenu == true {
            self.dismiss(animated: false, completion: nil)
            
         }else {
            self.dismiss(animated: false, completion: nil)
            kConstantObj.SetIntialMainViewController("VDG_ScanNowLoading_ViewController")
         }
       
    
    }
    @IBAction func btn_Privacy(_ sender: UIButton) {
        
         if Connectivity.isConnectedToInternet {
            guard let url = URL(string: "https://veridocglobal.com/Privacy%20Policy/VeriDoc%20Global%20Privacy%20Policy.pdf") else { return }
            UIApplication.shared.open(url)
        
         }else{
            Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
        }
        
    }
    
    @IBAction func btn_Phone_Resend(_ sender: UIButton) {
        
          if Connectivity.isConnectedToInternet {
               if str_Mobile.count > 0 {
                
                 Send_MobileOTP(str_MobileTmp: str_Mobile)
               
                
                }else {
                    Toast(text: "Mobile number does not found").show()
                }
         }else{
            Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
         }
       
    }
    
    @IBAction func btn_RequestReceived(_ sender: UIButton) {
        
    if Connectivity.isConnectedToInternet {
        
        if (str_Mobile.count) > 0 {
            
            Send_MobileOTP(str_MobileTmp: str_Mobile)
            
        }else {
            
            Toast(text: "Mobile number does not found").show()
            
        }
            
    }else{
        Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
    }
        
        
    }
        
    @IBAction func btn_Received(_ sender: UIButton) {
       
        if Connectivity.isConnectedToInternet {
        
        if (txt_PhoneNumber.text?.count)! > 0 {
            
            if isValidMobile == true {
               
                
                
                Send_MobileOTP(str_MobileTmp: str_Mobile)
               
                
                
            }else {
                Toast(text: "Please enter valid mobile number").show()
            }
            
        }else {
           Toast(text: "Please enter mobile number").show()
        }
        }else{
            Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
        }
        
        
    }
    
    func Send_MobileOTP(str_MobileTmp: String) {
        
        if Connectivity.isConnectedToInternet {
        
        let phoneNumber = str_MobileTmp
        
      
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
        
        Auth.auth().settings?.isAppVerificationDisabledForTesting = false
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate:nil) {
            verificationID, error in
            
            // remove Indicator
            activityIndicatorView.stopAnimating()
            activityIndicatorView.removeFromSuperview()
            vw_Load_BK.removeFromSuperview()
            
            if ((error) != nil) {
                print(error as Any)
               
                let tmp = error?.localizedDescription
                print(tmp as Any)
                PKHUD.sharedHUD.hide()
                self.submitButton.isEnabled = false
                Toast(text: tmp).show()
                return
                
            }else {
                
                 PKHUD.sharedHUD.hide()
                self.submitButton.isEnabled = true
                Toast(text: "Code sent to your number").show()
                self.lbl_Verification_Phone.text = self.str_Mobile
                self.str_verificationID = verificationID
                self.vw_PhoneNumber.isHidden = true
                self.vw_VerificationPhone.isHidden = false
                self.vw_VerificationEmail.isHidden = true
                self.vw_RequestReceiveOTP.isHidden = true
            }
            PKHUD.sharedHUD.hide()
            
            
        }
        }else{
            Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
            
        }
    }
    
    // MARK: - IBAction
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        
        
       if Connectivity.isConnectedToInternet {
        
        print(str_OTP)
        
        if str_OTP.count != 0  {
            
            if str_OTP.count > 5  {
            

            
           //  str_OTP = verificationCodeView.getVerificationCode()
            
                let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.str_verificationID ?? "",
                                                                                         verificationCode: str_OTP!)
            
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
                
                    Auth.auth().signInAndRetrieveData(with: credential) { authData, error in
                        
                        // remove Indicator
                        activityIndicatorView.stopAnimating()
                        activityIndicatorView.removeFromSuperview()
                        vw_Load_BK.removeFromSuperview()
                        
                                    if ((error) != nil) {
                                        
                                        
                                        let tmp = error?.localizedDescription
                                        print(tmp)
                                        PKHUD.sharedHUD.hide()
                                        if tmp == "The SMS verification code used to create the phone auth credential is invalid. Please resend the verification code SMS and be sure to use the verification code provided by the user." {
                                            Toast(text: "Wrong OTP").show()
                                        }else {
                                          Toast(text: tmp).show()
                                        }
            
                                        return
                                    }else {
                                        print(error.debugDescription)
                                        
                                        
                                         self.API_UpdateContact()
                                    }
                                    
                                   
            
                     }
            
            }else{
                Toast(text: "Invalid Email OTP").show()
            }
            
            
        }else{
            Toast(text: "Please enter OTP").show()
        }
    }else{
    Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
    
    }
    }
    
    @IBAction func submitEmailButton(_ sender: UIButton) {
        if Connectivity.isConnectedToInternet {
     if str_OTP.count != 0  {
        
        if str_OTP.count > 5  {
            
            let Entered_EmailOTP = Int(str_OTP)
            //UserDefaults.standard.set(int_OTP, forKey:"EMAILOTP")
            let Sent_EmailOTP = UserDefaults.standard.value(forKey: "EMAILOTP") as! Int
            
            if  Entered_EmailOTP == Sent_EmailOTP {
                
                vw_PhoneNumber.isHidden = false
                vw_VerificationPhone.isHidden = true
                vw_VerificationEmail.isHidden = true
                
                txt_PhoneNumber.text = nil
                verificationEmailCodeView.text = nil
                
            }else{
                Toast(text: "Wrong OTP").show()
            }
            
         }else{
            Toast(text: "Wrong OTP").show()
         }
            
          
        }else{
            Toast(text: "Please enter OTP").show()
        }
     }else{
      Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
     }
    
    }
    
    @IBAction func clearButtonTapped(_ sender: UIButton) {
          verificationCodeView.text = nil
        
    }
    
    @IBAction func btn_TryToDifferent(_ sender: UIButton) {
        
        if Connectivity.isConnectedToInternet {
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        let useremail = userDetail!["email"] as! String
        lbl_Verification_Email.text = useremail
        
        sendMail(strEmail: useremail)
        }else{
            Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
        }

    }
    @IBAction func btn_TryToDifferentResent(_ sender: UIButton) {
        
        if Connectivity.isConnectedToInternet {
        
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        let useremail = userDetail!["email"] as! String
        lbl_Verification_Email.text = useremail
        
        sendMail(strEmail: useremail)
        }else{
            Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func API_UpdateContact(){
        
        if Connectivity.isConnectedToInternet {
            
       let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        
        let userID = userDetail!["customerguid"] as! String
        let usercontact = str_Mobile
        let userfirstname = userDetail!["firstname"] as! String
        let userlastname = userDetail!["lastname"] as! String
        let useremail = userDetail!["email"] as! String
            
        
            
            let dictParams: [String: AnyObject] = ["customerguid" :  userID as AnyObject,"contact" : usercontact as AnyObject ,
                                                   "firstname" : userfirstname as AnyObject, "lastname" : userlastname as AnyObject, "email" : useremail as AnyObject]
        
           print(dictParams)
        
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
            
            Webservices_Alamofier.postWithURLVerify(serverlink: ConstantsModel.WebServiceUrl.API_updatecustomer, methodname: "", param:dictParams as NSDictionary, key: "key") { (bool, dictionary) in
                
                // remove Indicator
                activityIndicatorView.stopAnimating()
                activityIndicatorView.removeFromSuperview()
                vw_Load_BK.removeFromSuperview()
                
                if bool == true {
                   
                    
                    let saveSuccessful: Bool = KeychainWrapper.standard.set(dictionary, forKey: ConstantsModel.KeyDefaultUser.userData)
                    
                    print("Save was successful: \(saveSuccessful)")
                   
                    if bool == true {
                        
                        let returnCode = dictionary["returncode"] as! Int
                        
                        if returnCode == 1{
                            
                              UserDefaults.standard.set(Bool(true), forKey:"isMobileVerified")
                              UserDefaults.standard.synchronize()
                            
                                Toast(text: "Verified OTP").show()
                                self.vw_PhoneNumber.isHidden = true
                                self.vw_VerificationPhone.isHidden = true
                                self.vw_VerificationEmail.isHidden = true
                                self.vw_RequestReceiveOTP.isHidden = true
                                self.txt_PhoneNumber.text = nil
                                self.verificationCodeView.text = nil
                                self.dismiss(animated: true, completion: nil)
                        
                            
                        }else  if returnCode == 15 {
                         
                        } else if returnCode == 13 {
                           
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
    
    
    func sendMail(strEmail: String)  {
        
        if Connectivity.isConnectedToInternet {
            
            
            
            
            let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
            
            let userfirstname = userDetail!["firstname"] as! String
            let userlastname = userDetail!["lastname"] as! String
            let userID = userDetail!["customerguid"] as! String
            
            let int_OTP = (Int(generateRandomDigits(6))) as! Int
            
            UserDefaults.standard.set(int_OTP, forKey:"EMAILOTP")
            UserDefaults.standard.synchronize()
            
            let str_Cont = "This mail has been sent from VDG Scratch n Win app along for OTP " + String(int_OTP)
            
            
            let dictParams: [String: AnyObject] = ["customerguid" :  userID as AnyObject, "toname" : userfirstname+" "+userlastname as AnyObject ,
                                                   "toaddress" : strEmail as AnyObject , // Always use optional values carefully!
                "subject" : "Verification OTP" as AnyObject ,
                "body" : str_Cont as AnyObject ,
                ]
            //
            
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
            
            Webservices_Alamofier.postWithURL(serverlink: ConstantsModel.WebServiceUrl.API_sendemail, methodname: "", param:dictParams as NSDictionary, key: "key") { (bool, dictionary) in
                // you code goes here
                
                // spinner.dismiss()
                
                // remove Indicator
                activityIndicatorView.stopAnimating()
                activityIndicatorView.removeFromSuperview()
                vw_Load_BK.removeFromSuperview()
                
                
                if bool == true {
                    
                    let returncode = dictionary["returncode"] as! NSInteger
                    
                    if returncode == 1 {
                        
                        Toast(text: "OTP has sent to your mail address").show()
                        self.vw_PhoneNumber.isHidden = true
                        self.vw_VerificationPhone.isHidden = true
                        self.vw_VerificationEmail.isHidden = false
                        self.vw_RequestReceiveOTP.isHidden = true
                        
                    }else {
                        Toast(text: (dictionary["returnmessage"] as! String)).show()
                    }
                }
                
                
            }
            
        }else{
            Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
            
        }
        
        
    }
    
    
    func generateRandomDigits(_ digitNumber: Int) -> String {
        var number = ""
        for i in 0..<digitNumber {
            var randomNumber = arc4random_uniform(10)
            while randomNumber == 0 && i == 0 {
                randomNumber = arc4random_uniform(10)
            }
            number += "\(randomNumber)"
        }
        return number
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


// MARK: - KWVerificationCodeViewDelegate
//extension VDG_Phone_ViewController: KWVerificationCodeViewDelegate {
//    func didChangeVerificationCode() {
//        submitButton.isEnabled = verificationCodeView.hasValidCode()
//        submitEmailButton.isEnabled = verificationEmailCodeView                                                        .hasValidCode()
//    }
//}
extension VDG_Phone_ViewController: PinCodeTextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: PinCodeTextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: PinCodeTextField) {
        
    }
    
    func textFieldValueChanged(_ textField: PinCodeTextField) {
        let value = textField.text ?? ""
        print("value changed: \(value)")
        str_OTP = value
        
    }
    
    func textFieldShouldEndEditing(_ textField: PinCodeTextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: PinCodeTextField) -> Bool {
        return true
    }
}


extension VDG_Phone_ViewController: FPNTextFieldDelegate {
    
    func didSelectCountry(name: String, dialCode: String, code: String) {
        print(name, dialCode, code)
    }
    
    func didValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        print(isValid)
        isValidMobile = isValid
        
    }
    
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        
        textField.rightViewMode = UITextFieldViewMode.always
      
     //   textField.rightView = UIImageView(image: isValid ? #imageLiteral(resourceName: "success") : #imageLiteral(resourceName: "error"))
       // textField.leftViewMode = UITextFieldViewMode.always
        
      
        print(
            isValid,
            textField.getFormattedPhoneNumber(format: .E164),
            textField.getFormattedPhoneNumber(format: .International),
            textField.getFormattedPhoneNumber(format: .National),
            textField.getFormattedPhoneNumber(format: .RFC3966),
            textField.getRawPhoneNumber()
            
        )
        isValidMobile = isValid
        str_Mobile = textField.getFormattedPhoneNumber(format: .E164)
        
    }
    
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        print(name, dialCode, code)
    }
}
