//
//  NewTransactionViewController.swift
//  Money.io
//
//  Created by Jun Oh on 2019-03-03.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

protocol NewTransactionViewControllerDelegate {
  func createTransaction(name: String, paidUsers: [String: Double], splitUsers: [String: Double], owingAmountPerUser: [String: Double], completion: @escaping (_ success: Bool) -> Void)
  func updateTransaction(_ transaction: Transaction, name: String, paidUsers: [String: Double], splitUsers: [String: Double], owingAmountPerUser: [String: Double], createdTimestamp: Date, payback: Bool, completion: @escaping (_ success: Bool) -> Void)
}



class NewTransactionViewController: UIViewController {
  
  // MARK: Properties
  
  var group: Group?
  
  var paidByUsers: [User]?
  var splitBetweenUsers: [User]?
  var transaction: Transaction?
  
  var delegate: NewTransactionViewControllerDelegate?
  
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var amountTextField: UITextField!
  @IBOutlet weak var paidByButton: UIButton!
  @IBOutlet weak var splitBetweenButton: UIButton!
  
  
  // MARK: UIViewController methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    nameTextField.delegate = self
    amountTextField.delegate = self
    
    group = GlobalVariables.singleton.currentGroup
    if let transaction = transaction {
      nameTextField.text = transaction.name
      amountTextField.text = String(format: "%.2f", transaction.totalAmount)
    
      let paidUserString = listMultipleUserNames(from: [String](transaction.paidAmountPerUser.keys))
      let paidTitle = NSAttributedString(string: paidUserString)
      paidByButton.setAttributedTitle(paidTitle, for: .normal)

      paidByUsers = []
      for userUID in [String](transaction.paidAmountPerUser.keys) {
        if let user = group?.getUser(from: userUID) {
          paidByUsers?.append(user)
        }
      }
      
      let splitUserString = listMultipleUserNames(from: [String](transaction.splitAmountPerUser.keys))
      let splitTitle = NSAttributedString(string: splitUserString)
      splitBetweenButton.setAttributedTitle(splitTitle, for: .normal)
      
      splitBetweenUsers = []
      for userUID in [String](transaction.splitAmountPerUser.keys) {
        if let user = group?.getUser(from: userUID) {
          splitBetweenUsers?.append(user)
        }
      }

      if transaction.payback {
        nameTextField.isEnabled = false
        paidByButton.isEnabled = false
        paidByButton.tintColor = .gray
        splitBetweenButton.isEnabled = false
        splitBetweenButton.tintColor = .gray
      }
        titleLabel.text = "Edit Transaction"
    } else {
        titleLabel.text = "Add Transaction"
    }
    
