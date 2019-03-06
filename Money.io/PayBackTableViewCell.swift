//
//  PayBackTableViewCell.swift
//  Money.io
//
//  Created by Matthew Chan on 2019-03-04.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

class PayBackTableViewCell: UITableViewCell {
    
    var group: Group!
    var user: User?
    
    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var owingLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    
    
    func configureCell() {
        let currentUser = GlobalVariables.singleton.currentUser
        if let user = user {
            memberLabel.text = user.name
            amountLabel.text = String(format: "$%.2f", abs(user.amountOwing))
            
            if user.amountOwing > 0 {
                owingLabel.text = "Pay back"
                owingLabel.textColor = UIColor.red
                
                amountLabel.text = String(format: "$%.2f", abs(user.amountOwing))
                amountLabel.textColor = UIColor.red
            } else if user.amountOwing == 0 {
                owingLabel.text = ""
                
                amountLabel.text = "Not Involved"
                amountLabel.textColor = UIColor.gray
            } else {
                owingLabel.text = "Need back"
                owingLabel.textColor = UIColor.green
                
                amountLabel.text = String(format: "$%.2f", abs(user.amountOwing))
                amountLabel.textColor = UIColor.green
            }
            if user.uid == currentUser?.uid {
                amountLabel.text = "me"
                amountLabel.textColor = UIColor.gray
            }
        }
    }
    
}
