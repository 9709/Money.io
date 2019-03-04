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
  
  // MARK: UITableViewCell methods
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  // MARK: TransactionTableViewCell methods
  
  func configureCell() {
    if let transaction = transaction {
      nameLabel.text = transaction.name
      amountLabel.text = String(format: "$%.2f", transaction.amount)
    }
  }
  
}
