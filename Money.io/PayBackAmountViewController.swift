//
//  PayBackAmountViewController.swift
//  Money.io
//
//  Created by Matthew Chan on 2019-03-05.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

protocol PayBackAmountViewControllerDelegate {
    func payBack()
}

class PayBackAmountViewController: UIViewController {
    
    @IBOutlet weak var payBackMemberLabel: UILabel!
    @IBOutlet weak var payBackAmountTextfield: UITextField!
    
    // MARK: Properties
    
    var user: User?
    
    var delegate: PayBackAmountViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: Action
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        if let user = self.user {
            if let amount = payBackAmountTextfield.text, let inputAmount = Double(amount) {
                user.amountOwing -= inputAmount
            }
            delegate?.payBack()
            dismiss(animated: true, completion: nil)
        }
    }
    
}
