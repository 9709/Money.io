//
//  Group.swift
//  Money.io
//
//  Created by Matthew Chan on 2019-03-02.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit


struct Group {
  
  
  // MARK: Properties
  
  var listOfUsers: [User] = []
  var listOfTransactions: [Transaction] = []
  var name: String
  var uid: String?

  // MARK: Initializers
  
  init(name: String) {
    self.name = name
  }
  
  // MARK: Group User methods
  
  mutating func addUser(_ user: User) {
    listOfUsers.append(user)
  }
  
  mutating func deleteUser(at index: Int) {
    listOfUsers.remove(at: index)
  }
  
  // MARK: Group Transaction methods
  
  mutating func addTransaction(_ transaction: Transaction) {
    listOfTransactions.insert(transaction, at: 0)
    updateOwningAmountPerMember()
  }

  mutating func deleteTransaction(at index: Int) {
    listOfTransactions.remove(at: index)
    updateOwningAmountPerMember()
  }
  
  
  func updateOwningAmountPerMember() {
//    self.listOfUsers.forEach({(user: User) -> Void in user.amountOwing = 0})
//    let currentUser: User = GlobalVariables.singleton.currentUser;
//    for transaction in self.listOfTransactions {
//      let amountPerPerson = transaction.amount/Double(transaction.splitUsers.count)
//      if currentUser.uid == transaction.paidUser.uid {
//        for user in transaction.splitUsers {
//          if user.uid != currentUser.uid {
//            user.amountOwing -= amountPerPerson
//          }
//        }
//      } else if transaction.splitUsers.contains(where: { (splitUser) -> Bool in
//        splitUser.uid == currentUser.uid
//      }) {
//        transaction.paidUser.amountOwing += amountPerPerson
//      }
//    }
  }
  
}
