//
//  VDG_Suggestion_ViewController.swift
//  VeriDocG
//
//  Created by Bhavdip Patel on 28/11/18.
//  Copyright © 2018 SevenBits. All rights reserved.


import UIKit
import SwiftKeychainWrapper
import PKHUD


class VDG_Suggestion_ViewController: UIViewController, UIScrollViewDelegate {

    var window: UIWindow?
    
    @IBOutlet weak var ScrollV: UIScrollView!{
        didSet{
            ScrollV.delegate = self
        }
    }
    @IBOutlet weak var pageC: UIPageControl!
    @IBOutlet var img_BK: UIImageView!
    @IBOutlet var btn_Relogin: UIButton!
    @IBOutlet var lbl_Name: UILabel!
    @IBOutlet var txt_Help: UITextView!
    @IBOutlet var vw_BK: UIView!
    
    var img_ScreenShot: UIImage!
    
    var slides:[Slide] = [];
    
    override func viewDidAppear(_ animated: Bool) {
        
        
      
        
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        
        pageC.numberOfPages = slides.count
        pageC.currentPage = 0
        vw_BK.bringSubview(toFront: pageC)
        ScrollV.isDirectionalLockEnabled = true
        
        vw_BK.layer.cornerRadius = 8
        vw_BK.clipsToBounds = true
        vw_BK.layer.borderColor = UIColor.lightGray.cgColor
        vw_BK.layer.borderWidth = 0.5
        
       
    
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

      img_BK.image = img_ScreenShot
        
//     txt_Help.text = "- Your App has new feature. Please read below to  learn how it works.        \n        \n- Now your VDG App allows you to login to your web account using a QR scanner.        \n        \n- Using the new smart login feature, you have now access to controlling login functionality of your web account.        \n       \n- To get started, please click the button below to re-login to your account.       \n"
//        
//        
//        
//        // Do any additional setup after loading the view.
//        
//        
//        btn_Relogin.layer.cornerRadius = 8
//        
//        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
//        
//        lbl_Name.text = "Hello \(userDetail!["firstname"] as! String)"
//        
//        btn_Relogin.applyGradientButton()
        
    }
    
