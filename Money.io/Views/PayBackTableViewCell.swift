//
//  PayBackTableViewCell.swift
//  Money.io
//
//  Created by Matthew Chan on 2019-03-04.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

class PayBackTableViewCell: UITableViewCell {
    
    var user: User?
    
    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var owingLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    
    
    func configureCell() {
        if let user = user {
            memberLabel.text = user.name
            amountLabel.text = String(format: "$%.2f", abs(user.amountOwing))
            let amountOwing = user.amountOwing
            
            switch amountOwing {
            case let x where x > 0:
                owingLabel.text = "Pay back"
                owingLabel.textColor = UIColor.red
                
                amountLabel.text = String(format: "$%.2f", abs(user.amountOwing))
                amountLabel.textColor = UIColor.red
                
            case let x where x < 0:
                owingLabel.text = "Need back"
                owingLabel.textColor = UIColor.green
                
                amountLabel.text = String(format: "$%.2f", abs(user.amountOwing))
                amountLabel.textColor = UIColor.green
                
            default:
                owingLabel.text = ""
                
                amountLabel.text = "Not Involved"
                amountLabel.textColor = UIColor.gray
            }
        }
    }
    
}
