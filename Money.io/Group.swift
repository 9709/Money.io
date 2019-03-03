//
//  Group.swift
//  Money.io
//
//  Created by Matthew Chan on 2019-03-02.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

class Group {
  
  
  // MARK: Properties
  
  var listOfUsers: [User] = []
  var name: String
  let uid: Int
  static private var groupCount = 0

  // MARK: Initializers
  
  init(name: String) {
    self.name = name
    self.uid = Group.groupCount
    Group.groupCount += 1
  }
  
  // MARK: Group methods
  
  func addUser(name: String) {
    let user = User(name: name)
    listOfUsers.append(user)
  }
  
  func editUser(uid: Int, name: String) {
    for user in listOfUsers {
      if user.uid == uid {
        user.name = name
        break
      }
    }
  }
  
  func deleteUser(at index: Int) {
    listOfUsers.remove(at: index)
  }
  
  func findUserName(from uid: Int) -> String {
    for user in listOfUsers {
      if user.uid == uid {
        return user.name
      }
    }
    
    return ""
  }
  
}
