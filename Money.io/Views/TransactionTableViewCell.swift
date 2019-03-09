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
    if let transaction = transaction, let currentUser = currentUser {
      
      nameLabel.text = transaction.name
      
      if let userAmount = transaction.userAmount(user: currentUser) {
        if userAmount < 0 {
          borrowedLabel.text = "You borrowed"
          borrowedLabel.textColor = UIColor.red
          
          amountLabel.text = String(format: "$%.2f", abs(userAmount))
          amountLabel.textColor = UIColor.red
        } else {
          borrowedLabel.text = "You lent out"
          borrowedLabel.textColor = UIColor.green
          
          amountLabel.text = String(format: "$%.2f", abs(userAmount))
          amountLabel.textColor = UIColor.green
        }
      } else {
        borrowedLabel.text = ""
        
        amountLabel.text = "Not Involved"
        amountLabel.textColor = UIColor.gray
      }
//        if transaction.name.contains("Paid back:") {
//          borrowedLabel.text = ""
//
//          amountLabel.text = String(format: "$%.2f", abs(transactionAmount))
//          amountLabel.textColor = UIColor.red
//
//        } else if transaction.name.contains("Took back from:") {
//          borrowedLabel.text = ""
//
//          amountLabel.text = String(format: "$%.2f", abs(transactionAmount))
//          amountLabel.textColor = UIColor.green
//
//        }
      
    }
  }
  
}

