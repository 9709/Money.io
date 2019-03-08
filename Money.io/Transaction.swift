//
//  Transaction.swift
//  Money.io
//
//  Created by Jun Oh on 2019-03-03.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

struct Transaction {
  
  // MARK: Properties
  
  var name: String
  var amount: Double
  var paidUser: User
  var splitUsers: [User]
  
}

