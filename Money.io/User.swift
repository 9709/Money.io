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
  
  var name: String
  var uid: String?
  var groups: [Group]?
  
  // MARK: Initializers
  
  init(name: String) {
    self.name = name
  }
  
  // MARK: User methods
  
  mutating func addGroup(_ group: Group) {
    groups?.append(group)
  }
}
