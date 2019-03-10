import UIKit
import Firebase

extension DataManager {
  
  // MARK: Transaction related methods
  
  static func createTransaction(name: String, paidUsers: [String: Double], splitUsers: [String: Double], owingAmountPerUser: [String: Double], to group: Group, completion: @escaping (_ transaction: Transaction?) -> Void) {
    let createdTimestamp = Date()
    let transactionRef = db.collection("Group").document(group.uid).collection("Transactions").addDocument(data: ["name": name, "paidUsers": paidUsers, "splitUsers": splitUsers, "owingAmountPerUser": owingAmountPerUser, "createdTimestamp": createdTimestamp])
    let uid = transactionRef.documentID
    
    updateUsers(uid: uid, name: name, paidUsers: paidUsers, splitUsers: splitUsers, owingAmountPerUser: owingAmountPerUser, createdTimestamp: createdTimestamp, to: group, completion: completion)
  }
  
  static func updateTransaction(uid: String, name: String, paidUsers: [String: Double], splitUsers: [String: Double], owingAmountPerUser: [String: Double], to group: Group, completion: @escaping (_ transaction: Transaction?) -> Void) {
    var createdTimestamp: Date = Date()
    db.runTransaction({ (transaction, errorPointer) -> Any? in
      let transactionRef = db.collection("Group").document(group.uid).collection("Transactions").document(uid)
      let transactionDocument: DocumentSnapshot
      do {
        transactionDocument = try transaction.getDocument(transactionRef)
      } catch let fetchError as NSError {
        errorPointer?.pointee = fetchError
        return nil
      }
      
      if let createdTimestampData = transactionDocument.data()?["createdTimestamp"] as? Timestamp {
        createdTimestamp = createdTimestampData.dateValue()
      }
      
      transaction.updateData(["name": name, "paidUsers": paidUsers, "splitUsers": splitUsers, "owingAmountPerUser": owingAmountPerUser], forDocument: transactionRef)
      
      return nil
    }) { (object, error) in
      if let error = error {
        print("Error: \(error)")
        completion(nil)
      } else {
        updateUsers(uid: uid, name: name, paidUsers: paidUsers, splitUsers: splitUsers, owingAmountPerUser: owingAmountPerUser, createdTimestamp: createdTimestamp, to: group, completion: completion)
      }
    }
  }
  
  static func getAllTransactions(of groupUID: String, completion: @escaping ([Transaction]?) -> Void) {
    db.collection("Group").document(groupUID).collection("Transactions").order(by: "createdTimestamp").getDocuments{ (querySnapshot, error) in
      if let error = error {
        print("Error getting documents: \(error)")
        completion(nil)
      } else {
        var transactions: [Transaction] = []
        for transactionDocument in querySnapshot!.documents {
          if let name = transactionDocument.data()["name"] as? String,
            let paidUsers = transactionDocument.data()["paidUsers"] as? [String: Double],
            let splitUsers = transactionDocument.data()["splitUsers"] as? [String: Double],
            let owingAmountPerUser = transactionDocument.data()["owingAmountPerUser"] as? [String: Double],
            let createdTimestampData = transactionDocument.data()["createdTimestamp"] as? Timestamp {
            let createdTimestamp = createdTimestampData.dateValue()
            transactions.insert(Transaction(uid: transactionDocument.documentID, name: name, paidAmountPerUser: paidUsers, splitAmountPerUser: splitUsers, owingAmountPerUser: owingAmountPerUser, createdTimestamp: createdTimestamp), at: 0)
          }
        }
        completion(transactions)
      }
    }
  }
  
  // MARK: Private helper methods
  
  static private func updateUsers(uid: String, name: String, paidUsers: [String: Double], splitUsers: [String: Double], owingAmountPerUser: [String: Double], createdTimestamp: Date, to group: Group, completion: @escaping (_ transaction: Transaction?) -> Void) {
    db.runTransaction({ (transaction, errorPointer) -> Any? in
      var usersData: [String: (DocumentReference, DocumentSnapshot)] = [:]
      for uid in [String](owingAmountPerUser.keys) {
        let userRef = db.collection("User").document(uid)
        let userDocument: DocumentSnapshot
        do {
          userDocument = try transaction.getDocument(userRef)
        } catch let fetchError as NSError {
          errorPointer?.pointee = fetchError
          return nil
        }
        usersData[uid] = (userRef, userDocument)
      }
      
      for (uid, (userRef, userDocument)) in usersData {
        if let owingAmount = owingAmountPerUser[uid] {
          if let oldGroups = userDocument.data()?["groups"] as? [String: [String: Any]] {
            var newGroups = oldGroups
            var newOwingAmount: Double = owingAmount
            if let groupToUpdate = newGroups[group.uid],
              let oldAmount = groupToUpdate["owingAmount"] as? Double {
              newOwingAmount = owingAmount + oldAmount
            }
            newGroups[group.uid] = ["name": group.name, "owingAmount": newOwingAmount]
            transaction.updateData(["groups": newGroups], forDocument: userRef)
          } else {
            print("Users must have groups to make or edit a transaction")
            return nil
          }
        }
      }
      return nil
    }) { (object, error) in
      if let error = error {
        print("Error: \(error)")
        completion(nil)
      } else {
        let transaction = Transaction(uid: uid, name: name, paidAmountPerUser: paidUsers, splitAmountPerUser: splitUsers, owingAmountPerUser: owingAmountPerUser, createdTimestamp: createdTimestamp)
        completion(transaction)
      }
    }
  }
}
