//
//  VDG_Invite_ViewController.swift
//  VeriDocG
//
//  Created by Bhavdip Patel on 18/10/18.
//  Copyright © 2018 SevenBits. All rights reserved.
//

import UIKit
import MessageUI

import SwiftKeychainWrapper
import Firebase
import FirebaseAuth
import FirebaseDatabase
import NVActivityIndicatorView
import PKHUD



class VDG_Invite_ViewController: UIViewController, MFMessageComposeViewControllerDelegate {
   
    

    @IBOutlet var img_BK_View: UIImageView!
    var img_Bk: UIImage!
    @IBOutlet var btn_Rule: UIButton!
    @IBOutlet var btn_Close: UIButton!
    let kHeaderSectionTag: Int = 6900;
    @IBOutlet var vw_DeviceContact: UIView!
    @IBOutlet var vw_DeviceApp: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var vw_TblBK: UIView!
    @IBOutlet var btn_DeviceApp: UIButton!
    @IBOutlet var lbl_AppTitle: UILabel!
    @IBOutlet var btn_DeviceContact: UIButton!
    @IBOutlet var lbl_ContactTitle: UILabel!
    var str_Invite_Title : String!
    var str_Invite_URL : String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = true
        
        img_BK_View.image = img_Bk
        
        // Do any additional setup after loading the view.
        
    
        
        
        vw_TblBK.layer.cornerRadius = 8
        vw_TblBK.clipsToBounds = true
      
        
        btn_DeviceContact.setBackgroundImage(UIImage(named: "icn_i_contact_active"), for: .normal)
        lbl_ContactTitle.textColor = UIColor.black
        
        
        btn_DeviceApp.setBackgroundImage(UIImage(named: "icn_i_app_active"), for: .normal)
        lbl_AppTitle.textColor = UIColor.black
        
        
        
    }

    @IBAction func btn_Rule(_ sender: UIButton){
        
    }
    @IBAction func btn_Close(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_DeviceApp(_ sender: UIButton){
        

        
        buttonAction()
    }
    
    @IBAction func btn_DeviceContact(_ sender: UIButton){
        

        if (MFMessageComposeViewController.canSendText()) {
            
            let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
            
            let userFirst = userDetail!["firstname"] as! String
            
            
            let name = userFirst
            let strMsg = "\(name) is scratching to win Points everyday!\n\nHave you tried your luck yet? Now available on android and app store.\n\nDownload from the links below.\n\nPlay Store: https://play.google.com/store/apps/details?id=com.veridocscratch.android\n\nApp Store: \(ConstantsModel.BasePath.url_appstorescratchandwinapp)"
            
            
            let controller = MFMessageComposeViewController()
            controller.body = strMsg
            controller.recipients = []
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
        
        
    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func buttonAction() {
       
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        
        let userFirst = userDetail!["firstname"] as! String
        
        
        let name = userFirst
        let strMsg = "\(name) is scratching to win Points everyday!\n\nHave you tried your luck yet? Now available on android and app store.\n\nDownload from the links below.\n\nPlay Store: https://play.google.com/store/apps/details?id=com.veridocscratch.android\n\nApp Store: \(ConstantsModel.BasePath.url_appstorescratchandwinapp)"
        
        let someText:String = strMsg
        
        let sharedObjects:[AnyObject] = [someText as AnyObject]
        let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
   //   activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.copyToPasteboard,UIActivityType.saveToCameraRoll,UIActivityType.addToReadingList,UIActivityType.airDrop,UIActivityType.openInIBooks]
        
        
        
        
        activityViewController.completionWithItemsHandler = { (activity, success, items, error) in
            print(success ? "SUCCESS!" : "FAILURE")
        }
        // self.present(activityViewController, animated: true, completion: nil)
        
        self.present(activityViewController, animated: true, completion: {
            
            activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
                // react to the completion
                if completed {
                    // user shared an item
                    // self.UpdateScratches()
                    print("We used activity type ",returnedItems as Any)
                    print("We used activity type\(activityType ?? UIActivityType(rawValue: ""))")
                    
                    Toast(text: "You have invited successfully.").show()
                    
                    
                    
                } else {
                    
                    // user cancelled
                    print("We didn't want to share anything after all.")
                }
                
                if error != nil {
                    print("An Error occured: \(error?.localizedDescription ?? ""), \((error as NSError?)?.localizedFailureReason ?? "")")
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
                
               let old_TotalScratch = dic_Info["remaining_level_scratch"] as! Int
               let old_total_level_scratch = dic_Info["total_level_scratch"] as! Int
            
                    
                        
                 let str_NewRemaining = Constant.GlobalConstants.str_TotalScratchesPerInvited + old_TotalScratch
                
                 let str_Newold_total_level_scratch = Constant.GlobalConstants.str_TotalScratchesPerInvited +  old_total_level_scratch
                
                       dic_Info["remaining_level_scratch"] = str_NewRemaining as AnyObject
                       dic_Info["total_level_scratch"] = str_Newold_total_level_scratch as AnyObject
                       dic_Info["is_today_invite"] = true as AnyObject
                        
                Database.database().reference().child("Scratch&Win").child(userID).child((userID)+"-Scratch&Win").updateChildValues(dic_Info){ (error, ref) -> Void in
                            
                            if error != nil {
                                
                                Toast(text: error?.localizedDescription).show()
                                
                                return
                            }else {
                                self.dismiss(animated: true, completion: nil)
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
