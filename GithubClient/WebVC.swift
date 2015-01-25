//
//  WebVC.swift
//  GithubClient
//
//  Created by David Rogers on 1/23/15.
//  Copyright (c) 2015 David Rogers. All rights reserved.
//

import UIKit
import WebKit

class WebVC : UIViewController {
  
  let webView = WKWebView()
  var url : String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.webView.frame = self.view.frame
    self.view.addSubview(self.webView)
    
    let request = NSURLRequest(URL: NSURL(string: self.url)!)
    self.webView.loadRequest(request)
  
  }
  
}
