//
//  VDG_FAQ_ViewController.swift
//  VeriDocG
//
//  Created by Bhavdip Patel on 31/10/18.
//  Copyright © 2018 SevenBits. All rights reserved.
//

import UIKit

class VDG_FAQ_ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var window: UIWindow?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lbl_version: UILabel!
    
    var dataSource = LyricsGenerator.getLyrics()
     @IBOutlet var txt_ForeFAQ: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

     
        self.navigationController?.navigationBar.isHidden = true
        
         setupUI()
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            
            // self.labelVersion.text = version
            
            let dictionary = Bundle.main.infoDictionary!
            let version = dictionary["CFBundleShortVersionString"] as! String
            let build = dictionary["CFBundleVersion"] as! String
            lbl_version.text =  "Version \(version)"
            
            
        }
        
        
       // txt_ForeFAQ.text = "For more information and FAQs visit us at https://veridocglobal.com/VDG_Scratch_%26_Win_iOS_Terms.pdf"
        
       // txt_ForeFAQ.textAlignment = .left
        // Do any additional setup after loading the view.
    }
   
    func DeviceDetect() -> String {
        
        
        var str_DeviceType: String!
        
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("iPhone1")
                str_DeviceType = "iPhone1"
            case 1334:
                print("iPhone 6/6S/7/8")
                str_DeviceType = "iPhone2"
            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
                str_DeviceType = "iPhone3"
            case 2436:
                print("iPhone X, Xs")
                str_DeviceType = "iPhone4"
            case 2688:
                print("iPhone Xs Max")
                str_DeviceType = "iPhone5"
            case 1792:
                print("iPhone Xr")
                str_DeviceType = "iPhone6"
            default:
                print("unknown")
            }
        }
        
        return str_DeviceType
    }
    
    @IBAction func btn_Menu(_ sender: UIButton)  {
        
        sideMenuVC.toggleMenu()
        
    }
    @IBAction func btn_BackButton(_ sender: UIButton)  {
         sideMenuVC.toggleMenu()
        
      //  sender.addTarget(self, action:#selector(SSASideMenu.presentLeftMenuViewController), for: .touchUpInside)
    }

    override func viewDidAppear(_ animated: Bool) {
        let image = Constant.GradientImage() as UIImage?
        
        self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        //self.navigationController?.navigationBar.barTintColor = Constant.GlobalConstants.kColor_Theme
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    //MARK: UI
    func setupUI() {
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomTableViewCell
       
        
        if indexPath.row == (dataSource.count-1)
        {
            cell.lbl_Line.isHidden = true
            cell.icon.isHidden = true
            
            cell.setValuesLastRow(dataSource[indexPath.row])
            
        }else {
            cell.lbl_Line.isHidden = false
            cell.icon.isHidden = false
             cell.setValues(dataSource[indexPath.row])
        }
        return cell
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if indexPath.row == (dataSource.count-1)
        {
            let fbUrl: NSURL = NSURL(string: "https://veridocglobal.com/FAQsSnWiOS1.3.pdf")!
            
            if (UIApplication.shared.canOpenURL(fbUrl as URL)) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(fbUrl as URL, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(fbUrl as URL)
                }
            }
            
        }else {
            
            let lyrics = dataSource[indexPath.row]
            let lyricsShown = dataSource[indexPath.row].lyricsShown
            lyrics.lyricsShown = !lyricsShown
            
            tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
        
        
        
        
        
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
