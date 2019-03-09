//
//  PayBackTableViewCell.swift
//  Money.io
//
//  Created by Matthew Chan on 2019-03-04.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

class PayBackTableViewCell: UITableViewCell {
  
  // MARK: Properties
  
  var group: Group?
  var currentUser: User?
  var user: User?
  
  @IBOutlet weak var memberLabel: UILabel!
  @IBOutlet weak var owingLabel: UILabel!
  @IBOutlet weak var amountLabel: UILabel!
  
  // MARK: PayBackTableViewCell methods
  
  func configureCell() {
    if let user = user, let currentUser = currentUser, let group = group {
      memberLabel.text = user.name
      let amountOwing = group.owingAmountForUser(currentUser, owingToUser: user)
      
      switch amountOwing {
      case let x where x > 0:
        owingLabel.text = "Pay back"
        owingLabel.textColor = UIColor.red
        
        amountLabel.text = String(format: "$%.2f", abs(amountOwing))
        amountLabel.textColor = UIColor.red
        
      case let x where x < 0:
        owingLabel.text = "Need back"
        owingLabel.textColor = UIColor.green
        
        amountLabel.text = String(format: "$%.2f", abs(amountOwing))
        amountLabel.textColor = UIColor.green
        
      default:
        owingLabel.text = ""
        
        amountLabel.text = "Not Involved"
        amountLabel.textColor = UIColor.gray
      }
    }
  }
  
}
