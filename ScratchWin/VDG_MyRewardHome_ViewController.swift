//
//  VDG_MyRewardHome_ViewController.swift
//  VeriDocG
//
//  Created by Bhavdip Patel on 10/10/18.
//  Copyright © 2018 SevenBits. All rights reserved.
//

import UIKit

import HGCircularSlider
import GradientProgressBar

import SwiftKeychainWrapper
import Firebase
import FirebaseAuth
import FirebaseDatabase
import PKHUD

import NVActivityIndicatorView
import AMPopTip
import Toast_Swift



class VDG_MyRewardHome_ViewController: UIViewController, FSPagerViewDataSource, FSPagerViewDelegate, UIScrollViewDelegate {


    @IBOutlet var vw_HorizontalProgress: UIView!
    @IBOutlet var vw_PrizeBox: UIView!
    @IBOutlet var vw_VerticalProgress: UIView!
    @IBOutlet var VerticalProgress: UIView!
   
    @IBOutlet var btn_RemainTS: UIButton!
    @IBOutlet var lbl_Level : UILabel!
    @IBOutlet var btn_Close : UIButton!
    @IBOutlet var btn_Help : UIButton!
    @IBOutlet var vw_BK_Token : UIView!
    @IBOutlet var vw_BK_Prizes : UIView!
    @IBOutlet var vw_BK_Segment : UIView!
    @IBOutlet var btn_Invite : UIButton!
    @IBOutlet var btn_Share : UIButton!
    @IBOutlet var btn_Token : UIButton!
    @IBOutlet var btn_RedeemBox : UIButton!
    @IBOutlet var btn_Prize : UIButton!
    @IBOutlet var segment_Rewards: UISegmentedControl!
    @IBOutlet var progress_BM: MBCircularProgressBarView!
    @IBOutlet var progress_BM_Gray: MBCircularProgressBarViewGray!
    @IBOutlet weak var progressView: GradientProgressBar!
    @IBOutlet weak  var progressCircular: KDCircularProgress!
    @IBOutlet var lbl_PendingProgree : UILabel!
    @IBOutlet weak var circularSlider: CircularSlider!
    @IBOutlet weak var circularSliderBORDER: CircularSlider!
    @IBOutlet weak var circularSliderPending: CircularSlider!
    @IBOutlet weak var lbl_Points: UILabel!
    
    //var testSlider1:SummerSlider!
   
    @IBOutlet weak var TokenProgress: GradientProgressBar!
    var arr_PrizeList = [[String:AnyObject]]()
    var numberofcurrentLevel: Int = 0
    var fb_totalwintoken: Int = 0
    var fb_totalusedToken: Int = 0
    var lbl_Level1 : UILabel!
     var lbl_Level0 : UILabel!
    var lbl_Level60 : UILabel!
    var window: UIWindow?
    let cellPercentWidth: CGFloat = 0.9
   
    var img_ScreenShot: UIImage!
    var str_Remain: String!
    var lbl_NumberOfReedem : UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    let popTip1 = PopTip()
    
    
    
    //
    fileprivate let imageNames = ["prize_3_coin.png"]
 
    fileprivate let transformerTypes: [FSPagerViewTransformerType] = [.linear]
    