    func createSlides() -> [Slide] {
        
        
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
    
        
        let slide1:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
      
        slide1.lbl_Title.text = "Hello \(userDetail!["firstname"] as! String)"
        slide1.lbl_Title.textColor = Constant.GlobalConstants.kColor_Theme
        slide1.lbl_Desc.text = "Notice something different? We’ve added new features to your App! Swipe across to learn more about how it works."
        slide1.lbl_Desc.font = slide1.lbl_Desc.font.withSize(23)
        
        slide1.btn_Relogin.isHidden = true
        
        let slide2:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
      
        slide2.lbl_Title.text = "Smart Login"
        slide2.lbl_Title.textColor = Constant.GlobalConstants.kColor_Theme
        slide2.lbl_Desc.font = slide2.lbl_Desc.font.withSize(16)
        slide2.lbl_Desc.text = "Your App now comes with a Smart Login feature that will allow you to be in full control of your account, from wherever you are! \n The Smart Login feature is optional and can also be used as your 2 Factor Authentication when logging in to your web account. By using the Smart Login QR Scanner, you can force log out of your web session from this app whenever required. \n Swipe across to check it out!"
        slide2.btn_Relogin.isHidden = true
        
        
        let slide3:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide3.lbl_Title.textColor = Constant.GlobalConstants.kColor_Theme
        slide3.lbl_Title.text = "Getting Started"
        slide3.lbl_Desc.font = slide3.lbl_Desc.font.withSize(19)
        slide3.lbl_Desc.text = " Let’s get you started. Follow these two steps to re-login and authenticate your account  using One-Time Password (OTP) Authentication which will then enable you to securely sign in using Smart Login QR Scanner.\n \n Tap below to get started!"
        slide3.btn_Relogin.isHidden = false
        slide3.btn_Relogin.layer.cornerRadius = 8
        slide3.btn_Relogin.clipsToBounds = true
        slide3.btn_Relogin.addTarget(self, action:#selector(self.btn_GotoBack1), for: .touchUpInside)
        
        let color1 = UIColor(red: 37.0/255.0, green: 152.0/255.0, blue: 77.0/255.0, alpha: 1.0)
        let color2 = UIColor(red: 94.0/255.0, green: 177.0/255.0, blue: 71.0/255.0, alpha: 1.0)
        let color3 = UIColor(red: 94.0/255.0, green: 177.0/255.0, blue: 71.0/255.0, alpha: 1.0)
        
        slide3.btn_Relogin.applyGradient(colours: [color3,color2,color1])
      
        return [slide1, slide2, slide3]
    }
    
    @objc func btn_GotoBack1() {
        // kConstantObj.SetIntialMainViewController("PageViewController")
       // self.dismiss(animated: false, completion: nil)
        UserDefaults.standard.set(Bool(false), forKey:"isLogin")
        UserDefaults.standard.set(Bool(false), forKey:"isSmartLogin")
        UserDefaults.standard.set(Bool(false), forKey:"isMobileVerified")
        UserDefaults.standard.synchronize()
        
        let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: ConstantsModel.KeyDefaultUser.userData)
        
        print("Remove was successful: \(removeSuccessful)")
        
        let mainVcIntial = kConstantObj.SetIntialMainViewController("VDG_Auth_ViewController")
        self.window?.rootViewController = mainVcIntial
        
        self.dismiss(animated: false, completion: nil )
        
        
    }
    func setupSlideScrollView(slides : [Slide]) {
        
        ScrollV.frame = CGRect(x: 0, y: 0, width: vw_BK.frame.width, height: vw_BK.frame.height)
        ScrollV.contentSize = CGSize(width: vw_BK.frame.width * CGFloat(slides.count), height: vw_BK.frame.height)
        ScrollV.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: vw_BK.frame.width * CGFloat(i), y: 0, width: vw_BK.frame.width, height: vw_BK.frame.height)
            ScrollV.addSubview(slides[i])
        }
    }
    

    /*
     * default function called when view is scolled. In order to enable callback
     * when scrollview is scrolled, the below code needs to be called:
     * slideScrollView.delegate = self or
     */
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y>0 {
            scrollView.contentOffset.y = 0
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        
        pageC.currentPage = Int(pageIndex)
        
        let maximumHorizontalOffset: CGFloat = scrollView.contentSize.width - scrollView.frame.width
        let currentHorizontalOffset: CGFloat = scrollView.contentOffset.x
        
        // vertical
        let maximumVerticalOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.height
        let currentVerticalOffset: CGFloat = scrollView.contentOffset.y
        
        let percentageHorizontalOffset: CGFloat = currentHorizontalOffset / maximumHorizontalOffset
        let percentageVerticalOffset: CGFloat = currentVerticalOffset / maximumVerticalOffset
        
        
        /*
         * below code changes the background color of view on paging the scrollview
         */
        //        self.scrollView(scrollView, didScrollToPercentageOffset: percentageHorizontalOffset)
        
        
        /*
         * below code scales the imageview on paging the scrollview
         */
        let percentOffset: CGPoint = CGPoint(x: percentageHorizontalOffset, y: percentageVerticalOffset)
        
//        if(percentOffset.x > 0 && percentOffset.x <= 0.25) {
//
//         slides[0].lbl_Desc.transform.transform = CGAffineTransform(scaleX: (0.25-percentOffset.x)/0.25, y: (0.25-percentOffset.x)/0.25)
//           // slides[1].lbl_Desc.transform = CGAffineTransform(scaleX: percentOffset.x/0.25, y: percentOffset.x/0.25)
//
//        } else if(percentOffset.x > 0.25 && percentOffset.x <= 0.50) {
//        slides[1].lbl_Desc.transform.transform = CGAffineTransform(scaleX: (0.50-percentOffset.x)/0.25, y: (0.50-percentOffset.x)/0.25)
//         //   slides[2].lbl_Desc.transform = CGAffineTransform(scaleX: percentOffset.x/0.50, y: percentOffset.x/0.50)
//
//        } else if(percentOffset.x > 0.50 && percentOffset.x <= 0.75) {
//        slides[2].lbl_Desc.transform.transform = CGAffineTransform(scaleX: (0.75-percentOffset.x)/0.25, y: (0.75-percentOffset.x)/0.25)
//          //  slides[3].lbl_Desc.transform = CGAffineTransform(scaleX: percentOffset.x/0.75, y: percentOffset.x/0.75)
//
//        }
    }
    
    
    
    
    func scrollView(_ scrollView: UIScrollView, didScrollToPercentageOffset percentageHorizontalOffset: CGFloat) {
        if(pageC.currentPage == 0) {
            //Change background color to toRed: 103/255, fromGreen: 58/255, fromBlue: 183/255, fromAlpha: 1
            //Change pageControl selected color to toRed: 103/255, toGreen: 58/255, toBlue: 183/255, fromAlpha: 0.2
            //Change pageControl unselected color to toRed: 255/255, toGreen: 255/255, toBlue: 255/255, fromAlpha: 1
            
            let pageUnselectedColor: UIColor = fade(fromRed: 255/255, fromGreen: 255/255, fromBlue: 255/255, fromAlpha: 1, toRed: 103/255, toGreen: 58/255, toBlue: 183/255, toAlpha: 1, withPercentage: percentageHorizontalOffset * 3)
            pageC.pageIndicatorTintColor = pageUnselectedColor
            
            
            let bgColor: UIColor = fade(fromRed: 103/255, fromGreen: 58/255, fromBlue: 183/255, fromAlpha: 1, toRed: 255/255, toGreen: 255/255, toBlue: 255/255, toAlpha: 1, withPercentage: percentageHorizontalOffset * 3)
            slides[pageC.currentPage].backgroundColor = bgColor
            
            let pageSelectedColor: UIColor = fade(fromRed: 81/255, fromGreen: 36/255, fromBlue: 152/255, fromAlpha: 1, toRed: 103/255, toGreen: 58/255, toBlue: 183/255, toAlpha: 1, withPercentage: percentageHorizontalOffset * 3)
            pageC.currentPageIndicatorTintColor = pageSelectedColor
        }
    }
    
    
    func fade(fromRed: CGFloat,
              fromGreen: CGFloat,
              fromBlue: CGFloat,
              fromAlpha: CGFloat,
              toRed: CGFloat,
              toGreen: CGFloat,
              toBlue: CGFloat,
              toAlpha: CGFloat,
              withPercentage percentage: CGFloat) -> UIColor {
        
        let red: CGFloat = (toRed - fromRed) * percentage + fromRed
        let green: CGFloat = (toGreen - fromGreen) * percentage + fromGreen
        let blue: CGFloat = (toBlue - fromBlue) * percentage + fromBlue
        let alpha: CGFloat = (toAlpha - fromAlpha) * percentage + fromAlpha
        
        // return the fade colour
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    @IBAction func btn_Relogin(_ sender: UIButton){
        
        
        
        UserDefaults.standard.set(Bool(false), forKey:"isLogin")
        UserDefaults.standard.set(Bool(false), forKey:"isSmartLogin")
        UserDefaults.standard.set(Bool(false), forKey:"isMobileVerified")
        UserDefaults.standard.synchronize()
        
        let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: ConstantsModel.KeyDefaultUser.userData)
        
        print("Remove was successful: \(removeSuccessful)")
        
        let mainVcIntial = kConstantObj.SetIntialMainViewController("VDG_Auth_ViewController")
        self.window?.rootViewController = mainVcIntial
        
        self.dismiss(animated: false, completion: nil )
        
    }
    
    @IBAction func btn_Close(_ sender: UIButton){
        self.dismiss(animated: false, completion: nil )
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
