//
//  NetCon.swift
//  GithubClient
//
//  Created by David Rogers on 1/19/15.
//  Copyright (c) 2015 David Rogers. All rights reserved.
//

import UIKit

class NetCon {
  
//MARK: Singleton NetCon
  class var sharedNetworkController : NetCon {
    struct Static {
      static let instance : NetCon = NetCon()

    }
    return Static.instance
  }
  
  //global var of urlSession - we want accessible from all classes
  let clientSecret = "9afc211b878b387d26a5637b73b04c8eaa4040b1"
  let clientID = "952c7caaf6e1fab8e68e"
  
  var urlSession : NSURLSession
  let accessTokenUserDefaults = "accessToken"
  var accessToken : String?
  
  let imageQueue = NSOperationQueue()
  
//MARK: Init
  init() {
    //init with config
    let ephemConfig = NSURLSessionConfiguration.ephemeralSessionConfiguration()
    
    self.urlSession = NSURLSession(configuration: ephemConfig)
    if let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(self.accessTokenUserDefaults) as? String {
      self.accessToken = accessToken
    }
  
  }
  
  func requestAccessToken() {
    let url = "https://github.com/login/oauth/authorize?client_id=\(self.clientID)&scope=user,repo"
    
    UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    
  } 
  
  func handleCallbackURL(url : NSURL) {
      let query = url.query
    
    
//      let oauthURL = "https://github.com/login/oath/access_token\(query!)&client_id=\(self.clientID)&client_secret=\(self.clientSecret)"
//      let postRequest = NSMutableURLRequest(URL: NSURL(string: oauthURL)!)
//      postRequest.HTTPMethod = "POST"
//    this was another method learned in class, but will not work if the authentication comes in the body of the HTTP request, hence we do it in the following way:
    
    
    let bodyString = "\(query!)&client_id=\(self.clientID)&client_secret=\(self.clientSecret)"
    let bodyData = bodyString.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
    
    let length = bodyData!.length
    let postRequest = NSMutableURLRequest(URL: NSURL(string: "https://github.com/login/oauth/access_token")!)
    
    postRequest.HTTPMethod = "POST"
    
    postRequest.setValue("\(length)", forHTTPHeaderField: "Content_Length")
    postRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    postRequest.HTTPBody = bodyData
    
    let dataTask = self.urlSession.dataTaskWithRequest(postRequest, completionHandler: { (data, response, error) -> Void in
      
      if error == nil {
        if let httpResponse = response as? NSHTTPURLResponse {
          switch httpResponse.statusCode {
          case 200...299:
            let tokenResp = NSString(data: data, encoding: NSASCIIStringEncoding)
            println(tokenResp)
            
            let accessTokenComponent = tokenResp?.componentsSeparatedByString("&").first as String
            let accessToken = accessTokenComponent.componentsSeparatedByString("=").last
            //check it
            println(accessToken!)
            self.accessToken = accessToken
            //the following makes it so you don't have to do authentication over again by storing it in user defaults
            NSUserDefaults.standardUserDefaults().setObject(accessToken!, forKey: self.accessTokenUserDefaults )
            
            NSUserDefaults.standardUserDefaults().synchronize()
            
          default:
            println("default case")
          }
        }
      }
  
    })
    //required
    dataTask.resume()
  
  }
  
  func fetchRepoForSearchTerm(searchTerm : String, callback : ([AnyObject]?, String) -> (Void)) {
  
    let url = NSURL(string: "https://api.github.com/search/repositories?q=\(searchTerm)")
    
    let request = NSMutableURLRequest(URL: url!)
    request.setValue("token \(self.accessToken!)", forHTTPHeaderField: "Authorization")
  
    let dataTask = self.urlSession.dataTaskWithURL(url!, completionHandler: { (data, urlResp, error) -> Void in
  
      if error == nil {
        println(urlResp)
        if let httpResp = urlResp as? NSHTTPURLResponse {
          
          switch httpResp.statusCode {
                
          case 200...299:
            println(httpResp)
            let jsonDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as [String : AnyObject]
            println(jsonDictionary)
          default:
            println("default")
//            if let jsonArray = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? [AnyObject] {
//                for object in jsonArray {
//                  if let jsonDictionary = object as? [String : AnyObject] {
          }
          
        }
    
      }

    })
    dataTask.resume()
  }
  
  func fetchUsersForSearchTerm(searchTerm : String, callback : ([User]?, String?) -> (Void)) {
    let url = NSURL(string: "https://api.github.com/search/users?q=\(searchTerm)")
    let request = NSMutableURLRequest(URL: url!)
    //following line is how github knows who is making the request
    request.setValue("token \(self.accessToken!)", forHTTPHeaderField: "Authorization")
    
    let dataTask = self.urlSession.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
      if error == nil {
        
        if let httpResponse = response as? NSHTTPURLResponse {
          switch httpResponse.statusCode {
            
          case 200...299:
            if let jsonDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? [String : AnyObject] {
              if let itemsArray = jsonDictionary["items"] as? [[String : AnyObject]] {
                
                var users = [User]()
                
                for item in itemsArray {
                  let user = User(jsonDictionary: item)
                  users.append(user)
                  
                }
                
                  NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    callback(users, nil)
                  })
                }
              }
          default:
            println("default case with status code: \(httpResponse.statusCode)")
          }
        }
      } else {
        println(error.localizedDescription)
      }
      
    })
    dataTask.resume()
  }
  
  func fetchAvatarImage(url : String, completionHandler : (UIImage) -> (Void)) {
    
    let url = NSURL(string: url)
    
    self.imageQueue.addOperationWithBlock { () -> Void in
      let imageData = NSData(contentsOfURL: url!)
      let image = UIImage(data: imageData!)
      
      NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        completionHandler(image!)
      })
    }
  }
}
  














