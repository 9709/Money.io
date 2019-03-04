//
//  GroupViewController.swift
//  Money.io
//
//  Created by Matthew Chan on 2019-03-02.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

class GroupViewController: UIViewController {
  
  var group: Group!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    group = Group(name: "LHL")
    group.addUser(name: "Matthew")
    group.addUser(name: "Jun")
    group.addUser(name: "Jenny")
    group.addUser(name: "Josh")
    group.addUser(name: "Spencer")
    group.addUser(name: "Jason")
    group.addUser(name: "Roland")
    group.addUser(name: "Danny")
    group.addUser(name: "Sam")
    group.addUser(name: "Amir")
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toGroupMembersSegue" {
      if let viewController = segue.destination as? UINavigationController {
        if let groupMembersVC = viewController.children[0] as? GroupMembersViewController {
          groupMembersVC.group = group
        }
      }
    } else if segue.identifier == "toNewTransactionSegue" {
      if let viewController = segue.destination as? UINavigationController {
        if let newTransactionVC = viewController.children[0] as? NewTransactionViewController {
          newTransactionVC.group = group
        }
      }
    }
  }
  
}
