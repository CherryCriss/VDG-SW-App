//
//  GenerateInviteURL.swift
//  VeriDocG
//
//  Created by Bhavdip Patel on 23/10/18.
//  Copyright © 2018 SevenBits. All rights reserved.
//

import UIKit
import Branch
import SwiftKeychainWrapper

class GenerateInviteURL: NSObject {
    
    class func GetURLTemp(_ completion: @escaping ((String) -> Void)){
        
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        
        let now = NSDate()
        let nowTimeStamp = getCurrentTimeStampWOMiliseconds(dateToConvert: now)
        
        let str_First = userDetail!["firstname"] as! String
        let str_Last = userDetail!["lastname"] as! String
        

        let str_Name = str_First + " " + str_Last

        let dictParams: [String: AnyObject] = ["UserID" : userDetail!["customerguid"] as AnyObject ,
                                               "EmailID" : userDetail!["email"] as AnyObject,
                                               "Name" : str_Name as AnyObject
        ]
        
        var error : NSError?
        
        let jsonData = try! JSONSerialization.data(withJSONObject: dictParams, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        
     
        let lp: BranchLinkProperties = BranchLinkProperties()
        lp.channel = "VeriDoc Global Application"
        lp.feature = "invite"
        lp.stage = jsonString
        lp.addControlParam("android_deeplink_path", withValue: "https://play.google.com/store/apps/details?id=com.veridocscratch.android")
        lp.addControlParam("ios_url", withValue: ConstantsModel.BasePath.url_appstorescratchandwinapp)
        lp.matchDuration = 0
        
        
        
        
        let buo = BranchUniversalObject.init(canonicalIdentifier: nowTimeStamp)
        buo.title = "VeriDoc Global Application"
        buo.contentDescription = "Hey! Have you not tried SCRATCH & WIN?\nGet a chance to WIN up to 5000 Points and Exclusive Prizes.\nNow,For whom you are waiting? Hurry Up!!! Click on SCRATCH NOWand try out your LUCK."
        buo.locallyIndex = true
        buo.publiclyIndex = true
        buo.contentMetadata.customMetadata["sponsorname"] = userDetail!["customerguid"] as AnyObject

        
        
        
        buo.getShortUrl(with: lp) { (url, error) in
            print(url ?? "")
            
            var valueToReturn:String = "default"
            
            if error == nil {
                valueToReturn = url!
            }else {
                valueToReturn = ""
            }
            
            completion(valueToReturn)
            
        }
        
       
    }
    
    
    class func getCurrentTimeStampWOMiliseconds(dateToConvert: NSDate) -> String {
        let objDateformat: DateFormatter = DateFormatter()
        objDateformat.dateFormat = "yyyy-MM-dd"
        let strTime: String = objDateformat.string(from: dateToConvert as Date)
        let objUTCDate: NSDate = objDateformat.date(from: strTime)! as NSDate
        let milliseconds: Int64 = Int64(objUTCDate.timeIntervalSince1970)
        let strTimeStamp: String = "\(milliseconds)"
        return strTimeStamp
    }
    
    
}
