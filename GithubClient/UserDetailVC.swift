//
//  UserDetailVC.swift
//  GithubClient
//
//  Created by David Rogers on 1/21/15.
//  Copyright (c) 2015 David Rogers. All rights reserved.
//

import UIKit

class UserDetailVC: UIViewController {
  
  var selectedUser : User!
  
  @IBOutlet weak var userImage: UIImageView!
  

    override func viewDidLoad() {
        super.viewDidLoad()

      self.userImage.image = selectedUser?.avatarImage
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
