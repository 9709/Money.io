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
  
  var listOfOwingAmounts: [String: Double] = [:]
  var listOfUsers: [User] = []
  var listOfTransactions: [Transaction] = []

  // MARK: Initializers
  
  init(uid: String, name: String) {
    self.uid = uid
    self.name = name
  }
  
  // MARK: Group User methods
  
  func addUser(email: String, completion: @escaping (_ success: Bool) -> Void) {
    DataManager.addUser(email: email, to: self) { (user) in
      if let user = user {
        self.listOfUsers.append(user)
        self.listOfOwingAmounts[user.uid] = 0
        completion(true)
      } else {
        completion(false)
      }
    }
  }
  
  func getUser(from uid: String) -> User? {
    for user in listOfUsers {
      if user.uid == uid {
        return user
      }
    }
    return nil
  }
  
  func deleteUser(at index: Int) {
    listOfUsers.remove(at: index)
  }
  
  // MARK: Group Transaction methods
  
  func createTransaction(name: String, paidUsers: [String: Double], splitUsers: [String: Double], owingAmountPerUser: [String: Double], completion: @escaping (_ success: Bool) -> Void) {
    DataManager.createTransaction(name: name, paidUsers: paidUsers, splitUsers: splitUsers, owingAmountPerUser: owingAmountPerUser, to: self) { (transaction: Transaction?) in
      if let transaction = transaction {
        self.listOfTransactions.insert(transaction, at: 0)
        completion(true)
      } else {
        completion(false)
      }
      
    }
  }
  
  func updateTransaction(_ transaction: Transaction, name: String, paidUsers: [String: Double], splitUsers: [String: Double], owingAmountPerUser: [String: Double], completion: @escaping (_ success: Bool) -> Void) {
    DataManager.updateTransaction(uid: transaction.uid, name: name, paidUsers: paidUsers, splitUsers: splitUsers, owingAmountPerUser: owingAmountPerUser, to: self) { (transaction: Transaction?) in
      if let transaction = transaction {
        for index in 0..<self.listOfTransactions.count {
          if self.listOfTransactions[index].uid == transaction.uid {
            self.listOfTransactions[index] = transaction
            completion(true)
          }
        }
        completion(false)
      } else {
        completion(false)
      }
    }
  }

  func deleteTransaction(at index: Int) {
    listOfTransactions.remove(at: index)
    updateOwningAmountPerMember()
  }
  
  func groupOwingAmountForUser(_ user: User) -> Double {
    var totalOwingAmount: Double = 0
    for transaction in self.listOfTransactions {
      if transaction.owingAmountPerUser.keys.contains(user.uid), let owingAmount = transaction.owingAmountPerUser[user.uid] {
        totalOwingAmount += owingAmount
      }
    }
    return totalOwingAmount
  }
  
  func owingAmountForUser(_ user: User, owingToUser: User) -> Double {
    var amount: Double = 0
    for transaction in self.listOfTransactions {
      let allOwingAmount = transaction.determineUserOwingAmount()
      for owingAmount in allOwingAmount {
        if owingAmount.0 == owingToUser.uid && owingAmount.1 == user.uid {
          amount += owingAmount.2
          break
        } else if owingAmount.0 == user.uid && owingAmount.1 == owingToUser.uid {
          amount -= owingAmount.2
          break
        }
      }
    }
    return amount
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