    fileprivate var typeIndex = 0 {
        didSet {
            let type = self.transformerTypes[typeIndex]
            self.pagerView.transformer = FSPagerViewTransformer(type:type)
            switch type {
            case .crossFading, .zoomOut, .depth:
                self.pagerView.itemSize = FSPagerView.automaticSize
                self.pagerView.decelerationDistance = 1
            case .linear, .overlap:
                let transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.pagerView.itemSize = self.pagerView.frame.size.applying(transform)
                self.pagerView.decelerationDistance = FSPagerView.automaticDistance
            case .ferrisWheel, .invertedFerrisWheel:
                self.pagerView.itemSize = CGSize(width: 180, height: 140)
                self.pagerView.decelerationDistance = FSPagerView.automaticDistance
            case .coverFlow:
                self.pagerView.itemSize = CGSize(width: 220, height: 170)
                self.pagerView.decelerationDistance = FSPagerView.automaticDistance
            case .cubic:
                let transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                self.pagerView.itemSize = self.pagerView.frame.size.applying(transform)
                self.pagerView.decelerationDistance = 1
            }
        }
    }
    
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            self.pagerView.delegate = self
            self.pagerView.dataSource = self
            self.typeIndex = 0
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let index = self.typeIndex
        self.typeIndex = index // Manually trigger didSet
    }
    
    // MARK:- FSPagerViewDataSource
    
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return imageNames.count
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.image = UIImage(named: self.imageNames[index])
        cell.imageView?.contentMode = .scaleAspectFit
        cell.imageView?.clipsToBounds = true
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
    }
  
    
    @IBOutlet weak var pageControl: FSPageControl! {
        didSet {
            self.pageControl.numberOfPages = self.imageNames.count
            self.pageControl.contentHorizontalAlignment = .center
            self.pageControl.contentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            self.pageControl.hidesForSinglePage = true
           
            self.pageControl.setImage(UIImage(named:"icn_s_gray"), for: .normal)
            self.pageControl.setImage(UIImage(named:"icn_s_green"), for: .selected)
            
            
            self.pageControl.itemSpacing = 17.0
            self.pageControl.interitemSpacing = 17.0
            
            self.pageControl.backgroundColor = UIColor.clear
        }
    }
    
    // MARK:- FSPagerViewDelegate
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        self.pageControl.currentPage = targetIndex
    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        //createParticles()
        UserDefaults.standard.set("2", forKey: "tooltipmyrewards")
        UserDefaults.standard.synchronize()
        
        get_Scratches_Info()
        
        img_ScreenShot = self.takeScreenshot(false)
        
       
        
       
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true


        
        btn_RedeemBox.isUserInteractionEnabled = false
      

        
        circularSlider.maximumValue = 100
        circularSliderBORDER.maximumValue = 100
        
        let DeviceType = UIScreen.main.nativeBounds.height
        
        if DeviceType == 1136 {
            
            circularSliderPending.minimumValue = 1
            circularSlider.minimumValue = 1
            circularSliderBORDER.minimumValue = 1
            
            circularSliderPending.maximumValue = 120
            circularSlider.maximumValue = 120
            circularSliderBORDER.maximumValue = 120
            
        }else {
            
            circularSliderPending.minimumValue = 1
            circularSlider.minimumValue = 1
            circularSliderBORDER.minimumValue = 1
            
            circularSliderPending.maximumValue = 126
            circularSlider.maximumValue = 119
            circularSliderBORDER.maximumValue = 119
            
        }
        

        circularSliderPending.numberOfRounds = 1
        circularSlider.numberOfRounds = 1
        circularSliderBORDER.numberOfRounds = 1
        
        circularSliderPending.endPointValue = 0
        circularSlider.endPointValue = 0
        circularSliderBORDER.endPointValue = 100
    
        
               
        circularSlider.isUserInteractionEnabled = false
        circularSliderBORDER.isUserInteractionEnabled = false
        circularSliderPending.isUserInteractionEnabled = false

       

        // Modify the collectionView's decelerationRate (REQURED)
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        
        // Make the example pretty ✨
        //vw_BK_Prizes.applyGradient()
        
        // Assign delegate and data source
        collectionView.delegate = self
        collectionView.dataSource = self
        
       
        
        vw_BK_Prizes.isHidden = true
        vw_BK_Token.isHidden = false
        
        
        

        arr_PrizeList.append(["PrizeTitle" : "T-Shirt" as AnyObject,"PrizeType" : "2" as AnyObject, "PrizeDesc" : "test description" as AnyObject])
        arr_PrizeList.append(["PrizeTitle" : "Pen" as AnyObject,"PrizeType" : "3" as AnyObject, "PrizeDesc" : "test description" as AnyObject])
        arr_PrizeList.append(["PrizeTitle" : "VDG Token" as AnyObject,"PrizeType" : "1" as AnyObject, "PrizeDesc" : "test description" as AnyObject])
    

        
        lbl_NumberOfReedem = UILabel(frame: CGRect(x: btn_RedeemBox.frame.width+1, y: -11, width: 22, height: 22))
        lbl_NumberOfReedem.textAlignment = .center
        lbl_NumberOfReedem.textColor = UIColor.white
        lbl_NumberOfReedem.backgroundColor = Constant.GlobalConstants.kColor_Theme
        lbl_NumberOfReedem.layer.cornerRadius = lbl_NumberOfReedem.frame.width/2
        lbl_NumberOfReedem.clipsToBounds = true
        btn_RedeemBox.addSubview(lbl_NumberOfReedem)
        
        lbl_NumberOfReedem.isHidden = true
        
        btn_RedeemBox.isHidden = true
        
        collectionView.register(UINib.init(nibName: "Prize_TShirt_Cell", bundle: nil), forCellWithReuseIdentifier: "Prize_TShirt_Cell")
        collectionView.register(UINib.init(nibName: "Prize_Tokens_Cell", bundle: nil), forCellWithReuseIdentifier: "Prize_Tokens_Cell")
        collectionView.register(UINib.init(nibName: "Prize_Pen_Cell", bundle: nil), forCellWithReuseIdentifier: "Prize_Pen_Cell")
        

    
   
        
        btn_RemainTS.backgroundColor = UIColor.white
        btn_RemainTS.addShadow()
        
        
        self.circularSliderPending.endPointValue = CGFloat(1)
        self.circularSlider.endPointValue = CGFloat(1)
        self.circularSliderBORDER.endPointValue = 100
        progress_BM.value = 1.0
        
        TokenProgress.gradientColors = [#colorLiteral(red: 0.003921568627, green: 0.4, blue: 0.2156862745, alpha: 1).cgColor, #colorLiteral(red: 0.4901960784, green: 0.7019607843, blue: 0.2392156863, alpha: 1).cgColor]
  
    }
    
    func OpenLevel2Dialogue() {
        
        self.navigationController?.navigationBar.isHidden = true
        
        UserDefaults.standard.set(true, forKey: "detectLevelupScreen")
        UserDefaults.standard.synchronize()
        
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Finished_LevelUp_ViewController") as! VDG_Finished_LevelUp_ViewController
        secondViewController.img_ScreenShot = img_ScreenShot
        secondViewController.restorationIdentifier = "VDG_Finished_LevelUp_ViewControllerBack"
        self.navigationController?.present(secondViewController, animated: true, completion: nil)
        
    }
    
    func randomColor() -> UIColor{
        return UIColor(red: CGFloat(drand48()),
                       green: CGFloat(drand48()),
                       blue: CGFloat(drand48()),
                       alpha: 1.0)
        
    }
    
    //function which is triggered when handleTap is called
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
         Histroy()
    }
    func Histroy() {
        
        let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "VDG_ScratchHistory_ViewController") as! VDG_ScratchHistory_ViewController
        VC1.str_Remain = str_Remain
        self.navigationController?.pushViewController(VC1, animated: true)
        
    }
    func setLevelLabel(){
        
        let DeviceType = UIScreen.main.nativeBounds.height
        
        var X_L = 0.0
        var Y_L = 0.0
        
        X_L = Double(Double((circularSlider.frame.width/2)) - 39.5)
        Y_L = Double(circularSlider.frame.height - 46.00)
        

        
        if lbl_Level1 != nil {
            lbl_Level1.removeFromSuperview()
        }
        
        lbl_Level1 = UILabel(frame: CGRect(x: X_L, y: Y_L, width: 75, height: 42))
        
        lbl_Level1.textAlignment = .center
        
        
        lbl_Level1.font = UIFont.systemFont(ofSize: 13.0)
        lbl_Level1.backgroundColor = UIColor.black
        lbl_Level1.numberOfLines = 4
        lbl_Level1.textColor = UIColor.white
        circularSliderPending.addSubview(lbl_Level1)
        
        
        lbl_Level1.layer.cornerRadius = 20
        lbl_Level1.clipsToBounds = true
        
       // numberofcurrentLevel
       // if numberofcurrentLevel == 1 {
       //     lbl_Level1.text = "Level " + String(numberofcurrentLevel)
      //  }
        lbl_Level1.text = "Scratch\nTracker"
        
        
        
        if lbl_Level0 != nil {
            lbl_Level0.removeFromSuperview()
        }
        lbl_Level0 = UILabel(frame: CGRect(x: lbl_Level1.frame.origin.x - 34, y: lbl_Level1.frame.origin.y + 13, width: 20, height: 20))
        
        lbl_Level0.textAlignment = .center
        circularSliderPending.addSubview(lbl_Level0)
        lbl_Level0.text = "0"
        lbl_Level0.font = UIFont.systemFont(ofSize: 17.0)
        //lbl_Level1.backgroundColor = UIColor.black
        lbl_Level0.numberOfLines = 1
        lbl_Level0.textColor = UIColor.black
        
        
        
        if lbl_Level60 != nil {
            lbl_Level60.removeFromSuperview()
        }
        lbl_Level60 = UILabel(frame: CGRect(x: lbl_Level1.frame.origin.x + lbl_Level1.frame.size.width + 7, y: lbl_Level1.frame.origin.y + 15, width: 30, height: 20))
        
        lbl_Level60.textAlignment = .center
        circularSliderPending.addSubview(lbl_Level60)
        lbl_Level60.text = String(Constant.GlobalConstants.str_scratch_FirstLevel)
        lbl_Level60.font = UIFont.systemFont(ofSize: 17.0)
        //lbl_Level1.backgroundColor = UIColor.black
        lbl_Level60.numberOfLines = 1
        lbl_Level60.textColor = UIColor.black
        
    }
    
    @objc func updateTexts(str_Finished: Int) {
        
    
    
        //let finished_Token = str_Finished
        
//let PendingToken =  Int(Constant.GlobalConstants.str_TotalScratchesPerLevel) - finished_Token

        let strFinal = String(str_Finished)
        
       
        let DeviceType = UIScreen.main.nativeBounds.height
        var  attrString = ""
        if DeviceType == 1136 {
            attrString = "<html><center><font size='18' color='rgb(38,150,77)' face='Helvetica Neue'><b> \(strFinal) % </b> </font> <br> <font size='3' color='rgb(38,150,77)' face='Helvetica Neue'> Until Level Up </font> </center></html>"
        }else  {
            attrString = "<html><center><font size='24' color='rgb(38,150,77)' face='Helvetica Neue'><b> \(strFinal) % </b> </font> <br> <font size='5' color='rgb(38,150,77)' face='Helvetica Neue'> Until Level Up </font> </center></html>"
        }
        
        
        
        // works even without <html><body> </body></html> tags, BTW
        let data = attrString.data(using: String.Encoding.unicode)! // mind "!"
        let attrStr = try? NSAttributedString( // do catch
            data: data,
            options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        // suppose we have an UILabel, but any element with NSAttributedString will do
        
        lbl_PendingProgree.text = strFinal
        
        if str_Finished >= 2 {
            lbl_Points.text = "Points"
        }else {
            lbl_Points.text = "Point"
        }
        
       // circularSliderPending.endThumbImage = textToImage(drawText: str_Finished as NSString , inImage: UIImage(named: "icn_PendingProgress")!, atPoint: CGPoint(x: 11, y: 18))
    }
    
    
    
  
    
    
    @IBAction func actionSegmentAction(sender:UISegmentedControl) {
       
        switch sender.selectedSegmentIndex {
        
        case 0:
            self.lbl_NumberOfReedem.isHidden = true
             vw_BK_Token.isHidden = false
             vw_BK_Prizes.isHidden = true
             self.btn_RedeemBox.isUserInteractionEnabled = true
             self.btn_RedeemBox.setBackgroundImage(UIImage(named: "icn_disable_redeebox"), for: .normal)
            vw_HorizontalProgress.isHidden = false
            vw_PrizeBox.isHidden = false
            
            
            if fb_totalwintoken >= Constant.GlobalConstants.str_TotalTokenPerRedeem {
                self.btn_RedeemBox.isUserInteractionEnabled = true
                self.btn_RedeemBox.setBackgroundImage(UIImage(named: "icn_enable_redeebox"), for: .normal)
                
                
            }else {
                
                self.btn_RedeemBox.isUserInteractionEnabled = true
                self.btn_RedeemBox.setBackgroundImage(UIImage(named: "icn_disable_redeebox"), for: .normal)
                
                
            }
            
        case 1:
            self.lbl_NumberOfReedem.isHidden = false
            vw_BK_Token.isHidden = true
            vw_BK_Prizes.isHidden = false
            
            vw_HorizontalProgress.isHidden = true
            vw_PrizeBox.isHidden = true
          
            self.lbl_NumberOfReedem.text = String(self.arr_PrizeList.count)
            
            if self.arr_PrizeList.count >= Constant.GlobalConstants.TotalPrizePerRedeemBox {
                
                self.lbl_NumberOfReedem.textColor = UIColor.white
                self.lbl_NumberOfReedem.backgroundColor = Constant.GlobalConstants.kColor_Theme
                
                self.btn_RedeemBox.isUserInteractionEnabled = true
                self.btn_RedeemBox.setBackgroundImage(UIImage(named: "icn_enable_redeebox"), for: .normal)
                
            }else {
                
                self.lbl_NumberOfReedem.textColor = UIColor.darkGray
                self.lbl_NumberOfReedem.backgroundColor = UIColor.lightGray
                
                self.btn_RedeemBox.isUserInteractionEnabled = true
                self.btn_RedeemBox.setBackgroundImage(UIImage(named: "icn_disable_redeebox"), for: .normal)
                
            }
            
        default:
            vw_BK_Token.isHidden = false
            vw_BK_Prizes.isHidden = false
        }
    }
    
    
    @IBAction func btn_Close(_ sender: UIButton) {
       //  _ = navigationController?.popViewController(animated: false)
        if Connectivity.isConnectedToInternet {
            kConstantObj.SetIntialMainViewController("VDG_ScratchWinHome_ViewController")
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
        
   
             secondViewController.str_Descptn = "- The “Scratch Tracker” gauge contains the number of times you have scratched so far.\n\n- The reading in the middle of gauge contains your winning points till date.\n\n- The horizontal progress bar tracks how many more points you will need before you level up.\n\n- We are also giving away VeriDoc Global Merchandise, so keep scratching for your chance to win!"
      
        
       
        self.present(secondViewController, animated: true)
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
    
    @IBAction func btn_Prize(_ sender: UIButton) {
        
    }
    @IBAction func btn_Token(_ sender: UIButton) {
        
    }
    
    @IBAction func btn_RedeemBox(_ sender: UIButton) {
        
        // immediately hides all toast views in self.view
        self.view.hideAllToasts()
        
        if self.fb_totalwintoken >= Constant.GlobalConstants.str_TotalTokenPerRedeem  {
            
            print(fb_totalusedToken)
            if fb_totalusedToken >= Constant.GlobalConstants.str_scratch_FirstLevel {
         
                // toast with a specific duration and position
                self.view.makeToast("Please update our new version to redeem tokens.", duration: 3.0, position: .bottom)
           
            }else {
                
                // Toast(text: "").show()
                self.view.makeToast("You can radeem your VDG token after completing \(Constant.GlobalConstants.str_scratch_FirstLevel) Scratches.", duration: 3.0, position: .bottom)
            }
            
        }else {
            
            let penidngToken = Constant.GlobalConstants.str_TotalTokenPerRedeem - fb_totalwintoken
            
           // Toast(text: "").show()
            
             self.view.makeToast("You can redeem your VDG token after earning \(penidngToken) more Points.", duration: 3.0, position: .bottom)
        }
        

            
   
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
    
    func get_Scratches_Info() {
        
       
        
        var ref = Database.database().reference() // undeclared
        
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        
        let userID = userDetail!["customerguid"] as! String
        
        let str_Date = UserDefaults.standard.object(forKey: "C_D") as! String
        
        //HUD.show(.progress)
        //HUD.show(HUDContentType.rotatingImage(UIImage(named: "icn_spinner")))
        
        // Add Activity Indicatore
        let vw_Load_BK = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        vw_Load_BK.backgroundColor = UIColor.black
        vw_Load_BK.alpha = 0.3
        self.view.addSubview(vw_Load_BK)
        let frame = CGRect(x: (self.view.frame.width/2)-30, y: (self.view.frame.height/2)-30, width: 60, height: 60)
        let activityIndicatorView = NVActivityIndicatorView(frame: frame,
                                                            type: NVActivityIndicatorType.ballScale)
        
        activityIndicatorView.color = UIColor.darkGray
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        
        vw_BK_Token.isHidden = true
        vw_BK_Prizes.isHidden = true
        
        
        
        ref = Database.database().reference().child("Scratch&Win").child(userID).child(userID+"-Scratch&Win")
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            PKHUD.sharedHUD.hide()
            // remove Indicator
            activityIndicatorView.stopAnimating()
            activityIndicatorView.removeFromSuperview()
            vw_Load_BK.removeFromSuperview()
            self.vw_BK_Token.isHidden = false
            self.vw_BK_Prizes.isHidden = true
            if snapshot.exists() {
                
                print(snapshot.value as Any)
                let dic_Info = snapshot.value as! NSDictionary
                
                
                self.numberofcurrentLevel = dic_Info["current_level"] as! Int
                
                let str_Tmp = dic_Info["today_date"] as! String
                
                print(str_Tmp)
                
               // var TotalWin_Scratch = Int()
             
                self.str_Remain =  String(dic_Info["remaining_level_scratch"] as! Int)
                let str_Scratch = String(dic_Info["remaining_level_scratch"] as! Int) + " scratches remaining"
                
                self.btn_RemainTS.setTitle(str_Scratch, for: .normal)
                
                if (dic_Info["remaining_level_scratch"] as! Int) >= 2 {
                    self.btn_RemainTS.setTitle(String(dic_Info["remaining_level_scratch"] as! Int) + " scratches remaining", for: .normal)
                }else {
                    self.btn_RemainTS.setTitle(String(dic_Info["remaining_level_scratch"] as! Int) + " scratch remaining", for: .normal)
                }
             
                let Total_remaining_level_scratch = dic_Info["remaining_level_scratch"] as! Int
                let total_level_scratch = dic_Info["total_level_scratch"] as! Int
                let total_used_scratch = dic_Info["total_used_scratch"] as! Int
                self.fb_totalusedToken = total_used_scratch
                
                if total_used_scratch >= Constant.GlobalConstants.str_scratch_FirstLevel {
                    
                    let isShow = UserDefaults.standard.bool(forKey: "detectLevelupScreen")
                    
                    if isShow == false {
                        self.OpenLevel2Dialogue()
                    }
                    
                }else {
                      UserDefaults.standard.set(false, forKey: "detectLevelupScreen")
                      UserDefaults.standard.synchronize()
                }
                
                
                
                
                var perCent = (Float(total_level_scratch - Total_remaining_level_scratch) * 100.00) / Float(Constant.GlobalConstants.str_scratch_FirstLevel)
              
                
            
                
                
                self.progress_BM.isHidden = false
                if perCent <= 1.0  {
                    perCent  =  1.0
                    
                    
                }else if perCent >= 100.00 {
                    perCent = 100.00
               
                    
                     self.progress_BM_Gray.progressColor = UIColor.init(red: (255.0/255.0), green: (195.0/255.0), blue: (43.0/255.0), alpha: 1.0)
                    
                    self.progress_BM.isHidden = true
                    
                }
                
       
                UIView.animate(withDuration: 0.2, animations: {
                    
                    self.circularSliderPending.endPointValue = CGFloat(perCent)
                    self.progress_BM.value = CGFloat(perCent)
                    self.circularSlider.endPointValue = CGFloat(perCent)
                    self.circularSliderBORDER.endPointValue = 100
            
                })
            
        
                self.updateTexts(str_Finished: dic_Info["totalWinningAmount"] as! Int)
                
                
                 let TotalWinningAmount = dic_Info["totalWinningAmount"] as! Int
                self.fb_totalwintoken = TotalWinningAmount
                
               
                
                var perVertical = Float(TotalWinningAmount) / Float(Constant.GlobalConstants.str_TotalTokenPerRedeem)
                
                //perVertical = perVertical
            
                //self.testSlider1.value = Float(perVertical)
                
                self.TokenProgress.progress = Float(perVertical)
                
              

                
               //  self.TokenProgress.updateGradientLayerTemp(progress: CGFloat(Float(perVertical)))
                let newTmp = self.TokenProgress.sizeByPercentageTemp(originalRect: self.TokenProgress.frame, width: CGFloat(Float(perVertical)))
                
                print(newTmp)
                
                
              //  self.setLevelLabel()
                
                switch self.segment_Rewards.selectedSegmentIndex {
                    
                case 0:
                    self.lbl_NumberOfReedem.isHidden = true
                    
                    if TotalWinningAmount >= Constant.GlobalConstants.str_TotalTokenPerRedeem {
                        self.btn_RedeemBox.isUserInteractionEnabled = true
                        self.btn_RedeemBox.setBackgroundImage(UIImage(named: "icn_enable_redeebox"), for: .normal)

                    }else {
                        
                        self.btn_RedeemBox.isUserInteractionEnabled = true
                        self.btn_RedeemBox.setBackgroundImage(UIImage(named: "icn_disable_redeebox"), for: .normal)
                    }
                case 1:
                    
                    self.lbl_NumberOfReedem.isHidden = false
                    self.vw_BK_Token.isHidden = true
                    self.vw_BK_Prizes.isHidden = false
                    self.btn_RedeemBox.isUserInteractionEnabled = true
                    self.btn_RedeemBox.setBackgroundImage(UIImage(named: "icn_enable_redeebox"), for: .normal)
                    
                    self.lbl_NumberOfReedem.text = String(self.arr_PrizeList.count)
                    
                    if self.arr_PrizeList.count >= Constant.GlobalConstants.TotalPrizePerRedeemBox {
                         self.btn_RedeemBox.isUserInteractionEnabled = true
                        self.lbl_NumberOfReedem.textColor = UIColor.white
                        self.lbl_NumberOfReedem.backgroundColor = Constant.GlobalConstants.kColor_Theme
                    }else {
                        self.btn_RedeemBox.isUserInteractionEnabled = true
                        self.lbl_NumberOfReedem.textColor = UIColor.darkGray
                        self.lbl_NumberOfReedem.backgroundColor = UIColor.lightGray
                    }
                    
                default:
                    self.vw_BK_Token.isHidden = false
                    self.vw_BK_Prizes.isHidden = false
                }
                
                
              
                 let penidngToken = Constant.GlobalConstants.str_TotalTokenPerRedeem - self.fb_totalwintoken
        
                if penidngToken > 0 {
                    
                    self.popTip1.font = UIFont(name: "Avenir-Medium", size: 10)!
                    self.popTip1.textColor = UIColor.white
                    self.popTip1.shouldDismissOnTap = false
                    self.popTip1.shouldDismissOnTapOutside = false
                    self.popTip1.shouldDismissOnSwipeOutside = false
                    self.popTip1.edgeMargin = 2
                    self.popTip1.offset = 2
                    self.popTip1.bubbleOffset = 0
                    self.popTip1.edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    //self.popTip1.actionAnimation = .bounce(10)
                    
                    self.popTip1.bubbleColor = UIColor.black
                   
                    let tmpRect  = CGRect(x: newTmp.origin.x, y: newTmp.origin.y, width: newTmp.width*2, height: newTmp.height)
                    
                    
                    if penidngToken >= 2 {
                       self.popTip1.show(text: "\(penidngToken) Points\nmore to go.", direction: .down, maxWidth: 140, in: self.vw_VerticalProgress, from: tmpRect)
                    }else {
                        self.popTip1.show(text: "\(penidngToken) Point\nmore to go.", direction: .down, maxWidth: 140, in: self.vw_VerticalProgress, from: tmpRect)
                    }
                    
                    
                }
               
               
            }
            
        })
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    // MARK: - Swipe Delegate method
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension VDG_MyRewardHome_ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected Cell #\(indexPath.row)")
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let total = scrollView.contentSize.width - scrollView.bounds.width
//        let offset = scrollView.contentOffset.x
//        let percent = Double(offset / total)
//
//        let progress = percent * Double(arr_PrizeList.count - 1)
//
//        (self.pageControls).forEach { (control) in
//            control.progress = progress
//        }
//    }
}

extension VDG_MyRewardHome_ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arr_PrizeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let dic_Info = arr_PrizeList[indexPath.row]
        
        let str_Type = dic_Info["PrizeType"] as! String
        
        if str_Type == "1" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Prize_TShirt_Cell", for: indexPath) as! Prize_TShirt_Cell
            
            cell.img_BK.layer.cornerRadius = 8
            cell.img_BK.clipsToBounds = true
            
           
            cell.vw_BK.addShadowOnView()
            
            return cell
        }else if str_Type == "2" {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Prize_Tokens_Cell", for: indexPath) as! Prize_Tokens_Cell
            
            cell.img_BK.layer.cornerRadius = 8
            cell.img_BK.clipsToBounds = true
           
            cell.vw_BK.addShadowOnView()
          
            
            return cell
            
            
        }else  {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Prize_Pen_Cell", for: indexPath) as! Prize_Pen_Cell
            cell.img_BK.layer.cornerRadius = 8
            cell.img_BK.clipsToBounds = true
            
            
            cell.vw_BK.addShadowOnView()
            return cell
            
            
        }
        
        
     
 
        
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
//    }
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        print("Current centered index: \(String(describing: centeredCollectionViewFlowLayout.currentCenteredPage ?? nil))")
//    }
//
//    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        print("Current centered index: \(String(describing: centeredCollectionViewFlowLayout.currentCenteredPage ?? nil))")
//    }
}
