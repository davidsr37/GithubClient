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
  let clientSecret = "f25d12fdcaa80cdb7058691fb523852b4727e99f"
  let clientID = "db94e269b025aa7eca3a"
  
  var urlSession : NSURLSession
  let accessTokenUserDefaults = "AccessToken"
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
  //MARK: Handle Callback ->
  func handleCallbackURL(url : NSURL) {
      let query = url.query
    
    
     let requestURL = "https://github.com/login/oath/access_token\(query!)&client_id=\(self.clientID)&client_secret=\(self.clientSecret)"
     let postRequest = NSMutableURLRequest(URL: NSURL(string: requestURL)!)
     postRequest.HTTPMethod = "POST"
    
//    this was another (much shorter) method learned in class, but will not work if the authentication comes in the body of the HTTP request, we can do it in the following way in that case:
//    
//    //our data and format, but added to the body-string
//    let bodyString = "\(query!)&client_id=\(self.clientID)&client_secret=\(self.clientSecret)"
//    
//    //set property necessary for body-data format
//    let bodyData = bodyString.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
//    //another necessary property of this format
//    let length = bodyData!.length
//    
//    //set-up post request url and then you can set more required properties for the body format
//    let postRequest = NSMutableURLRequest(URL: NSURL(string: "https://github.com/login/oauth/access_token")!)
//    //this next one is universal: our method call to the API server
//    postRequest.HTTPMethod = "POST"
//    
//    //and this is how we do it
//    postRequest.setValue("\(length)", forHTTPHeaderField: "Content-Length")
//    postRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//    //and we do it
//    postRequest.HTTPBody = bodyData
//    //yes, that was a lot to do for body format
//    
    //now, to the session - request
    
    
    let dataTask = self.urlSession.dataTaskWithRequest(postRequest, completionHandler: { (data, response, error) -> Void in
      
      if error == nil {
        if let httpResponse = response as? NSHTTPURLResponse {
          switch httpResponse.statusCode {
          case 200...299:
            let tokenResp = NSString(data: data, encoding: NSASCIIStringEncoding)
            println(tokenResp)
            //token and data comes back
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
  
  func fetchRepoForSearchTerm(searchTerm : String, callback : ([Repository]?, String?) -> (Void)) {
  
    let url = NSURL(string: "https://api.github.com/search/repositories?q=\(searchTerm)")
    
    let request = NSMutableURLRequest(URL: url!)
    request.setValue("token \(self.accessToken!)", forHTTPHeaderField: "Authorization")
  
    let dataTask = self.urlSession.dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
  
      if error == nil {
      
        if let httpResp = response as? NSHTTPURLResponse {
          
          switch httpResp.statusCode {
                
          case 200...299:
            println(httpResp)
            if let jsonDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? [String : AnyObject] {
      //      println(jsonDictionary)
            
              if let itemsArray = jsonDictionary["items"] as? [[String : AnyObject]] {
              var repos = [Repository]()
              for item in itemsArray {
                let repo = Repository(jsonDictionary: item)
                repos.append(repo)
                }
              NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                callback(repos, nil)
                })
              }
            }
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
  //MARK: Avatar Image Fetch 
  
  //we pass in a url and see it complete in the image and return void
  func fetchAvatarImage(avatarURL : String, completionHandler : (UIImage?) -> (Void)) {
    //local image variable
    var image: UIImage?
    //local url variable
    let url = NSURL(string: avatarURL)
    //if the info is there
    if url != nil {
    //setup seperate queue
    imageQueue.addOperationWithBlock( {() -> Void in
      //convert data of image to image
      let imageData = NSData(contentsOfURL: url!)
      if imageData != nil {
        image = UIImage(data: imageData!)
      }
      //bring the image back to the main queue using the completion handler
      NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        completionHandler(image!)
      })
    })
      
    } else {
        completionHandler(image!)
        
      
      
    }
  }
  
  //MARK: Repos for User Fetch
  func fetchReposForUser(userName: String, callback: ([Repository]?, String?) -> (Void)) {
    let url = NSURL(string: "https://api.github.com/search/repositories?q=user:\(userName)")
    let request = NSMutableURLRequest(URL: url!)
    //authorize
    request.setValue("token \(self.accessToken!)", forHTTPHeaderField: "Authorization")
    
    let dataTask = self.urlSession.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
      if error == nil {
        
        if let httpResponse = response as? NSHTTPURLResponse {
          switch httpResponse.statusCode {
            
          case 200...299:
            if let jsonDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? [String : AnyObject] {
              if let itemsArray = jsonDictionary["items"] as? [[String : AnyObject]] {
                
                var repositories = [Repository]()
                
                for item in itemsArray {
                  let repository = Repository(jsonDictionary: item)
                  repositories.append(repository)
                  
                }
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                  callback(repositories, nil)
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
}











