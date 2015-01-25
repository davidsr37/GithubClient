//
//  Repo.swift
//  GithubClient
//
//  Created by David Rogers on 1/19/15.
//  Copyright (c) 2015 David Rogers. All rights reserved.
//

import Foundation

struct Repository {
  
  let name : String
  let author : String
  let url : String
  
  init(jsonDictionary : [String : AnyObject]) {
    self.name = jsonDictionary["name"] as String
    self.author = jsonDictionary["login"] as String 
    self.url = jsonDictionary["html_url"] as String
  }
  
}
