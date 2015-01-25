//
//  UserDetailVC.swift
//  GithubClient
//
//  Created by David Rogers on 1/21/15.
//  Copyright (c) 2015 David Rogers. All rights reserved.
//

import UIKit

class UserDetailVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  var selectedUser : User!
  
  let netCon = NetCon.sharedNetworkController
  
  var repos = [Repository]()
  
  @IBOutlet weak var userImage: UIImageView!
  
  @IBOutlet weak var userNameLabel: UILabel!
  
  @IBOutlet weak var userTableView: UITableView!
  
  

    override func viewDidLoad() {
        super.viewDidLoad()
      userImage.layer.cornerRadius = 12
      userImage.layer.masksToBounds = true
      userImage.image = selectedUser.avatarImage
      
      userNameLabel.text = selectedUser.name
    
        // Do any additional setup after loading the view.
      
      
      
      netCon.fetchReposForUser(selectedUser.name, callback: { (repos, error) -> (Void) in
        if error == nil {
          if repos != nil {
            self.repos = repos!
            self.userTableView.reloadData()
          }
        }
      })
   
      //setup table for user - starting with delegate/data-source
      userTableView.dataSource = self
      userTableView.delegate = self
      
      //setup automatic dimension
      userTableView.estimatedRowHeight = 100
      userTableView.rowHeight = UITableViewAutomaticDimension
    }
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return repos.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("REPO_CELL", forIndexPath: indexPath) as RepoCell
  
    let repo = repos[indexPath.row]
    cell.repoNameLabel.text = repo.name
    cell.authorNameLabel.text = repo.author
  
    return cell
  }
  
  func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    
    let webVC = self.storyboard?.instantiateViewControllerWithIdentifier("WEB_VC") as WebVC
    
    webVC.url = repos[indexPath.row].url
    
    navigationController?.pushViewController(webVC, animated: true)
    self.navigationController?.delegate = nil
  }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
