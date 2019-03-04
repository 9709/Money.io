//
//  NewTransactionViewController.swift
//  Money.io
//
//  Created by Jun Oh on 2019-03-03.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

protocol NewTransactionViewControllerDelegate {
  func addTransaction(_ transaction: Transaction)
}

class NewTransactionViewController: UIViewController {
  
  // MARK: Properties
  
  var group: Group?
  var paidByMember: User?
  var splitBetweenMembers: [User]?
  
  var delegate: NewTransactionViewControllerDelegate?
  
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var amountTextField: UITextField!
  @IBOutlet weak var paidByButton: UIButton!
  @IBOutlet weak var splitBetweenButton: UIButton!
  
  // MARK: UIViewController methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  // MARK: Actions
  
  @IBAction func cancel(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func save(_ sender: UIBarButtonItem) {
    if let name = nameTextField.text,
      let amountString = amountTextField.text, let amount = Double(amountString),
      let paidUser = paidByMember,
      let splitUsers = splitBetweenMembers {
      let transaction = Transaction(name: name, amount: amount, paidUser: paidUser, splitUsers: splitUsers)
      delegate?.addTransaction(transaction)
    }
    dismiss(animated: true, completion: nil)
  }
  
  // MARK: Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toPaidBySegue" {
      if let viewController = segue.destination as? UINavigationController {
        if let paidByVC = viewController.children[0] as? PaidByViewController {
          paidByVC.user = paidByMember
          paidByVC.group = group
          paidByVC.delegate = self
        }
      }
    } else if segue.identifier == "toSplitBetweenSegue" {
      if let viewController = segue.destination as? UINavigationController {
        if let splitBetweenVC = viewController.children[0] as? SplitBetweenViewController {
          splitBetweenVC.members = splitBetweenMembers
          splitBetweenVC.group = group
          splitBetweenVC.delegate = self
        }
      }
    }
  }
  
}

extension NewTransactionViewController: PaidByViewControllerDelegate {
  
  // MARK: PaidByViewControllerDelegate methods
  
  func updatePaidByMember(user: User) {
    let title = NSAttributedString(string: user.name)
    paidByButton.setAttributedTitle(title, for: .normal)
    paidByMember = user
  }
}

extension NewTransactionViewController: SplitBetweenViewControllerDelegate {
  
  // MARK: SplitBetweenViewControllerDelegate methods
  
  func updateSplitBetweenMembers(members: [User]) {
    var allUsersString = ""
    for member in members {
      allUsersString.append("\(member.name), ")
    }
    allUsersString = allUsersString.trimmingCharacters(in: CharacterSet.letters.inverted)
    let title = NSAttributedString(string: allUsersString)
    splitBetweenButton.setAttributedTitle(title, for: .normal)
    splitBetweenMembers = members
  }
}
