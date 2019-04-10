//
//  VDG_RateUS_ViewController.swift
//  VeriDocG
//
//  Created by Bhavdip Patel on 11/12/18.
//  Copyright © 2018 SevenBits. All rights reserved.
//

import UIKit


class VDG_RateUS_ViewController: UIViewController {

    var window: UIWindow?
    @IBOutlet var vw_Rate: UIView!
   
    
    
    @IBOutlet var btn_Submit: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     self.navigationController?.navigationBar.isHidden = true
        // Do any additional setup after loading the view.
    }

    
    override func viewDidAppear(_ animated: Bool) {
     
        print(vw_Rate.frame.width/2)
        
        
        
        let starRatingView = HCSStarRatingView(frame: CGRect(x: 0, y: 0, width: vw_Rate.frame.width, height: vw_Rate.frame.height))
        starRatingView.maximumValue = 5
        starRatingView.minimumValue = 0
        starRatingView.value = 0
        starRatingView.emptyStarImage = UIImage(named: "icn_rate_empty")
        
        starRatingView.filledStarImage = UIImage(named: "icn_rate_fill")
        //starRatingView.backgroundColor = UIColor.gray
       // starRatingView.tintColor = UIColor.init(red: 255/255, green: 196/255, blue: 43/255 , alpha: 1.0)
        //starRatingView.addTarget(self, action: #selector(self.didChangeValue(_:)), for: .valueChanged)
        vw_Rate.addSubview(starRatingView)
        
        print(starRatingView.frame.width)
        
        
        let X1 = starRatingView.frame.width/2 as CGFloat
        let X2 = vw_Rate.frame.width/2 as CGFloat
        let X3 = X2 - X1
     
        // let xPosition = DynView.frame.origin.x
        
        //View will slide 20px up
        
        let yPosition = starRatingView.frame.origin.y
        let height = starRatingView.frame.size.height
        let width = starRatingView.frame.size.width
     
        
        UIView.animate(withDuration: 0.5, animations: {
           // starRatingView.frame = CGRect(x: X3,y: yPosition,width: width, height: height)
        })
        
        
        btn_Submit.layer.cornerRadius = 8
        btn_Submit.clipsToBounds = true
        
        
       
        
    }
    
    @IBAction func btn_RateUs(_ sender: UIButton) {
        
        if let url = URL(string: ConstantsModel.BasePath.url_appstorescratchandwinapp),
            UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url, options: [:]) { (opened) in
                if(opened){
                    print("App Store Opened")
                }
            }
        } else {
            print("Can't Open URL on Simulator")
        }
    }
    
    @IBAction func btn_BackButton(_ sender: UIButton)  {
        
        sideMenuVC.toggleMenu()
        
    }
    
    @IBAction func btn_NotNow(_ sender: UIButton) {
       kConstantObj.SetIntialMainViewController("VDG_ScanNowLoading_ViewController")
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
