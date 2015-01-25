//
//  UserSearchVC.swift
//  GithubClient
//
//  Created by David Rogers on 1/21/15.
//  Copyright (c) 2015 David Rogers. All rights reserved.
//

import UIKit

class UserSearchVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UINavigationControllerDelegate {
  
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  @IBOutlet weak var searchBar: UISearchBar!
  
  var users = [User]()
  
  let netCon = NetCon.sharedNetworkController

    override func viewDidLoad() {
        super.viewDidLoad()
      collectionView.dataSource = self
      collectionView.delegate = self
      
      searchBar.delegate = self
      
      navigationController?.delegate = self
    

        // Do any additional setup after loading the view.
    }

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return users.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("USER_CELL", forIndexPath: indexPath) as UserCell
    
    
    var user = users[indexPath.row]
    
    
    cell.userImage.layer.cornerRadius = 8
    cell.userImage.layer.masksToBounds = true
    
    cell.userImage.image = nil
    cell.userImage.alpha = 0
    let cellAnimationDuration = 0.3
    
    
    
    if user.avatarImage == nil {
     
      netCon.fetchAvatarImage(user.avatarURL, completionHandler: { (avatarImage) -> (Void) in
        
        
        user.avatarImage = avatarImage
        self.users[indexPath.row].avatarImage = avatarImage
        cell.userImage.image = user.avatarImage
        
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
          
          UIView.animateWithDuration(cellAnimationDuration, animations: { () -> Void in
            cell.userImage.alpha = 1.0
          })
        })
      })
    } else {
      cell.userImage.image = user.avatarImage
      UIView.animateWithDuration(cellAnimationDuration, animations: { () -> Void in
        cell.userImage.alpha = 1.0
      })
    }
    return cell
  }
  
  //MARK: Searchbar
  
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    
    
    NetCon.sharedNetworkController.fetchUsersForSearchTerm(searchBar.text, callback: { (users, errorDescription) -> (Void) in
      if users != nil {
        self.users = users!
        
      }
      self.collectionView.reloadData()
    })
    searchBar.resignFirstResponder()
  }
  
  func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    if toVC is UserDetailVC {
      return ToUserDetailTransitionAnimationController()
    } else {
    return nil
    }
  }
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "SHOW_USER_DETAIL" {
      let userDetailVC = segue.destinationViewController as UserDetailVC
      let selectedIndexPath = collectionView.indexPathsForSelectedItems().first as NSIndexPath
      userDetailVC.selectedUser = users[selectedIndexPath.row]
      
    }
  }
  
  func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    return text.validateSearch()
  }
}
