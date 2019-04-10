//
//  VDG_Share_ViewController.swift
//  VeriDocG
//
//  Created by Bhavdip Patel on 17/10/18.
//  Copyright © 2018 SevenBits. All rights reserved.
//

import UIKit
import MessageUI
import NVActivityIndicatorView
import SwiftKeychainWrapper
import Firebase
import FirebaseAuth
import FirebaseDatabase

import PKHUD

class VDG_Share_ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var img_BK_View: UIImageView!
    var img_Bk: UIImage!
    @IBOutlet var btn_Rule: UIButton!
    @IBOutlet var btn_Close: UIButton!
    let kHeaderSectionTag: Int = 6900;
    @IBOutlet var vw_TblBK: UIView!
    @IBOutlet weak var tableView: UITableView!
    let lbl_Total_Scratch : UILabel! = nil
      var img_ScreenShot: UIImage!
    var expandedSectionHeaderNumber: Int = -1
    var expandedSectionHeader: UITableViewHeaderFooterView!
    var sectionItems: Array<Any> = []
    var sectionNames: Array<Any> = []
    var isBlogShare: Bool!
    let lbl_title_ : UILabel! = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        img_BK_View.image = img_Bk
        
        // Do any additional setup after loading the view.
        
        sectionNames = ["VeriDoc Global Blog"];
        sectionItems = [["The Story Behind VeriDoc Global...."]];
        self.tableView!.tableFooterView = UIView()
        
        
        vw_TblBK.layer.cornerRadius = 8
        vw_TblBK.clipsToBounds = true
        
        self.navigationController?.navigationBar.isHidden = true
        
          img_ScreenShot = self.takeScreenshot(false)
    }

    
    override func viewDidAppear(_ animated: Bool) {
        
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
    
    
    @IBAction func btn_Rule(_ sender: UIButton){
        
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Help_Scratch_Win_ViewController") as! VDG_Help_Scratch_Win_ViewController
        
        secondViewController.img_Bk = img_ScreenShot
        
        secondViewController.str_Descptn = "- Are you craving some more scratches? But first, would you like to share this blog on your Facebook page to reload your scratch counter. If you do not wish to share blog, simply press no to reload your scratch counter.\n\n- We will never post on your Facebook page without your permission..\n\n- This blog post will help generate awareness about the benefits of blockchain and how VeriDoc Global is a game changer."
        
        self.present(secondViewController, animated: true)
        
        
    }
    @IBAction func btn_Close(_ sender: UIButton){
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func buttonAction(sender: UIButton!) {
        
        let btnsendtag: UIButton = sender
        
        print(btnsendtag)
        
        let someText:String = "VeriDoc Global"
        let objectsToShare:URL = URL(string: ConstantsModel.BasePath.url_Share_Blog)!
        let sharedObjects:[AnyObject] = [objectsToShare as AnyObject,someText as AnyObject]
        let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
         activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.copyToPasteboard,UIActivityType.assignToContact,UIActivityType.saveToCameraRoll,UIActivityType.addToReadingList,UIActivityType.airDrop,UIActivityType.openInIBooks,UIActivityType.markupAsPDF, UIActivity.ActivityType(rawValue: "com.apple.reminders.RemindersEditorExtension"), UIActivity.ActivityType(rawValue: "com.apple.mobilenotes.SharingExtension"), UIActivity.ActivityType(rawValue: "com.google.chrome.ios")]
        
        
      
        
        
        
        
        activityViewController.completionWithItemsHandler = { (activity, success, items, error) in
            print(success ? "SUCCESS!" : "FAILURE")
        }
        // self.present(activityViewController, animated: true, completion: nil)
        
        self.present(activityViewController, animated: true, completion: {
            
            activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
                // react to the completion
                if completed {
                    // user shared an item
                    self.UpdateScratches(shareType: (activityType?.rawValue)!)
                    
                    print("We used activity type ",returnedItems as Any)
                    
                    print("We used activity type\(activityType ?? UIActivityType(rawValue: ""))")
                    
                   
                } else {
                    Toast(text: "Blog Sharing is cancelled! Please try again! ").show()
                    
                }
                
                if error != nil {
                    
                    print("An Error occured: \(error?.localizedDescription ?? ""), \((error as NSError?)?.localizedFailureReason ?? "")")
                    
                     Toast(text: "Blog Sharing is cancelled! Please try again! ").show()
                }
            }
        })
       
    }
    
    func UpdateScratches(shareType: String) {
        
        var ref = Database.database().reference() // undeclared
        
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        
        let userID = userDetail!["customerguid"] as! String
      
        
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
                
                let str_Tmp = dic_Info["today_date"]
                
                print(str_Tmp)
                
                
                
                
                
                let old_TotalScratch = dic_Info["remaining_level_scratch"] as! Int
                let old_total_level_scratch = dic_Info["total_level_scratch"] as! Int
                let old_today_use_scratch = dic_Info["today_use_scratch"] as! Int
                
                
                let PendingScratch = Constant.GlobalConstants.str_TotalScratchesPerDay - old_today_use_scratch
                
                var scratchperShared = 0
                
             //if self.isBlogShare == true {
                    scratchperShared = Constant.GlobalConstants.str_TotalScratchesPerShared
               
                
//                if shareType == "com.apple.UIKit.activity.PostToFacebook" {
//                    // facebook
//                    scratchperShared = 2
//                }else  if shareType == "com.apple.UIKit.activity.PostToTwitter" {
//                    // twitter
//                    scratchperShared = 5
//                }else  if shareType == "com.linkedin.LinkedIn.ShareExtension" {
//                    // linked
//                    scratchperShared = 5
//                }else {
//                    // other
//                    scratchperShared = 1
//                }
                
                
                let str_NewTS = scratchperShared + old_TotalScratch
                
                let str_Newtotal_level_scratch = scratchperShared + old_total_level_scratch
                
                dic_Info["remaining_level_scratch"] = str_NewTS as AnyObject
                dic_Info["total_level_scratch"] = str_Newtotal_level_scratch as AnyObject
                dic_Info["is_today_share"] = true as AnyObject
                dic_Info["today_avialble_scracth"] = PendingScratch as AnyObject
                Database.database().reference().child("Scratch&Win").child(userID).child((userID)+"-Scratch&Win").updateChildValues(dic_Info){ (error, ref) -> Void in
                    
                    if error != nil {
                        
                        Toast(text: error?.localizedDescription).show()
                        
                        return
                    }else {
                        Toast(text: "You Shared the blog Successfully!").show()
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
    
    // MARK: - Table view delegate
    // MARK: - Tableview Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if sectionNames.count > 0 {
            tableView.backgroundView = nil
            return sectionNames.count
        } else {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
            messageLabel.text = "Retrieving data.\nPlease wait."
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = .center;
            messageLabel.font = UIFont(name: "HelveticaNeue", size: 20.0)!
            messageLabel.sizeToFit()
            self.tableView.backgroundView = messageLabel;
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.expandedSectionHeaderNumber == section) {
            let arrayOfItems = self.sectionItems[section] as! NSArray
            return arrayOfItems.count;
        } else {
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (self.sectionNames.count != 0) {

            let str_Title = self.sectionNames[section] as! String

            let tmp = String(self.sectionItems.count) + " Scratches"


            return str_Title

        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38.0;
    }
    
   
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 0;
    }
    
   
   
 
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        //recast your view as a UITableViewHeaderFooterView
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.white
        header.textLabel?.textColor = UIColor.black
        header.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 14.0)!
        if let viewWithTag = self.view.viewWithTag(kHeaderSectionTag + section) {
            viewWithTag.removeFromSuperview()
        }
        
        let headerFrame = vw_TblBK.frame.size
        let theImageView = UIImageView(frame: CGRect(x: headerFrame.width - 35, y: 15, width: 15, height: 15));
        let imgAdd = UIImage(named: "icn_plus_b")
        
        theImageView.image = imgAdd
        theImageView.tag = kHeaderSectionTag + section
        
        
        let sectionData = self.sectionItems[section] as! NSArray
  
        header.addSubview(theImageView)
        
        print(sectionData)
        
        let lbl_Total_Scratch = UILabel()
        let str_Title = String(sectionData.count)
        lbl_Total_Scratch.frame = CGRect(x: theImageView.frame.origin.x - 120, y: 0, width: 120,height: header.frame.height)
        lbl_Total_Scratch.font = UIFont(name: "HelveticaNeue-Medium", size: 14.0)!
        lbl_Total_Scratch.textColor = UIColor.black
        lbl_Total_Scratch.textAlignment = .left
        
       // if section == 0 {
            lbl_Total_Scratch.text = String(Constant.GlobalConstants.str_ScratchesPerBlogShared)+" Scratches"
       /// }else {
         //   lbl_Total_Scratch.text = String(Constant.GlobalConstants.str_ScratchesPerTestimonialShared)+" Scratches"
//}
        
        
        header.addSubview(lbl_Total_Scratch)
      
        
        
        
        // make headers touchable
        header.tag = section
        let headerTapGesture = UITapGestureRecognizer()
        headerTapGesture.addTarget(self, action: #selector(VDG_Share_ViewController.sectionHeaderWasTouched(_:)))
        header.addGestureRecognizer(headerTapGesture)
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as UITableViewCell
        let section = self.sectionItems[indexPath.section] as! NSArray
     
        let lbl_Detail = cell.viewWithTag(11) as! UILabel
        lbl_Detail.textColor = UIColor.darkGray
        lbl_Detail.text = section[indexPath.row] as? String
        lbl_Detail.font = UIFont(name: "Helvetica", size: 14.0)!
        
        let btn_Share = cell.viewWithTag(200) as! UIButton
        btn_Share.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
       
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Expand / Collapse Methods
    
    @objc func sectionHeaderWasTouched(_ sender: UITapGestureRecognizer) {
        
        
        let headerView = sender.view as! UITableViewHeaderFooterView
        let section    = headerView.tag
        let eImageView = headerView.viewWithTag(kHeaderSectionTag + section) as? UIImageView
     
        if section == 0 {
            isBlogShare = true
        }else{
            isBlogShare = false
        }
     
        if (self.expandedSectionHeaderNumber == -1) {
            self.expandedSectionHeaderNumber = section
           let imgAdd = UIImage(named: "icn_minus_b")
            eImageView?.image = imgAdd
            tableViewExpandSection(section, imageView: eImageView!)
        } else {
            if (self.expandedSectionHeaderNumber == section) {
                 let imgAdd = UIImage(named: "icn_plus_b")
                
                eImageView?.image = imgAdd
                
                tableViewCollapeSection(section, imageView: eImageView!)
                
            } else {
                
                let cImageView = self.view.viewWithTag(kHeaderSectionTag + self.expandedSectionHeaderNumber) as? UIImageView
                tableViewCollapeSection(self.expandedSectionHeaderNumber, imageView: cImageView!)
                tableViewExpandSection(section, imageView: eImageView!)
                
            }
        }
    }
    
    func tableViewCollapeSection(_ section: Int, imageView: UIImageView) {
        let sectionData = self.sectionItems[section] as! NSArray
        
        self.expandedSectionHeaderNumber = -1;
        if (sectionData.count == 0) {
            return;
        } else {
            
            
            UIView.animate(withDuration: 0.4, animations: {
                imageView.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
            })
            var indexesPath = [IndexPath]()
            for i in 0 ..< sectionData.count {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            self.tableView!.beginUpdates()
            self.tableView!.deleteRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.tableView!.endUpdates()
            
            
        }
    }
    
    func tableViewExpandSection(_ section: Int, imageView: UIImageView) {
        let sectionData = self.sectionItems[section] as! NSArray
        
        if (sectionData.count == 0) {
            self.expandedSectionHeaderNumber = -1;
            return;
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                imageView.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
            })
            var indexesPath = [IndexPath]()
            for i in 0 ..< sectionData.count {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            self.expandedSectionHeaderNumber = section
            self.tableView!.beginUpdates()
            self.tableView!.insertRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.tableView!.endUpdates()
        }
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
