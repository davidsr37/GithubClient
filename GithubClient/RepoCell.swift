//
//  RepoCell.swift
//  GithubClient
//
//  Created by David Rogers on 1/24/15.
//  Copyright (c) 2015 David Rogers. All rights reserved.
//

import UIKit



class RepoCell: UITableViewCell {
  

  @IBOutlet weak var repoNameLabel: UILabel!
  
  
  @IBOutlet weak var authorNameLabel: UILabel!
  
  let repo : Repository!
  
  
  //xib file version of viewDidLoad
  override func awakeFromNib() {
    super.awakeFromNib()
    
    self.repoNameLabel.text = repo?.name
    self.authorNameLabel.text = repo?.author
    
    // Initialization code would go here
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }

  
  
}