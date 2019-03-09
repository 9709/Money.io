import UIKit

struct Transaction {
  
  // MARK: Properties
  
  var uid: String
  var name: String
  
  var paidUsers: [String: Double]
  var splitUsers: [String: Double]
  
  var totalAmount: Double {
    var totalAmount: Double = 0
    for amount in paidUsers {
      totalAmount += amount.value
    }
    return totalAmount
  }
  
  // MARK: Transaction methods
  
  func userAmount(user: User) -> Double? {
    if !paidUsers.keys.contains(user.uid) && !splitUsers.keys.contains(user.uid) {
      return nil
    }
    
    var amount: Double = 0
    if paidUsers.keys.contains(user.uid), let paidAmount = paidUsers[user.uid] {
      amount += paidAmount
    }
    if splitUsers.keys.contains(user.uid), let splitAmount = splitUsers[user.uid]{
      amount -= splitAmount
    }
    
    return amount
  }
  
  func determineUserOwingAmount() -> [(String, String, Double)] {
    var paidUserUIDs: [String: Double] = [:]
    var owingUserUIDs: [String: Double] = [:]
    
    var fullTransactionDetails: [String: Double] = [:]
    for user in paidUsers {
      fullTransactionDetails[user.key] = user.value
      if !splitUsers.keys.contains(user.key) {
        paidUserUIDs[user.key] = user.value
      }
    }
    for user in splitUsers {
      if fullTransactionDetails.keys.contains(user.key), let oldAmount = fullTransactionDetails[user.key] {
        fullTransactionDetails[user.key] = oldAmount - user.value
        if let newAmount = fullTransactionDetails[user.key] {
          if newAmount > 0 {
            paidUserUIDs[user.key] = newAmount
          } else if newAmount < 0 {
            owingUserUIDs[user.key] = 0 - newAmount
          }
        }
      } else {
        fullTransactionDetails[user.key] = 0 - user.value
        owingUserUIDs[user.key] = user.value
      }
    }
    
    var totalOwingAmount: Double = 0
    for paidUserUID in paidUserUIDs {
      totalOwingAmount += paidUserUID.value
    }
    
    var paidToOwingTuples: [(String, String, Double)] = []
    for owingUserUID in owingUserUIDs {
      for paidUserUID in paidUserUIDs {
        let owingAmount = owingUserUID.value * (paidUserUID.value / totalOwingAmount)
        paidToOwingTuples.append((paidUserUID.key, owingUserUID.key, owingAmount))
      }
    }
    
    return paidToOwingTuples
  }
}

