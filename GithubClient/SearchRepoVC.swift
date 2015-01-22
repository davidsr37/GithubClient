//
//  SearchRepoVC.swift
//  GithubClient
//
//  Created by David Rogers on 1/19/15.
//  Copyright (c) 2015 David Rogers. All rights reserved.
//

import UIKit

class SearchRepoVC: UIViewController, UITableViewDataSource, UISearchBarDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  
  @IBOutlet weak var searchBar: UISearchBar!
  
  var netCon : NetCon!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.dataSource = self
    self.searchBar.delegate = self
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    self.netCon = appDelegate.netCon
  }
  
  
//MARK: UITableViewDataSource
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 10
  }
  
   func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("REPO_CELL", forIndexPath: indexPath) as UITableViewCell
    return cell
  }
//MARK: UISearchBarDelegate
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    println(searchBar.text)
    self.netCon.fetchRepoForSearchTerm(searchBar.text, callback: { (repositories, errorDescription) -> (Void) in
    })
    searchBar.resignFirstResponder()
    
  }
  
}
