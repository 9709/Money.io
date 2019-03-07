//
//  PayBackAmountViewController.swift
//  Money.io
//
//  Created by Matthew Chan on 2019-03-05.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

protocol PayBackAmountViewControllerDelegate {
    func payBackTransaction(_ transaction: Transaction)
}



class PayBackAmountViewController: UIViewController {
    
    @IBOutlet weak var payBackMemberLabel: UILabel!
    @IBOutlet weak var payBackAmountTextfield: UITextField!
    
    
    
    
    // MARK: Properties
    
    var transaction: Transaction?
    var user: User?
    var memberName: String = ""
    
    var delegate: PayBackAmountViewControllerDelegate?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = user {
            memberName = user.name
            if user.amountOwing > 0 {
                payBackMemberLabel.text = "Pay \(memberName) back:"
            } else {
                payBackMemberLabel.text = "Taking back from \(memberName) :"
            }
        }
    }
    
    
    
    
    // MARK: Action
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        if let user = user {
            if user.amountOwing > 0 {
                if let amountString = payBackAmountTextfield.text, let amount = Double(amountString) {
                    if let currentUser = GlobalVariables.singleton.currentUser {
                        let transaction = Transaction(name: "Paid back: \(memberName)", amount: amount, paidUser: currentUser, splitUsers: [user])
                        delegate?.payBackTransaction(transaction)
                    }
                }
            } else {
                if let amountString = payBackAmountTextfield.text, let amount = Double(amountString) {
                    let negAmount = amount * -1.00
                    if let currentUser = GlobalVariables.singleton.currentUser {
                        let transaction = Transaction(name: "Took back from: \(memberName)", amount: negAmount, paidUser: currentUser, splitUsers: [user])
                        delegate?.payBackTransaction(transaction)
                    }
                }
            }
            dismiss(animated: true, completion: nil)
        }
    }
    
}
