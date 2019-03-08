//
//  User.swift
//  Money.io
//
//  Created by Matthew Chan on 2019-03-02.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

struct User {
  
  // MARK: Propeerties
  
  var uid: String?
  
  var name: String
  var groups: [Group]?
  var amountOwing: Double = 0

  // MARK: Initializers
  
  init(name: String) {
    self.name = name
  }
  
  // MARK: User methods
  
  mutating func addGroup(_ group: Group) {
    if groups != nil {
      groups?.append(group)
    } else {
      groups = [group]
    }
  }
}

