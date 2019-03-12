//
//  PayBackAmountViewController.swift
//  Money.io
//
//  Created by Matthew Chan on 2019-03-05.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

protocol PayBackAmountViewControllerDelegate {
  func payBackTransaction(name: String, paidUsers: [String: Double], splitUsers: [String: Double], owingAmountPerUser: [String: Double], completion: @escaping (_ success: Bool) -> Void)
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
    guard let user = user, let currentUser = currentUser, let group = group else {
      // NOTE: Alert user something has gone wrong
      return
    }
    guard let amountString = payBackAmountTextfield.text, let amount = Double(amountString) else {
      // NOTE: Alert user for missing amount
      return
    }
    let amountOwing = group.owingAmountForUser(currentUser, owingToUser: user)
    
    let name = (amountOwing > 0) ? "Paid back: \(memberName)" : "Took back from: \(memberName)"
    let paidUsers = (amountOwing > 0) ? [currentUser.uid: amount] : [user.uid: amount]
    let splitUsers = (amountOwing > 0) ? [user.uid: amount] : [currentUser.uid: amount]
    let owingAmountPerUser = (amountOwing > 0) ? [currentUser.uid: 0 - amount, user.uid: amount] : [currentUser.uid: amount, user.uid: 0 - amount]
    delegate?.payBackTransaction(name: name, paidUsers: paidUsers, splitUsers: splitUsers, owingAmountPerUser: owingAmountPerUser) { (success: Bool) in
      if success {
        self.dismiss(animated: true, completion: nil)
      } else {
        // NOTE: Alert user for unsuccessful creation of payback
      }
    }
    showSpinner()
  }
  
  // MARK: Private helper methods
  
  private func showSpinner() {
    let spinner = UIActivityIndicatorView(style: .gray)
    spinner.translatesAutoresizingMaskIntoConstraints = false
    spinner.startAnimating()
    view.addSubview(spinner)
    spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
  }
}
