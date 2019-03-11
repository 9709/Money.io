//
//  PayBackAmountViewController.swift
//  Money.io
//
//  Created by Matthew Chan on 2019-03-05.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

protocol PayBackAmountViewControllerDelegate {
  func payBackTransaction(name: String, paidUsers: [String: Double], splitUsers: [String: Double], owingAmountPerUser: [String: Double])
}



class PayBackAmountViewController: UIViewController {
  
  @IBOutlet weak var payBackMemberLabel: UILabel!
  @IBOutlet weak var payBackAmountTextfield: UITextField!
  
  
  
  
  // MARK: Properties
  
  var user: User?
  var group: Group?
  var currentUser: User?
  var memberName: String = ""
  
  var delegate: PayBackAmountViewControllerDelegate?
  
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    group = GlobalVariables.singleton.currentGroup
    currentUser = GlobalVariables.singleton.currentUser
    if let user = user, let currentUser = currentUser, let group = group {
      memberName = user.name
      let amountOwing = group.owingAmountForUser(currentUser, owingToUser: user)
      if amountOwing > 0 {
        payBackMemberLabel.text = "Pay \(memberName) back:"
      } else {
        payBackMemberLabel.text = "Taking back from \(memberName) :"
      }
    }
  }
  
  deinit {
    group = nil
    currentUser = nil
    user = nil
    delegate = nil
  }
  
  
  
  
  // MARK: Action
  
  @IBAction func cancel(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func save(_ sender: UIBarButtonItem) {
    if let user = user, let currentUser = currentUser, let group = group {
      let amountOwing = group.owingAmountForUser(currentUser, owingToUser: user)
      if amountOwing > 0 {
        if let amountString = payBackAmountTextfield.text, let amount = Double(amountString) {
          let name = "Paid back: \(memberName)"
          let paidUsers = [currentUser.uid: amount]
          let splitUsers = [user.uid: amount]
          let owingAmountPerUser = [currentUser.uid: 0 - amount, user.uid: amount]
          delegate?.payBackTransaction(name: name, paidUsers: paidUsers, splitUsers: splitUsers, owingAmountPerUser: owingAmountPerUser)
          dismiss(animated: true, completion: nil)
        }
      } else {
        if let amountString = payBackAmountTextfield.text, let amount = Double(amountString) {
          let name = "Took back from: \(memberName)"
          let paidUsers = [user.uid: amount]
          let splitUsers = [currentUser.uid: amount]
          let owingAmountPerUser = [currentUser.uid: amount, user.uid: 0 - amount]
          delegate?.payBackTransaction(name: name, paidUsers: paidUsers, splitUsers: splitUsers, owingAmountPerUser: owingAmountPerUser)
          dismiss(animated: true, completion: nil)
        }
      }
    }
  }
  
}
