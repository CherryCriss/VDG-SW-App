//
//  API_FCMPUSH.swift
//  VeriDocG
//
//  Created by Bhavdip Patel on 22/11/18.
//  Copyright © 2018 SevenBits. All rights reserved.
//

import UIKit

class API_FCMPUSH: NSObject {

    
    class func pushNotification(_ parameters: NSDictionary, completion: @escaping ((String) -> Void)){
        
 
        // create the request
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("key=" + Constant.GlobalConstants.str_FCMserverKey, forHTTPHeaderField: "authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      
        
         print(parameters)
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let dataTask = session.dataTask(with: request as URLRequest) { data,response,error in
            let httpResponse = response as? HTTPURLResponse
            if (error != nil) {
                print(error!)
            } else {
                print(httpResponse!)
                
                
                if response != nil {   // Complete response
                    let responseData = String(data: data!, encoding: String.Encoding.utf8)
                     completion(responseData!)
                }

               
                
                
            }
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            do {
                guard let responseDictionary = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        print("error trying to convert data to JSON")
                        return
                }
                print("The responseDictionary is: " + responseDictionary.description)
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
            DispatchQueue.main.async {
                //Update your UI here
            }
        }
        dataTask.resume()
        
     
            
        
            
        
        
        
    }
    
}
