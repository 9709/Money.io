import UIKit

struct Transaction {
  
  // MARK: Properties
  
  var uid: String
  var name: String
  
  var userIDPaidAmount: [String: Double]
  
  // MARK: Transaction methods
  
  func userAmount(user: User) -> Double? {
    if userIDPaidAmount.keys.contains(user.uid) {
      return userIDPaidAmount[user.uid]
    } else {
      return nil
    }
  }
}

