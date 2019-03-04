//
//  Transaction.swift
//  Money.io
//
//  Created by Jun Oh on 2019-03-03.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

class Transaction {
  
  // MARK: Properties
  
  let uid: Int
  
  var name: String
  var amount: Double
  var paidUser: User
  var splitUsers: [User]
  
  static private var transactionCount = 0
  
  // MARK: Initializers
  
  init(name: String, amount: Double, paidUser: User, splitUsers: [User]) {
    self.name = name
    self.amount = amount
    self.paidUser = paidUser
    self.splitUsers = splitUsers
    
    self.uid = Transaction.transactionCount
    Transaction.transactionCount += 1
  }
}
