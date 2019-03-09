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
  
  var uid: String
  var name: String
  
  var listOfUsers: [User] = []
  var listOfTransactions: [Transaction] = []

  // MARK: Initializers
  
  init(uid: String, name: String) {
    self.uid = uid
    self.name = name
  }
  
  // MARK: Group User methods
  
  func addUser(email: String, completion: @escaping () -> Void) {
    DataManager.addUser(email: email, to: self) { [weak self] (user) in
      if let user = user {
        self?.listOfUsers.append(user)
        completion()
      }
    }
  }
  
  func deleteUser(at index: Int) {
    listOfUsers.remove(at: index)
  }
  
  // MARK: Group Transaction methods
  
  func createTransaction(name: String, details: [String: Double], completion: @escaping () -> Void) {
    DataManager.createTransaction(name: name, details: details, to: self) { [weak self] transaction in
      self?.listOfTransactions.insert(transaction, at: 0)
      completion()
    }
  }

  func deleteTransaction(at index: Int) {
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
