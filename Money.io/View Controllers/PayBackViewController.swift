//
//  PayBackViewController.swift
//  Money.io
//
//  Created by Matthew Chan on 2019-03-04.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

protocol PayBackViewControllerDelegate {
  func payBackTransaction(name: String, paidUsers: [String: Double], splitUsers: [String: Double], completion: @escaping () -> Void)
}


class PayBackViewController: UIViewController {
  
  // MARK: Properties
  
  var group: Group?
  var currentUser: User?
  var user: User?
  var payBackUsers: [User] = []
  
  var delegate: PayBackViewControllerDelegate?
  
  @IBOutlet weak var tableView: UITableView!
  
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let group = group, let currentUser = currentUser {
      for user in group.listOfUsers {
        if user.uid == currentUser.uid {
          continue
        }
        payBackUsers.append(user)
      }
    }
    
    tableView.dataSource = self
  }
  
  
  
  
  // MARK: Actions
  
  @IBAction func cancel(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }
  
  
  // MARK: Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toPayBackAmountSegue" {
      if let viewController = segue.destination as? UINavigationController,
        let payBackAmountVC = viewController.topViewController as? PayBackAmountViewController {
        if let payBackCell = sender as? PayBackTableViewCell,
          let selectedRow = tableView.indexPath(for: payBackCell)?.row {
          let user = payBackUsers[selectedRow]
          payBackAmountVC.user = user
          payBackAmountVC.currentUser = currentUser
          payBackAmountVC.group = group
          payBackAmountVC.delegate = self
        }
      }
    }
  }
  
}


extension PayBackViewController: UITableViewDataSource {
  
  // MARK: UITableViewDataSource methods
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return payBackUsers.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "PayBackCell", for: indexPath) as? PayBackTableViewCell else {
      return UITableViewCell()
    }
    
    cell.group = group
    cell.currentUser = currentUser
    cell.user = payBackUsers[indexPath.row]
    cell.configureCell()
    
    return cell
  }
}



extension PayBackViewController: PayBackAmountViewControllerDelegate {
  
  func payBackTransaction(name: String, paidUsers: [String: Double], splitUsers: [String: Double]) {
    delegate?.payBackTransaction(name: name, paidUsers: paidUsers, splitUsers: splitUsers) { [weak self] in
      OperationQueue.main.addOperation {
        self?.tableView.reloadData()
      }
    }
  }
}
