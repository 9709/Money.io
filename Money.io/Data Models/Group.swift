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
  
  func createTransaction(name: String, paidUsers: [String: Double], splitUsers: [String: Double], completion: @escaping () -> Void) {
    DataManager.createTransaction(name: name, paidUsers: paidUsers, splitUsers: splitUsers, to: self) { [weak self] transaction in
      self?.listOfTransactions.insert(transaction, at: 0)
      completion()
    }
  }
  
  func updateTransaction(_ transaction: Transaction, name: String, paidUsers: [String: Double], splitUsers: [String: Double], completion: @escaping () -> Void) {
    DataManager.updateTransaction(uid: transaction.uid, name: name, paidUsers: paidUsers, splitUsers: splitUsers, to: self) { [weak self] transaction in
      if let transactionList = self?.listOfTransactions {
        for index in 0..<transactionList.count {
          if transactionList[index].uid == transaction.uid {
            self?.listOfTransactions[index] = transaction
            completion()
          }
        }
      }
    }
  }

  func deleteTransaction(at index: Int) {
    listOfTransactions.remove(at: index)
    updateOwningAmountPerMember()
  }
  
  func groupPaidAmountForUser(_ user: User) -> Double {
    var amount: Double = 0
    for transaction in self.listOfTransactions {
      if transaction.paidUsers.keys.contains(user.uid), let paidAmount = transaction.paidUsers[user.uid] {
        amount += paidAmount
      }
      if transaction.splitUsers.keys.contains(user.uid), let owingAmount = transaction.splitUsers[user.uid] {
        amount -= owingAmount
      }
    }
    return amount
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
