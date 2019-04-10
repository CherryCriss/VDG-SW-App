//
//  VDG_View_MyReddemBox_ViewController.swift
//  VeriDocG
//
//  Created by Bhavdip Patel on 15/10/18.
//  Copyright © 2018 SevenBits. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase
import FirebaseAuth
import FirebaseDatabase
import NVActivityIndicatorView
import PKHUD



class VDG_View_MyReddemBox_ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource{

    
    @IBOutlet var tbl_Prizes: UITableView!
    @IBOutlet var btn_Close : UIButton!
    @IBOutlet var btn_Help : UIButton!
    @IBOutlet var btn_Redeem : UIButton!
    @IBOutlet var lbl_RemainTS: UILabel!
    var img_ScreenShot: UIImage!
    @IBOutlet var lbl_RedeemStatus: UILabel!
    var arr_PrizeList = [[String:AnyObject]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

         self.navigationController?.navigationBar.isHidden = true
        // Do any additional setup after loading the view.
        

        
        let nib = UINib.init(nibName: "VDG_MyRewards_Prize_Cell", bundle: nil)
        tbl_Prizes.register(nib, forCellReuseIdentifier: "VDG_MyRewards_Prize_Cell")
        img_ScreenShot = self.takeScreenshot(false)
        
        
        
        
        arr_PrizeList.append(["PrizeTitle" : "T-Shirt" as AnyObject,"PrizeType" : "2" as AnyObject, "PrizeDesc" : "test description" as AnyObject, "Prize_Image" : "tstirt.png" as AnyObject])
        
        arr_PrizeList.append(["PrizeTitle" : "Pen" as AnyObject,"PrizeType" : "3" as AnyObject, "PrizeDesc" : "test description" as AnyObject, "Prize_Image" : "icn_prize_pen.png" as AnyObject])
        
        arr_PrizeList.append(["PrizeTitle" : "T-Shirt" as AnyObject,"PrizeType" : "2" as AnyObject, "PrizeDesc" : "test description" as AnyObject, "Prize_Image" : "tstirt.png" as AnyObject])
        
     // arr_PrizeList.append(["PrizeTitle" : "T-Shirt" as AnyObject,"PrizeType" : "2" as AnyObject, "PrizeDesc" : "test description" as AnyObject, "Prize_Image" : "tstirt.png" as AnyObject])
        
        
        
        if arr_PrizeList.count >= Constant.GlobalConstants.TotalPrizePerRedeemBox {
            btn_Redeem.setBackgroundImage(UIImage(named: "icn_btn_bk_green"), for: .normal)
            lbl_RedeemStatus.isHidden = true
            btn_Redeem.setTitleColor(UIColor.white, for: .normal)
            btn_Redeem.isUserInteractionEnabled = true
        }else {
            
             lbl_RedeemStatus.isHidden = false
             btn_Redeem.setBackgroundImage(UIImage(named: "icn_disable_redeem_bk"), for: .normal)
             btn_Redeem.setTitleColor(UIColor.lightGray, for: .normal)
             btn_Redeem.isUserInteractionEnabled = false
            
        }
        let remainPrize = Constant.GlobalConstants.TotalPrizePerRedeemBox - arr_PrizeList.count
        
        lbl_RedeemStatus.text = "You need \(remainPrize) more prize to redeem."
        
        
        
        
        
        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr_PrizeList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "VDG_MyRewards_Prize_Cell"
        var cell: VDG_MyRewards_Prize_Cell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? VDG_MyRewards_Prize_Cell
        if cell == nil {
            tableView.register(UINib(nibName: "VDG_MyRewards_Prize_Cell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? VDG_MyRewards_Prize_Cell
        }
        
        let dic_Info = arr_PrizeList[indexPath.row]
        
        let str_Type = dic_Info["PrizeType"] as! String
        
        if str_Type == "2" {
            cell.segment_Size.isHidden = false
        }else {
            cell.segment_Size.isHidden = true
        }
        
        cell.img_Prize.image = UIImage(named: dic_Info["Prize_Image"] as! String)
        cell.lbl_Title.text = (dic_Info["PrizeTitle"] as! String)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 135.0
    }
    
    @IBAction func btn_Close(_ sender: UIButton) {
         _ = navigationController?.popViewController(animated: false)
    }
    @IBAction func btn_Help(_ sender: UIButton) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Help_Scratch_Win_ViewController") as! VDG_Help_Scratch_Win_ViewController
        secondViewController.img_Bk = img_ScreenShot
        secondViewController.str_Descptn = "- Inspect the complete Points WON during SCRATCH AND WIN.       \n       \n- Using more SCRATCH CARDS will increase the LEVEL and the chances of winning VALUABLES will be also increased.       \n       \n- The CIRCULAR PROGRESS BAR and the HORIZONTAL PROGRESS BAR is used to track the LEVEL for level up and required Points for redemption.       \n       \n- The Points can be used to redeem once the horizontal progress bar is MATURE.       \n       \n- Available rewards can be viewed in the PRIZES SECTION."
        self.navigationController?.present(secondViewController, animated: true)
    }
    @IBAction func btn_Redeem(_ sender: UIButton) {
        let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "VDG_Redeem_Confirm_ViewController") as! VDG_Redeem_Confirm_ViewController
        self.navigationController?.pushViewController(VC1, animated: true)
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
