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
    currentUser = GlobalVariables.singleton.currentUser
    group = GlobalVariables.singleton.currentGroup
    if let user = user, let currentUser = currentUser, let group = group {
      memberLabel.text = user.name
      let amountOwing = group.owingAmountForUser(currentUser, owingToUser: user)
      
      switch amountOwing {
      case let x where x > 0:
        owingLabel.text = "Pay back"
        owingLabel.textColor = .red
        
        amountLabel.text = String(format: "$%.2f", abs(amountOwing))
        amountLabel.textColor = .red
        
      case let x where x < 0:
        owingLabel.text = "Need back"
        owingLabel.textColor = .green
        
        amountLabel.text = String(format: "$%.2f", abs(amountOwing))
        amountLabel.textColor = .green
        
      default:
        owingLabel.text = ""
        
        amountLabel.text = "Not Involved"
        amountLabel.textColor = .gray
      }
    }
  }
  
  override func prepareForReuse() {
    group = nil
    currentUser = nil
    user = nil
    memberLabel.text = ""
    owingLabel.text = ""
    owingLabel.textColor = .black
    amountLabel.text = ""
    amountLabel.textColor = .black
  }
  
}
