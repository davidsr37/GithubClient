//
//  ToUserDetailTransitionAnimationController.swift
//  GithubClient
//
//  Created by David Rogers on 1/21/15.
//  Copyright (c) 2015 David Rogers. All rights reserved.
//

import UIKit

class ToUserDetailTransitionAnimationController : NSObject, UIViewControllerAnimatedTransitioning {
 //MARK: Transition Duration
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
    return 0.4
  }
  //MARK: Animation
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    
    //get references to both UserSearch and UserDetail VC's
    let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as
      UserSearchVC
    let toVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as UserDetailVC
    
    let containerView = transitionContext.containerView()
    
    //get selected cell and snapshot the image (userImage) that is going to move
    let selectedIndexPath = fromVC.collectionView.indexPathsForSelectedItems().first as NSIndexPath
    let cell = fromVC.collectionView.cellForItemAtIndexPath(selectedIndexPath) as UserCell
    let cellSnapshot = cell.userImage.snapshotViewAfterScreenUpdates(false)
    
    cellSnapshot.frame = containerView.convertRect(cell.userImage.frame, fromView: cell.userImage.superview)
    
    cell.userImage.hidden = true
    
    //make toVC start on screen but transparent (alpha = 0)
    toVC.view.frame = transitionContext.finalFrameForViewController(toVC)
    toVC.view.alpha = 0
    toVC.userImage.hidden = true
    
    //add views to transition container
    containerView.addSubview(toVC.view)
    containerView.addSubview(cellSnapshot)
    
    //autolayout
    toVC.view.setNeedsLayout()
    toVC.view.layoutIfNeeded()
    
    let duration = self.transitionDuration(transitionContext)
    
    UIView.animateWithDuration(duration, animations: { () -> Void in
      toVC.view.alpha = 1.0
      
      cellSnapshot.frame = containerView.convertRect(toVC.userImage.frame, fromView: toVC.view)
      
      }) { (finished) -> Void in
        
        toVC.userImage.hidden = false
        cell.userImage.hidden = false
        cellSnapshot.removeFromSuperview()
        transitionContext.completeTransition(true)
      }
    
  }
  
}
