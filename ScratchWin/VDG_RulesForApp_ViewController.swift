//
//  VDG_RulesForApp_ViewController.swift
//  VeriDocG
//
//  Created by Bhavdip Patel on 19/03/19.
//  Copyright © 2019 SevenBits. All rights reserved.
//

import UIKit




class VDG_RulesForApp_ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Data model: These strings will be the data for the table view cells
    let arr_Info: [String] = ["You must be 18+ years of age to participate in this promotion.", "Persons ineligible and excluded from this promotion are: (a) Directors and Employees of VeriDoc Global: (b) Persons who are prohibited under the laws of their country of citizenship, residency or domicile to participate in any games of chance and/or skill, or this Promotion.", "Only one account per person is allowed for this promotion.","The promotion ends when the prize pool runs out.", "Prizes are awarded on an ‘as-is’ basis and are not transferable, negotiable, refundable or exchangeable. Non-cash prizes cannot be taken in cash. The promoter reserves the right not to award any prize or part thereof to any person who, for any reason whatsoever, fails to meet any stipulated requirement in order to claim a prize.", "Accounts may be subject to verification when claiming prizes. If individuals are found to be using multiple accounts to harvest VDG utility points during this promotion, the promoter reserves the right to disqualify the participant and not to award any prize to that person.", "Apple is not involved in any way with this promotion or sweepstakes."]
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "Rules_App_Cell"
    
    // don't forget to hook this up from the storyboard
    @IBOutlet var tableView: UITableView!
      @IBOutlet weak var lbl_version: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // (optional) include this line if you want to remove the extra empty cell divider lines
        // self.tableView.tableFooterView = UIView()
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationController?.navigationBar.isHidden = true
        
      
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            
            // self.labelVersion.text = version
            
            let dictionary = Bundle.main.infoDictionary!
            let version = dictionary["CFBundleShortVersionString"] as! String
            let build = dictionary["CFBundleVersion"] as! String
            lbl_version.text =  "Version \(version)"
        
        }
        
        let nib = UINib.init(nibName: "Rules_App_Cell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Rules_App_Cell")
        
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
    }
    
    @IBAction func btn_Menu(_ sender: UIButton)  {
        
        sideMenuVC.toggleMenu()
        
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_Info.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "Rules_App_Cell"
        var cell: Rules_App_Cell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? Rules_App_Cell
        if cell == nil {
            tableView.register(UINib(nibName: "Rules_App_Cell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? Rules_App_Cell
        }
        
        let number = indexPath.row + 1
        cell.lbl_Number?.text =   "•"//String(number)
        cell.lbl_Details?.text = arr_Info[indexPath.row]
     
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
