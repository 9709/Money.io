import UIKit


class Group {
  
  // MARK: Properties
  
  var uid: String
  var name: String
  
  var listOfOwingAmounts: [String: Double] = [:]
  var listOfUsers: [User] = []
  var listOfTransactions: [Transaction] = []
  
  var sortedTransactions: [String: [Transaction]] = [:]
  var sortedMonthYear: [String] = []
  
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
  
  func createTransaction(name: String, paidUsers: [String: Double], splitUsers: [String: Double], owingAmountPerUser: [String: Double], payback: Bool, completion: @escaping (_ success: Bool) -> Void) {
    DataManager.createTransaction(name: name, paidUsers: paidUsers, splitUsers: splitUsers, owingAmountPerUser: owingAmountPerUser, payback: payback, to: self) { (transaction: Transaction?) in
      if let transaction = transaction {
        self.listOfTransactions.insert(transaction, at: 0)
        self.sortedMonthYear = self.sortMonthYear()
        self.sortedTransactions = self.sortTransactionsByDate()
        completion(true)
      } else {
        completion(false)
      }
      
    }
  }
  
  func updateTransaction(_ transaction: Transaction, name: String, paidUsers: [String: Double], splitUsers: [String: Double], owingAmountPerUser: [String: Double], createdTimestamp: Date, payback: Bool, completion: @escaping (_ success: Bool) -> Void) {
    DataManager.updateTransaction(uid: transaction.uid, name: name, paidUsers: paidUsers, splitUsers: splitUsers, owingAmountPerUser: owingAmountPerUser, createdTimestamp: createdTimestamp, payback: payback, to: self) { (transaction: Transaction?) in
      if let transaction = transaction {
        var found = false
        for index in 0..<self.listOfTransactions.count {
          if self.listOfTransactions[index].uid == transaction.uid {
            self.listOfTransactions[index] = transaction
            self.sortedMonthYear = self.sortMonthYear()
            self.sortedTransactions = self.sortTransactionsByDate()
            completion(true)
            found = true
            break
          }
        }
        if !found {
          completion(false)
        }
      } else {
        completion(false)
      }
    }
  }
  
  func deleteTransaction(at index: Int, completion: @escaping (_ success: Bool) -> Void) {
    DataManager.deleteTransaction(listOfTransactions[index], of: self) { (success: Bool) in
      if success {
        self.listOfTransactions.remove(at: index)
        self.sortedMonthYear = self.sortMonthYear()
        self.sortedTransactions = self.sortTransactionsByDate()
        completion(success)
      } else {
        completion(success)
      }
    }
  }
  
  func sortTransactionsByDate() -> [String: [Transaction]] {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "LLLL YYYY"
    var sortedTransactions: [String: [Transaction]] = [:]
    for transaction in listOfTransactions {
      let monthYear = dateFormatter.string(from: transaction.createdTimestamp)
      if sortedTransactions.keys.contains(monthYear) {
        sortedTransactions[monthYear]?.append(transaction)
      } else {
        sortedTransactions[monthYear] = [transaction]
      }
    }
    return sortedTransactions
  }
  
  func sortMonthYear() -> [String] {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "LLLL YYYY"
    var sortedMonthYear: [String] = []
    for transaction in listOfTransactions {
      let monthYear = dateFormatter.string(from: transaction.createdTimestamp)
      if sortedMonthYear.count == 0 {
        sortedMonthYear.append(monthYear)
        continue
      }
      if sortedMonthYear.last! != monthYear {
        sortedMonthYear.append(monthYear)
      }
    }
    return sortedMonthYear
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
  
}
