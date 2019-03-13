//
//  TransactionTableViewCell.swift
//  Money.io
//
//  Created by Jun Oh on 2019-03-03.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    var currentUser: User?
    var transaction: Transaction?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var borrowedLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    
    
    // MARK: TransactionTableViewCell methods
    
    func configureCell() {
        let darkGreen = UIColor(red:0, green:0.80, blue:0, alpha:1.0)
        currentUser = GlobalVariables.singleton.currentUser
        guard let transaction = transaction, let currentUser = currentUser else {
            return
        }
        
        nameLabel.text = transaction.name
        
        if let userAmount = transaction.owingAmountPerUser[currentUser.uid] {
            if userAmount > 0 {
                borrowedLabel.text = "You borrowed"
                borrowedLabel.textColor = .red
                
                amountLabel.text = String(format: "$%.2f", abs(userAmount))
                amountLabel.textColor = .red
                
            } else {
                borrowedLabel.text = "You lent out"
                borrowedLabel.textColor = darkGreen
                
                amountLabel.text = String(format: "$%.2f", abs(userAmount))
                amountLabel.textColor = darkGreen
            }
        } else {
            borrowedLabel.text = ""
            
            amountLabel.text = "Not Involved"
            amountLabel.textColor = .gray
        }
        
        if transaction.payback {
            borrowedLabel.text = ""
            amountLabel.textColor = .gray
            
            if let owingAmount = transaction.owingAmountPerUser[currentUser.uid] {
                var nameString = transaction.name
                if owingAmount < 0 {
                    nameString = nameString.replacingOccurrences(of: currentUser.name, with: "You", options: .anchored, range: nil)
                    nameLabel.textColor = .gray
                } else {
                    nameString = nameString.replacingOccurrences(of: "back \(currentUser.name)", with: "you back", options: [.anchored, .backwards], range: nil)
                    nameLabel.textColor = .gray
                }
                nameLabel.text = nameString
            }
        }
        
    }
    
    override func prepareForReuse() {
        currentUser = nil
        transaction = nil
        nameLabel.text = ""
        borrowedLabel.text = ""
        borrowedLabel.textColor = .black
        amountLabel.text = ""
        amountLabel.textColor = .black
    }
    
}

