//
//  VDG_ScratchWinHome_ViewController.swift
//  VeriDocG
//
//  Created by Bhavdip Patel on 04/10/18.
//  Copyright © 2018 SevenBits. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase
import FirebaseAuth
import FirebaseDatabase
import NVActivityIndicatorView
import PKHUD
import AMPopTip



class VDG_ScratchWinHome_ViewController: UIViewController, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var vw_BK_SW: UIView!
    @IBOutlet var vw_BK_MyRewards: UIView!
    @IBOutlet var btn_Up: UIButton!
    @IBOutlet var btn_down: UIButton!
    @IBOutlet var btn_BackButton : UIButton!
    var isLevelUp = false
    var window: UIWindow?
    let popTip1 = PopTip()
    let popTip2 = PopTip()
    var totalscratchused = Int()
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        // Do any additional setup after loading the view.
//        let swipeUP = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
//        swipeUP.direction = UISwipeGestureRecognizerDirection.up
//        vw_BK_MyRewards.addGestureRecognizer(swipeUP)
//        vw_BK_MyRewards.isUserInteractionEnabled = true
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap_vw_ScratchWin(_:)))
        vw_BK_SW.addGestureRecognizer(tap)
        vw_BK_SW.isUserInteractionEnabled = true
        
      
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.tap_vw_MyRewards(_:)))
        vw_BK_MyRewards.addGestureRecognizer(tap2)
        vw_BK_MyRewards.isUserInteractionEnabled = true

        
        self.navigationController?.navigationBar.isHidden = true
        
        animatScratch()
        animateMyReward()
        
        get_Scratches_Info()
        
     
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
         refreshTooltips()
        
    }
    
    func refreshTooltips() {
        
        
        if UserDefaults.standard.object(forKey: "tooltipscratch") != nil {
            let tooltipscratch =  UserDefaults.standard.object(forKey: "tooltipscratch") as! String
            let tooltipmyrewards =  UserDefaults.standard.object(forKey: "tooltipmyrewards") as! String
            
            if tooltipscratch == "1" {
                zoomIn_Scratch()
            }else if tooltipmyrewards == "1" {
                zoomIn_MyRewards()
            }else {
                
            }
            
        }
        
    
      
    }
    
    
    func zoomIn_Scratch() {
        
       
        popTip1.font = UIFont(name: "Avenir-Medium", size: 15)!
        popTip1.textColor = UIColor.white
        popTip1.shouldDismissOnTap = true
        popTip1.shouldDismissOnTapOutside = true
        popTip1.shouldDismissOnSwipeOutside = true
        popTip1.edgeMargin = 5
        popTip1.offset = 2
        popTip1.bubbleOffset = 0
        popTip1.edgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        popTip1.actionAnimation = .bounce(10)

        
        popTip1.dismissHandler = { _ in
            print("dismiss")
            UserDefaults.standard.set("2", forKey: "tooltipscratch")
            UserDefaults.standard.synchronize()
            
            self.refreshTooltips()
            
        }
        popTip1.bubbleColor = Constant.GlobalConstants.kColor_Theme
        
        popTip1.show(text: "Tap Here\nTo play Scratch and win!", direction: .down, maxWidth: 200, in: vw_BK_MyRewards, from: btn_Up.frame)
        
       
        
      
    }
    
    @objc func animatScratch() {
        // specify the property you want to animate
//        let zoomInAndOut = CABasicAnimation(keyPath: "transform.scale")
//        // starting from the initial value 1.0
//        zoomInAndOut.fromValue = 1.0
//        // to scale down you set toValue to 0.5
//        zoomInAndOut.toValue = 1.05
//        // the duration for the animation is set to 1 second
//        zoomInAndOut.duration = 10.0
//        // how many times you want to repeat the animation
//        zoomInAndOut.repeatCount = HUGE
//        // to make the one animation(zooming in from 1.0 to 0.5) reverse to two animations(zooming back from 0.5 to 1.0)
//        zoomInAndOut.autoreverses = true
//        // because the animation consists of 2 steps, caused by autoreverses, you set the speed to 2.0, so that the total duration until the animation stops is 5 seconds
//        zoomInAndOut.speed = 10.0
//        // add the animation to your button
//        vw_BK_SW.layer.add(zoomInAndOut, forKey: "scale")
        
       vw_BK_SW.zoomFirst()
    }
    
    @objc func animateMyReward() {
   
//        // specify the property you want to animate
//        let zoomInAndOut = CABasicAnimation(keyPath: "transform.scale")
//        // starting from the initial value 1.0
//        zoomInAndOut.fromValue = 1.05
//        // to scale down you set toValue to 0.5
//        zoomInAndOut.toValue = 1.0
//        // the duration for the animation is set to 1 second
//        zoomInAndOut.duration = 10.0
//
//
//        // Set animation to be consistent on completion
//        zoomInAndOut.isRemovedOnCompletion = false
//        zoomInAndOut.fillMode = kCAFillModeForwards
//
//        // how many times you want to repeat the animation
//       // zoomInAndOut.repeatCount = HUGE
//        // to make the one animation(zooming in from 1.0 to 0.5) reverse to two animations(zooming back from 0.5 to 1.0)
//        zoomInAndOut.autoreverses = true
//        // because the animation consists of 2 steps, caused by autoreverses, you set the speed to 2.0, so that the total duration until the animation stops is 5 seconds
//        zoomInAndOut.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//        zoomInAndOut.speed = 10.0
//        // add the animation to your button
//        vw_BK_MyRewards.layer.add(zoomInAndOut, forKey: "scale")
        
     
        
        
       vw_BK_MyRewards.zoomSecound()
            
      

       
    }
    
    func zoomIn_MyRewards() {
        
        
        popTip2.font = UIFont(name: "Avenir-Medium", size: 15)!
        popTip2.textColor = Constant.GlobalConstants.kColor_Theme
        popTip2.shouldDismissOnTap = true
        popTip2.shouldDismissOnTapOutside = true
        popTip2.shouldDismissOnSwipeOutside = true
        popTip2.edgeMargin = 5
        popTip2.offset = 2
        popTip2.bubbleOffset = 0
        popTip2.edgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        popTip2.actionAnimation = .bounce(10)
        
        
        popTip2.dismissHandler = { _ in
            print("dismiss")
            
            UserDefaults.standard.set("2", forKey: "tooltipmyrewards")
            UserDefaults.standard.synchronize()
            
            self.refreshTooltips()
        }
        
        
        popTip2.bubbleColor = UIColor.white
        popTip2.show(text: "Tap Here\nTo see My Rewards!", direction: .up, maxWidth: 200, in: vw_BK_SW, from: btn_down.frame)
        
        
    
        
    }
    
    
    
    
    
  
    
    
    
    @IBAction func btn_BackButton(_ sender: UIButton)  {
        let mainVcIntial = kConstantObj.SetIntialMainViewController("VDG_Home_ViewController")
        self.window?.rootViewController = mainVcIntial
    }
    
    @IBAction func btn_Menu(_ sender: UIButton)  {
        sideMenuVC.toggleMenu()
    }
    
    @objc func tap_vw_ScratchWin(_ sender: UITapGestureRecognizer) {
      
      if Connectivity.isConnectedToInternet {
        
                popTip1.removeFromSuperview()
                popTip2.removeFromSuperview()

               
                if  isLevelUp == true {
                    kConstantObj.SetMainViewController("VDG_MyRewardHome_ViewController")
                   
                }else {
                    kConstantObj.SetMainViewController("VDG_ScratchWinNow_ViewController")
                }
        
        }else {
          Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
        }
        
    }
    
    @objc func tap_vw_MyRewards(_ sender: UITapGestureRecognizer) {
        
        if Connectivity.isConnectedToInternet {
                popTip1.removeFromSuperview()
                popTip2.removeFromSuperview()
              //  let viewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_MyRewardHome_ViewController") as! VDG_MyRewardHome_ViewController
              //  self.navigationController?.pushViewController(viewController, animated: false)
        
                 kConstantObj.SetMainViewController("VDG_MyRewardHome_ViewController")
        
        }else {
            Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
        }
        
    }

    
    func get_Scratches_Info() {
        
        isLevelUp = false
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
                
                self.totalscratchused = dic_Info["total_used_scratch"]  as! Int
                
                
                let Total_remaining_level_scratch = dic_Info["remaining_level_scratch"] as! Int
                let total_level_scratch = dic_Info["total_level_scratch"] as! Int
                let total_used_scratch = dic_Info["total_used_scratch"] as! Int
               
                
                
                
                
                var perCent = (Float(total_level_scratch - Total_remaining_level_scratch) * 100.00) / Float(Constant.GlobalConstants.str_scratch_FirstLevel)
                
                
        
                
                if perCent <= 1.0  {
                    perCent  =  1.0
                    self.isLevelUp = false
                }else if perCent >= 100.00 {
                    perCent = 100.00
                    self.isLevelUp = true
                }
                
            
                
                let str_Tmp = dic_Info["today_date"] as! String
                
                print(str_Tmp)
                
                if str_Tmp != str_Date {
                    let mainVcIntial = kConstantObj.SetIntialMainViewController("VDG_ScanNowLoading_ViewController")
                    self.window?.rootViewController = mainVcIntial
                }
                
            }
            
        })
        
    }
    
    
    
}
