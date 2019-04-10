//
//  VDG_MyAddress_ViewController.swift
//  VeriDocG
//
//  Created by Bhavdip Patel on 25/01/19.
//  Copyright © 2019 SevenBits. All rights reserved.
//

import UIKit

class VDG_MyAddress_ViewController: UIViewController {
    
    @IBOutlet var txt_Address1: UITextField!
    @IBOutlet var txt_Address2: UITextField!
    @IBOutlet var txt_Suburb: UITextField!
    @IBOutlet var txt_PostCode: UITextField!
    @IBOutlet var txt_ContactNumber: UITextField!
    @IBOutlet var btn_State: UIButton!
    @IBOutlet var btn_State_Arrw: UIButton!
    @IBOutlet var btn_Save: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btn_Save.layer.cornerRadius = 8
        btn_Save.clipsToBounds = true
        
    }
    
    @IBAction func btn_Save(_ sender: UIButton) {
        
    if(txt_Address1.text?.removingWhitespaces(txt_Address1.text).isEmpty)!{
            Toast(text: "Please enter Address").show()
        
        }else if (txt_Suburb.text?.removingWhitespaces(txt_Suburb.text).isEmpty)!{
            Toast(text: "Please enter suburb").show()
        
        }else if (txt_PostCode.text?.removingWhitespaces(txt_PostCode.text).isEmpty)!{
           Toast(text: "Please enter postcode").show()
        
        }else if (btn_State.titleLabel?.text == "Select"){
            Toast(text: "Please select state").show()
        
        }else if (txt_ContactNumber.text?.removingWhitespaces(txt_ContactNumber.text).isEmpty)!{
            Toast(text: "Please enter contact number").show()
        }else {
            Toast(text: "Success!").show()
        }
        
        
        
        
        
        
    }
    
    @IBAction func btn_Back(_ sender: UIButton) {
        
        _ = navigationController?.popToRootViewController(animated: true) 
        
    }
    
    @IBAction func btn_State(_ sender: UIButton) {
        
        
        
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