    let toolbar: UIToolbar = UIToolbar()
    toolbar.barStyle = .default
    toolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
                     UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard(_:)))]
    toolbar.sizeToFit()
    amountTextField.inputAccessoryView = toolbar
  }
  
  deinit {
    group = nil
    paidByUsers = nil
    splitBetweenUsers = nil
    transaction = nil
    delegate = nil
  }
  
    // MARK: Dismiss keyboard
    
    @objc func dismissKeyboard(_ sender: UIBarButtonItem) {
        nameTextField.resignFirstResponder()
        amountTextField.resignFirstResponder()
    }
    
  // MARK: Actions
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: UIButton) {
        if let transaction = transaction {
            var name = transaction.name
            if let newName = nameTextField.text {
                guard newName != "" else {
                    // NOTE: Alert user for empty name
                    return
                }
                name = newName
            }
            
            guard let amountString = amountTextField.text, let amount = Double(amountString) else {
                print("Nothing to split")
                // NOTE: Alert user for empty amount
                return
            }
            
            guard amount > 0 else {
                print("You can't split 0 or negative amount")
                // NOTE: Alert user for 0 amount or negative amount
                return
            }
            
            var paidUserUIDAndAmount = transaction.paidAmountPerUser
            if let paidByUsers = paidByUsers {
                guard paidByUsers.count > 0 else {
                    print("Someone has to pay")
                    // NOTE: Alert user for empty paid users
                    return
                }
                
                paidUserUIDAndAmount = [:]
                for user in paidByUsers {
                    paidUserUIDAndAmount[user.uid] = amount / Double(paidByUsers.count)
                }
            }
            
            var splitUserUIDAndAmount = transaction.splitAmountPerUser
            if let splitBetweenUsers = splitBetweenUsers {
                guard splitBetweenUsers.count > 0 else {
                    print("Someone has to pay")
                    // NOTE: Alert user for empty split users
                    return
                }
                
                splitUserUIDAndAmount = [:]
                for user in splitBetweenUsers {
                    splitUserUIDAndAmount[user.uid] = amount / Double(splitBetweenUsers.count)
                }
            }
            
            if amount != transaction.totalAmount && (paidByUsers == nil && splitBetweenUsers == nil) {
                for user in paidUserUIDAndAmount {
                    paidUserUIDAndAmount[user.key] = amount / Double(paidUserUIDAndAmount.count)
                }
                for user in splitUserUIDAndAmount {
                    splitUserUIDAndAmount[user.key] = amount / Double(splitUserUIDAndAmount.count)
                }
            }
            
            var totalOwingAmountPerUser: [String: Double] = [:]
            for (userUID, paidAmount) in paidUserUIDAndAmount {
                totalOwingAmountPerUser[userUID] = 0 - paidAmount
            }
            
            for (userUID, owingAmount) in splitUserUIDAndAmount {
                if paidUserUIDAndAmount.keys.contains(userUID), let oldAmount = totalOwingAmountPerUser[userUID] {
                    totalOwingAmountPerUser[userUID] = owingAmount + oldAmount
                } else {
                    totalOwingAmountPerUser[userUID] = owingAmount
                }
            }
            
            let createdTimestamp = transaction.createdTimestamp
            let payback = transaction.payback
            
            // If any value is different, update, otherwise, do not update
            if name != transaction.name ||
                paidUserUIDAndAmount != transaction.paidAmountPerUser ||
                splitUserUIDAndAmount != transaction.splitAmountPerUser {
                delegate?.updateTransaction(transaction, name: name, paidUsers: paidUserUIDAndAmount, splitUsers: splitUserUIDAndAmount, owingAmountPerUser: totalOwingAmountPerUser, createdTimestamp: createdTimestamp, payback: payback) { (success: Bool) in
                    if success {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        // NOTE: Alert the user for the unsuccessful creation of transaction
                    }
                }
                showSpinner()
            } else {
                dismiss(animated: true, completion: nil)
            }
        } else {
            if let name = nameTextField.text,
                let amountString = amountTextField.text, let amount = Double(amountString),
                let paidByUsers = paidByUsers,
                let splitBetweenUsers = splitBetweenUsers {
                
                guard amount > 0 && paidByUsers.count > 0 && splitBetweenUsers.count > 0 else {
                    print("Someone has to pay and someone has to borrow")
                    // NOTE: Alert user for empty amount, paid users, or split users
                    return
                }
                
                var totalOwingAmountPerUser: [String: Double] = [:]
                
                var paidUserUIDAndAmount: [String: Double] = [:]
                for user in paidByUsers {
                    paidUserUIDAndAmount[user.uid] = amount / Double(paidByUsers.count)
                    
                    totalOwingAmountPerUser[user.uid] = 0 - amount / Double(paidByUsers.count)
                }
                
                var splitUserUIDAndAmount: [String: Double] = [:]
                for user in splitBetweenUsers {
                    splitUserUIDAndAmount[user.uid] = amount / Double(splitBetweenUsers.count)
                    
                    if paidUserUIDAndAmount.keys.contains(user.uid), let oldAmount = totalOwingAmountPerUser[user.uid] {
                        totalOwingAmountPerUser[user.uid] = amount / Double(splitBetweenUsers.count) + oldAmount
                    } else {
                        totalOwingAmountPerUser[user.uid] = amount / Double(splitBetweenUsers.count)
                    }
                }
                
                // Delegate will dissmiss the view
                delegate?.createTransaction(name: name, paidUsers: paidUserUIDAndAmount, splitUsers: splitUserUIDAndAmount, owingAmountPerUser: totalOwingAmountPerUser) { (success: Bool) in
                    if success {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        // NOTE: Alert the user for the unsuccessful creation of transaction
                    }
                }
                showSpinner()
            } else {
                // NOTE: Alert user for empty name, amount, paid users, or split users
            }
        }
    }

  
  // MARK: Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toPaidBySegue" {
      if let viewController = segue.destination as? UINavigationController,
        let paidByVC = viewController.topViewController as? SplitBetweenViewController {
        paidByVC.users = paidByUsers
        paidByVC.paid = true
        paidByVC.delegate = self
      }
    } else if segue.identifier == "toSplitBetweenSegue" {
      if let viewController = segue.destination as? UINavigationController,
        let splitBetweenVC = viewController.topViewController as? SplitBetweenViewController {
        splitBetweenVC.users = splitBetweenUsers
        splitBetweenVC.paid = false
        splitBetweenVC.delegate = self
      }
    }
  }
  
  // MARK: Private helper methods
  
  private func listMultipleUserNames(from userUIDs: [String]) -> String {
    var allUsersString = ""
    for userUID in userUIDs {
      if let user = group?.getUser(from: userUID) {
        allUsersString.append("\(user.name), ")
      }
    }
    allUsersString = allUsersString.trimmingCharacters(in: CharacterSet.letters.inverted)
    return allUsersString
  }
  
  private func showSpinner() {
    let spinner = UIActivityIndicatorView(style: .gray)
    spinner.translatesAutoresizingMaskIntoConstraints = false
    spinner.startAnimating()
    view.addSubview(spinner)
    spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
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


extension NewTransactionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        amountTextField.resignFirstResponder()
        return true
    }
}
