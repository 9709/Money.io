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
        if let user = user {
            memberLabel.text = user.name
            amountLabel.text = String(format: "$%.2f", user.amountOwing)
        }
    }
    
}
