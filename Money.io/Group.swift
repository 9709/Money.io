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
  var listOfTransactions: [Transaction] = []
  var name: String
  let uid: Int
  static private var groupCount = 0

  // MARK: Initializers
  
  init(name: String) {
    self.name = name
    self.uid = Group.groupCount
    Group.groupCount += 1
  }
  
    
    
    
  // MARK: Group User methods
  
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
  
  func findUser(from uid: Int) -> User? {
    for user in listOfUsers {
      if user.uid == uid {
        return user
      }
    }
    return nil
  }
  
    
    
    
  // MARK: Group Transaction methods
  
  func addTransaction(_ transaction: Transaction) {
    listOfTransactions.insert(transaction, at: 0)
    updateOwningAmountPerMember()
  }

  func deleteTransaction(at index: Int) {
    listOfTransactions.remove(at: index)
    updateOwningAmountPerMember()
  }

    
    
    // MARK: Sums amount owing for each peron

    func updateOwningAmountPerMember() {
        self.listOfUsers.forEach({(user: User) -> Void in user.amountOwing = 0})
        let currentUser: User = GlobalVariables.singleton.currentUser;
        for transaction in self.listOfTransactions {
            let amountPerPerson = transaction.amount/Double(transaction.splitUsers.count)
            if currentUser.uid == transaction.paidUser.uid {
                for user in transaction.splitUsers {
                    if user.uid != currentUser.uid {
                        user.amountOwing -= amountPerPerson
                    }
                }
            } else if transaction.splitUsers.contains(where: { (splitUser) -> Bool in
                splitUser.uid == currentUser.uid
            }) {
                transaction.paidUser.amountOwing += amountPerPerson
            }
            
//            for user in self.listOfUsers {
//                if transaction.paidUser === GlobalVariables.singleton.currentUser {
//                    amountPerPerson = (transaction.amount/Double(transaction.splitUsers.count)) * -1.00
//
//                    if transaction.splitUsers.contains(where: { (splitUser) -> Bool in
//                        splitUser.uid == user.uid
//                    }) {
//                        Calculations.updateUserDebt(with: amountPerPerson, and: user)
//                    }
//                    print(user.name, user.amountOwing)
//                } else {
//                    if transaction.splitUsers.contains(where: { (splitUser) -> Bool in
//                        splitUser.uid == user.uid
//                    }) {
//                        Calculations.updateUserDebt(with: amountPerPerson, and: user)
//                    }
//                    print(user.name, user.amountOwing)
//                }
//            }
        }
    }
  
}
