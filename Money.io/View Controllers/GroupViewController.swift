//
//  GroupViewController.swift
//  Money.io
//
//  Created by Matthew Chan on 2019-03-02.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

protocol GroupViewControllerDelegate {
  
}

class GroupViewController: UIViewController {
  
  // MARK: Properties
  
  var currentUser: User?
  
  var group: Group?
  var user: User?
  var delegate: GroupViewControllerDelegate?
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var totalOwingLabel: UILabel!
  @IBOutlet weak var oweStatusLabel: UILabel!
  
  // MARK: UIViewController methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = group?.name
    tableView.dataSource = self
    tableView.delegate = self
  }
  
  override func viewDidAppear(_ animated: Bool) {
    if let group = group, let currentUser = currentUser {
      
      let sum = group.groupPaidAmountForUser(currentUser)
      totalOwingLabel.text = String(format: "$%.2f", abs(sum))
      
      if sum < 0 {
        totalOwingLabel.textColor = UIColor.red
        oweStatusLabel.text = "You owe:"
      } else {
        totalOwingLabel.textColor = UIColor.green
        oweStatusLabel.text = "You need back:"
      }
    }
  }
  
  // MARK: Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toGroupMembersSegue" {
      if let viewController = segue.destination as? UINavigationController {
        if let groupMembersVC = viewController.topViewController as? GroupMembersViewController {
          groupMembersVC.group = group
        }
      }
    } else if segue.identifier == "toNewTransactionSegue" {
      if let viewController = segue.destination as? UINavigationController {
        if let newTransactionVC = viewController.topViewController as? NewTransactionViewController {
          newTransactionVC.group = group
          newTransactionVC.delegate = self
        }
      }
    } else if segue.identifier == "toEditTransactionSegue" {
      if let viewController = segue.destination as? UINavigationController {
        if let editTransactionVC = viewController.topViewController as? NewTransactionViewController {
          if let transactionCell = sender as? TransactionTableViewCell,
            let selectedRow = tableView.indexPath(for: transactionCell)?.row {
            let transaction = group?.listOfTransactions[selectedRow]
            editTransactionVC.transaction = transaction
            editTransactionVC.group = group
            editTransactionVC.delegate = self
          }
        }
      }
    } else if segue.identifier == "toPayBackSegue" {
      if let viewController = segue.destination as? UINavigationController {
        if let payBackVC = viewController.topViewController as? PayBackViewController {
          payBackVC.group = group
          payBackVC.currentUser = currentUser
          payBackVC.delegate = self
        }
      }
    }
  }
  
}

extension GroupViewController: NewTransactionViewControllerDelegate {
  
  // MARK: NewTransactionViewControllerDelegate methods
  
  func createTransaction(name: String, paidUsers: [String: Double], splitUsers: [String: Double]) {
    group?.createTransaction(name: name, paidUsers: paidUsers, splitUsers: splitUsers) { [weak self] in
      OperationQueue.main.addOperation {
        self?.tableView.reloadData()
      }
    }
  }
  
  func updateTransaction(_ transaction: Transaction, name: String, paidUsers: [String: Double], splitUsers: [String: Double]) {
    group?.updateTransaction(transaction, name: name, paidUsers: paidUsers, splitUsers: splitUsers) { [weak self] in
      OperationQueue.main.addOperation {
        self?.tableView.reloadData()
      }
    }
  }
}

extension GroupViewController: PayBackViewControllerDelegate {
  
  // MARK: PayBackViewControllerDelegate methods
  
  func payBackTransaction(name: String, paidUsers: [String: Double], splitUsers: [String: Double], completion: @escaping () -> Void) {
    group?.createTransaction(name: name, paidUsers: paidUsers, splitUsers: splitUsers) { [weak self] in
      OperationQueue.main.addOperation {
        self?.tableView.reloadData()
        completion()
      }
    }
  }
}

extension GroupViewController: UITableViewDelegate {
  
  // MARK: UITableViewDelegate methods
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      group?.deleteTransaction(at: indexPath.row)
      tableView.reloadData()
    }
  }
  
}

extension GroupViewController: UITableViewDataSource {
  
  // MARK: UITableViewDataSource methods
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let group = group {
      return group.listOfTransactions.count
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as? TransactionTableViewCell else {
      return UITableViewCell()
    }
    
    cell.currentUser = currentUser
    cell.transaction = group?.listOfTransactions[indexPath.row]
    cell.configureCell()
    
    return cell
  }
  
  
}
