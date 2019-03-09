//
//  NewTransactionViewController.swift
//  Money.io
//
//  Created by Jun Oh on 2019-03-03.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

protocol NewTransactionViewControllerDelegate {
  func createTransaction(name: String, details: [String: Double])
  func updateTransaction()
}



class NewTransactionViewController: UIViewController {
  
  // MARK: Properties
  
  var group: Group?
  
  var paidByUsers: [User]?
  var splitBetweenUsers: [User]?
//  var transaction: Transaction?
  
  var delegate: NewTransactionViewControllerDelegate?
  
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var amountTextField: UITextField!
  @IBOutlet weak var paidByButton: UIButton!
  @IBOutlet weak var splitBetweenButton: UIButton!
  
  
  
  
  // MARK: UIViewController methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
//    if let transaction = transaction {
//      nameTextField.text = transaction.name
//      amountTextField.text = String(format: "%.2f", transaction.amount)
//
//      let paidByMember = transaction.paidUser
//      let title = NSAttributedString(string: paidByMember.name)
//      paidByButton.setAttributedTitle(title, for: .normal)
//
//      let splitBetweenMembers = transaction.splitUsers
//      var allUsersString = ""
//      for member in splitBetweenMembers {
//        allUsersString.append("\(member.name), ")
//      }
//      allUsersString = allUsersString.trimmingCharacters(in: CharacterSet.letters.inverted)
//      let splitTitle = NSAttributedString(string: allUsersString)
//      splitBetweenButton.setAttributedTitle(splitTitle, for: .normal)
//
//      navigationItem.title = "Edit Transaction"
//    } else {
      navigationItem.title = "Add Transaction"
//    }
    
  }
  
  // MARK: Actions
  
  @IBAction func cancel(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func save(_ sender: UIBarButtonItem) {
//    if var transaction = transaction {
//      if let name = nameTextField.text {
//        transaction.name = name
//      }
//      if let amountString = amountTextField.text, let amount = Double(amountString) {
//        transaction.amount = amount
//      }
//      if let paidUser = paidByMember {
//        transaction.paidUser = paidUser
//      }
//      if let splitUsers = splitBetweenMembers {
//        transaction.splitUsers = splitUsers
//      }
//      delegate?.updateTransaction()
//    } else {
      if let name = nameTextField.text,
        let amountString = amountTextField.text, let amount = Double(amountString),
        let paidUsers = paidByUsers,
        let splitUsers = splitBetweenUsers {
        
        var transactionDetails: [String: Double] = [:]
        for user in paidUsers {
          transactionDetails[user.uid] = amount / Double(paidUsers.count)
        }
        
        for user in splitUsers {
          if transactionDetails.keys.contains(user.uid), let paidAmount = transactionDetails[user.uid] {
            transactionDetails[user.uid] = paidAmount - amount / Double(splitUsers.count)
          } else {
            transactionDetails[user.uid] = 0 - amount / Double(splitUsers.count)
          }
        }
        
        delegate?.createTransaction(name: name, details: transactionDetails)
      }
      dismiss(animated: true, completion: nil)
//    }
  }
  // MARK: Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toPaidBySegue" {
      if let viewController = segue.destination as? UINavigationController {
        if let paidByVC = viewController.topViewController as? SplitBetweenViewController {
          paidByVC.users = paidByUsers
          paidByVC.group = group
          paidByVC.paid = true
          paidByVC.delegate = self
        }
      }
    } else if segue.identifier == "toSplitBetweenSegue" {
      if let viewController = segue.destination as? UINavigationController {
        if let splitBetweenVC = viewController.topViewController as? SplitBetweenViewController {
          splitBetweenVC.users = splitBetweenUsers
          splitBetweenVC.group = group
          splitBetweenVC.paid = false
          splitBetweenVC.delegate = self
        }
      }
    }
  }
  
}





extension NewTransactionViewController: SplitBetweenViewControllerDelegate {
  
  // MARK: SplitBetweenViewControllerDelegate methods
  
  func updateTransactionUsers(users: [User], paid: Bool) {
    var allUsersString = ""
    for user in users {
      allUsersString.append("\(user.name), ")
    }
    allUsersString = allUsersString.trimmingCharacters(in: CharacterSet.letters.inverted)
    let title = NSAttributedString(string: allUsersString)
    
    if paid {
      paidByButton.setAttributedTitle(title, for: .normal)
      paidByUsers = users
    } else {
      splitBetweenButton.setAttributedTitle(title, for: .normal)
      splitBetweenUsers = users
    }
  }
}
