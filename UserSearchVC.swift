//
//  UserSearchVC.swift
//  GithubClient
//
//  Created by David Rogers on 1/21/15.
//  Copyright (c) 2015 David Rogers. All rights reserved.
//

import UIKit

class UserSearchVC: UIViewController, UICollectionViewDataSource, UISearchBarDelegate, UINavigationControllerDelegate {
  
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  @IBOutlet weak var searchBar: UISearchBar!
  
  var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
      self.collectionView.dataSource = self
      self.searchBar.delegate = self
      self.navigationController?.delegate = self

        // Do any additional setup after loading the view.
    }

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.users.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("USER_CELL", forIndexPath: indexPath) as UserCell
    cell.userImage.image = nil
    var user = self.users[indexPath.row]
    if user.avatarImage == nil {
      
      // setup netcon-singleton method for fetchUserImage
      NetCon.sharedNetworkController.fetchAvatarImage(user.avatarURL, completionHandler: { (image) -> (Void) in
        cell.userImage.image = image
        user.avatarImage = image
        self.users[indexPath.row] = user
      })
    } else {
      cell.userImage.image = user.avatarImage
    }
    return cell
  }
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    
    NetCon.sharedNetworkController.fetchUsersForSearchTerm(searchBar.text, callback: { (users, errorDescription) -> (Void) in
      if errorDescription == nil {
        self.users = users!
        self.collectionView.reloadData()
      }
    })
  }
  
  func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    if fromVC is UserSearchVC {
      return ToUserDetailTransitionAnimationController()
    }
    return nil
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "SHOW_USER_DETAIL" {
      let destinationVC = segue.destinationViewController as UserDetailVC
      let selectedIndexPath = self.collectionView.indexPathsForSelectedItems().first as NSIndexPath
      destinationVC.selectedUser = self.users[selectedIndexPath.row]
      
    }
  }
}
