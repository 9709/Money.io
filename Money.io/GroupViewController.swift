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
    
    tableView.dataSource = self
    tableView.delegate = self
  }
  
  // MARK: Navigation
  
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
    } else if segue.identifier == "toEditTransactionSegue" {
      if let viewController = segue.destination as? UINavigationController {
        if let editTransactionVC = viewController.children[0] as? NewTransactionViewController {
          if let transactionCell = sender as? TransactionTableViewCell,
            let selectedRow = tableView.indexPath(for: transactionCell)?.row {
            let transaction = group.listOfTransactions[selectedRow]
            editTransactionVC.transaction = transaction
            editTransactionVC.group = group
            editTransactionVC.delegate = self
          }
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
  
  func updateTransaction() {
    tableView.reloadData()
  }
}

extension GroupViewController: UITableViewDelegate {
  
  // MARK: UITableViewDelegate methods
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      group.deleteTransaction(at: indexPath.row)
      tableView.reloadData()
    }
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
