//
//  VDG_ScratchHistory_ViewController.swift
//  VeriDocG
//
//  Created by Bhavdip Patel on 30/10/18.
//  Copyright © 2018 SevenBits. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase
import FirebaseAuth
import FirebaseDatabase

import PKHUD


class VDG_ScratchHistory_ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet var tbl_History: UITableView!
    @IBOutlet var btn_Close : UIButton!
    @IBOutlet var btn_Help : UIButton!
    @IBOutlet var btn_Confirm : UIButton!
    @IBOutlet var btn_Edit : UIButton!
    @IBOutlet var btn_check : UIButton!
    @IBOutlet var lbl_RemainTS: UILabel!
    @IBOutlet var txt_Address: UITextView!
    @IBOutlet var txt_Contact : UITextView!
    var str_Remain : String!
    var totalDays = Int()
    var arr_LastDayInfo = [[String:AnyObject]]()
    var arr_Final = [[String:AnyObject]]()
    var buttonsArray = [UIButton]()
    var img_ScreenShot: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let nib = UINib.init(nibName: "VDG_ScratchHistory_Cell", bundle: nil)
        tbl_History.register(nib, forCellReuseIdentifier: "VDG_ScratchHistory_Cell")
      
        GetHistory()
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        let image = Constant.GradientImage() as UIImage?
        
        
        
        self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        //self.navigationController?.navigationBar.barTintColor = Constant.GlobalConstants.kColor_Theme
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        img_ScreenShot = self.takeScreenshot(false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr_Final.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "VDG_ScratchHistory_Cell"
        
        var cell: VDG_ScratchHistory_Cell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? VDG_ScratchHistory_Cell
        
        
        if cell == nil {
            if(cell == nil) {
                cell = Bundle.main.loadNibNamed("VDG_ScratchHistory_Cell", owner: self, options: nil)![0] as? VDG_ScratchHistory_Cell
            }
        }
        
        
       
       
        cell.lbl_DayNumber.text = "Day " + String(indexPath.row + 1 as! Int)
       
        
        let dayInfo =  self.arr_Final[indexPath.row]
        
        let str_Amt = dayInfo["totlabutton"] as! String
       
        let totalDayScratch = Constant.GlobalConstants.str_TotalScratchesPerDay
        
        var arr_status = [String]()
        
        if str_Amt.count == 0 {
            
        }else {
            arr_status = str_Amt.components(separatedBy: ",")
        }
        
     
        
        let totalButton = totalDayScratch
        var xvalue = 20
        let yvalue = cell.lbl_DayNumber.frame.origin.y
        
        for i in 0..<arr_status.count {
            
            
            
                let button = UIButton(frame: CGRect(x: xvalue, y: Int(yvalue), width: 45 , height:45))
            
                button.backgroundColor = UIColor.clear
            
            
               let isLoss = Int(arr_status[i] as! String)!
        
            
                if isLoss == 0 {
                    button.setBackgroundImage(UIImage(named: "icn_used_scratches"), for: .normal)
                    button.isUserInteractionEnabled = false
                    
                }else {
                    button.setBackgroundImage(UIImage(named: "icn_pending_scratches"), for: .normal)
                    button.isUserInteractionEnabled = false
                }
                
                button.tag = i
                cell.vw_BK.addSubview(button)
                
                xvalue = xvalue + 15 + 45
            
        }
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 110.0
    }
    
    @IBAction func btn_Close(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: false)
    }
    @IBAction func btn_Help(_ sender: UIButton) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Help_Scratch_Win_ViewController") as! VDG_Help_Scratch_Win_ViewController
        secondViewController.img_Bk = img_ScreenShot
        secondViewController.str_Descptn = "- Inspect the complete Point WON during SCRATCH AND WIN.       \n       \n- Using more SCRATCH CARDS will increase the LEVEL and the chances of winning VALUABLES will be also increased.       \n       \n- The CIRCULAR PROGRESS BAR and the HORIZONTAL PROGRESS BAR is used to track the LEVEL for level up and required Points for redemption.       \n       \n- The Point can be used to redeem once the horizontal progress bar is MATURE.       \n       \n- Available rewards can be viewed in the PRIZES SECTION."
        self.present(secondViewController, animated: true)
    }
    @IBAction func btn_Confirm(_ sender: UIButton) {
        
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
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Share_ViewController") as! VDG_Share_ViewController
        secondViewController.img_Bk = img_ScreenShot
        self.navigationController?.present(secondViewController, animated: true)
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
    
    
    func GetHistory() {
        
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
                
                self.arr_LastDayInfo = (arr_Days as NSArray).sortedArray(using: [NSSortDescriptor(key: "day", ascending: true)]) as! [[String:AnyObject]]
                
                let dayInfo =  self.arr_LastDayInfo.last as! [String: AnyObject]
            
                let ScratchPerDay = dayInfo["day"] as! Int
                
                self.totalDays = Int(self.str_Remain)! / ScratchPerDay
                
                print(self.str_Remain)
                
                print(self.totalDays)
                
                
                var firebaserecord = self.arr_LastDayInfo.count
                firebaserecord = firebaserecord - 1
                
               
                
                for i in 0..<self.totalDays {
                    
                    
                    if i <= firebaserecord {
                        
                        let str_Amt = dayInfo["winAmount"] as! String
                        
        
                        self.arr_Final.append(["totlabutton": str_Amt as AnyObject])
                        
                    }else {
                        
                        self.arr_Final.append(["totlabutton": "" as AnyObject])
                        
                    }
                    
                    
                   }
              
                self.tbl_History.reloadData()
                
           
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
