//
//  NewTransactionViewController.swift
//  Money.io
//
//  Created by Jun Oh on 2019-03-03.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

protocol NewTransactionViewControllerDelegate {
  func createTransaction(name: String, paidUsers: [String: Double], splitUsers: [String: Double])
  func updateTransaction(_ transaction: Transaction, name: String, paidUsers: [String: Double], splitUsers: [String: Double])
}



class NewTransactionViewController: UIViewController {
  
  // MARK: Properties
  
  var group: Group?
  
  var paidByUsers: [User]?
  var splitBetweenUsers: [User]?
  var transaction: Transaction?
  
  var delegate: NewTransactionViewControllerDelegate?
  
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var amountTextField: UITextField!
  @IBOutlet weak var paidByButton: UIButton!
  @IBOutlet weak var splitBetweenButton: UIButton!
  
  
  
  
  // MARK: UIViewController methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    if let transaction = transaction {
      nameTextField.text = transaction.name
      amountTextField.text = String(format: "%.2f", transaction.totalAmount)
      
      var allUsersString = ""
      for userUID in transaction.paidUsers {
        if let user = group?.getUser(from: userUID.key) {
          allUsersString.append("\(user.name), ")
        }
      }
      allUsersString = allUsersString.trimmingCharacters(in: CharacterSet.letters.inverted)
      let title = NSAttributedString(string: allUsersString)
      paidByButton.setAttributedTitle(title, for: .normal)

      allUsersString = ""
      for userUID in transaction.splitUsers {
        if let user = group?.getUser(from: userUID.key) {
          allUsersString.append("\(user.name), ")
        }
      }
      allUsersString = allUsersString.trimmingCharacters(in: CharacterSet.letters.inverted)
      let splitTitle = NSAttributedString(string: allUsersString)
      splitBetweenButton.setAttributedTitle(splitTitle, for: .normal)

      navigationItem.title = "Edit Transaction"
    } else {
      navigationItem.title = "Add Transaction"
    }
    
  }
  
  // MARK: Actions
  
  @IBAction func cancel(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func save(_ sender: UIBarButtonItem) {
    if let transaction = transaction {
      var name = transaction.name
      if let newName = nameTextField.text {
        name = newName
      }
      
      guard let amountString = amountTextField.text, let amount = Double(amountString) else {
        print("Nothing to split")
        return
      }
      
      guard amount != 0 else {
        print("You can't split 0")
        return
      }
      
      var paidUsers = transaction.paidUsers
      if let paidByUsers = paidByUsers {
        guard paidByUsers.count > 0 else {
          print("Someone has to pay")
          return
        }
        
        paidUsers = [:]
        for user in paidByUsers {
          paidUsers[user.uid] = amount / Double(paidByUsers.count)
        }
      }
      
      var splitUsers = transaction.splitUsers
      if let splitBetweenUsers = splitBetweenUsers {
        guard splitBetweenUsers.count > 0 else {
          print("Someone has to pay")
          return
        }
        
        splitUsers = [:]
        for user in splitBetweenUsers {
          splitUsers[user.uid] = amount / Double(splitBetweenUsers.count)
        }
      }
      
      if amount != transaction.totalAmount && (paidByUsers == nil && splitBetweenUsers == nil) {
        for user in paidUsers {
          paidUsers[user.key] = amount / Double(paidUsers.count)
        }
        for user in splitUsers {
          splitUsers[user.key] = amount / Double(splitUsers.count)
        }
      }
      
      // If any value is different, update, otherwise, do not update
      if name != transaction.name ||
        paidUsers != transaction.paidUsers ||
        splitUsers != transaction.splitUsers {
        delegate?.updateTransaction(transaction, name: name, paidUsers: paidUsers, splitUsers: splitUsers)
      }
      dismiss(animated: true, completion: nil)
    } else {
      if let name = nameTextField.text,
        let amountString = amountTextField.text, let amount = Double(amountString),
        let paidByUsers = paidByUsers,
        let splitBetweenUsers = splitBetweenUsers {
        
        guard amount != 0 && paidByUsers.count > 0 && splitBetweenUsers.count > 0 else {
          print("Someone has to pay and someone has to borrow")
          return
        }
        
        var paidUsers: [String: Double] = [:]
        for user in paidByUsers {
          paidUsers[user.uid] = amount / Double(paidByUsers.count)
        }
        
        var splitUsers: [String: Double] = [:]
        for user in splitBetweenUsers {
          splitUsers[user.uid] = amount / Double(splitBetweenUsers.count)
        }
        
        delegate?.createTransaction(name: name, paidUsers: paidUsers, splitUsers: splitUsers)
        dismiss(animated: true, completion: nil)
      }
    }
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
