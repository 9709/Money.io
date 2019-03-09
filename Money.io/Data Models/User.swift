//
//  User.swift
//  Money.io
//
//  Created by Matthew Chan on 2019-03-02.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

class User {
  
  // MARK: Properties
  
  var uid: String
  var name: String
  
  var email: String?
  var groups: [Group]?

  // MARK: Initializers
  
  init(uid: String, name: String) {
    self.uid = uid
    self.name = name
  }
  
  // MARK: User methods
  
  func createGroup(name: String, completion: @escaping () -> Void) {
    DataManager.createGroup(name: name) { [weak self] (group) in
      if let group = group {
        if self?.groups != nil {
          self?.groups?.append(group)
        } else {
          self?.groups = [group]
        }
        completion()
      }
    }
    
  }
}

