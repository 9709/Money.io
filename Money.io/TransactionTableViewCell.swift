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
    
    var transaction: Transaction?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var borrowedLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    
    
    // MARK: TransactionTableViewCell methods
    
    func configureCell() {
        if let transaction = transaction {
            
            nameLabel.text = transaction.name
            
            var transactionAmount = transaction.amount
            let selfIsPaidUser = transaction.paidUser.uid == GlobalVariables.singleton.currentUser.uid
            let selfIsSplitUser = transaction.splitUsers.contains(where: {(user) -> Bool in user.uid == GlobalVariables.singleton.currentUser.uid})
            let numSplit = transaction.splitUsers.count
            let splitAmount = transaction.amount / Double(numSplit)
            if selfIsPaidUser {
                if transaction.name.contains("Paid back:") {
                    borrowedLabel.text = "\(transaction.splitUsers)"
                    
                    amountLabel.text = String(format: "$%.2f", abs(transactionAmount))
                    amountLabel.textColor = UIColor.black
                    
                } else if transaction.name.contains("Took back from:") {
                    borrowedLabel.text = "\(transaction.paidUser)"
                    
                    amountLabel.text = String(format: "$%.2f", abs(transactionAmount))
                    amountLabel.textColor = UIColor.black
                    
                } else {
                    borrowedLabel.text = "You lent out"
                    borrowedLabel.textColor = UIColor.green
                    
                    transactionAmount = selfIsSplitUser ? -1.00 * transaction.amount + splitAmount : transaction.amount * -1.00
                    amountLabel.text = String(format: "$%.2f", abs(transactionAmount))
                    amountLabel.textColor = UIColor.green
                }
            } else if selfIsSplitUser {
                borrowedLabel.text = "You borrowed"
                borrowedLabel.textColor = UIColor.red
                
                amountLabel.text = String(format: "$%.2f", splitAmount)
                amountLabel.textColor = UIColor.red
            } else {
                borrowedLabel.text = ""
                
                amountLabel.text = "Not Involved"
                amountLabel.textColor = UIColor.gray
            }
        }
    }
    
}

