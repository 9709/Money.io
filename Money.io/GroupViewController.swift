//
//  GroupViewController.swift
//  Money.io
//
//  Created by Matthew Chan on 2019-03-02.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

class GroupViewController: UIViewController {
  
  // MARK: Properties

  var group: Group!
  
  @IBOutlet weak var tableView: UITableView!
  
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
    
    group.addTransaction(Transaction(name: "Dinner", amount: 70.00, paidUser: group.listOfUsers[2], splitUsers: [
      group.listOfUsers[1],
      group.listOfUsers[2],
      group.listOfUsers[3],
      group.listOfUsers[4]
      ]))
    
    tableView.dataSource = self
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
          newTransactionVC.delegate = self
        }
      }
    }
  }
  
}

extension GroupViewController: NewTransactionViewControllerDelegate {
  
  // MARK: NewTransactionViewControllerDelegate methods
  
  func addTransaction(_ transaction: Transaction) {
    group.addTransaction(transaction)
    tableView.reloadData()
  }
}

extension GroupViewController: UITableViewDataSource {
  
  // MARK: UITableViewDataSource methods
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return group.listOfTransactions.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as? TransactionTableViewCell else {
      return UITableViewCell()
    }
    
    cell.transaction = group.listOfTransactions[indexPath.row]
    cell.configureCell()
    
    return cell
  }
  
  
}
