import UIKit
import Firebase

extension DataManager {
  
  // MARK: Transaction related methods
  
  static func createTransaction(name: String, paidUsers: [String: Double], splitUsers: [String: Double], owingAmountPerUser: [String: Double], to group: Group, completion: @escaping (_ transaction: Transaction?) -> Void) {
    let createdTimestamp = Date()
    let transactionRef = db.collection("Group").document(group.uid).collection("Transactions").addDocument(data: ["name": name, "paidUsers": paidUsers, "splitUsers": splitUsers, "owingAmountPerUser": owingAmountPerUser, "createdTimestamp": createdTimestamp])
    let uid = transactionRef.documentID
    
    updateUsersForNewTransaction(uid: uid, name: name, paidUsers: paidUsers, splitUsers: splitUsers, owingAmountPerUser: owingAmountPerUser, createdTimestamp: createdTimestamp, to: group, completion: completion)
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
        updateUsersForUpdatingTransaction(uid: uid, name: name, paidUsers: paidUsers, splitUsers: splitUsers, owingAmountPerUser: owingAmountPerUser, createdTimestamp: createdTimestamp, to: group, completion: completion)
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
  
  static private func updateUsersForUpdatingTransaction(uid: String, name: String, paidUsers: [String: Double], splitUsers: [String: Double], owingAmountPerUser: [String: Double], createdTimestamp: Date, to group: Group, completion: @escaping (_ transaction: Transaction?) -> Void) {
    db.runTransaction({ (transaction, errorPointer) -> Any? in
      
      var transactionToUpdate: Transaction?
      for oldTransaction in group.listOfTransactions {
        if oldTransaction.uid == uid {
          transactionToUpdate = oldTransaction
          break
        }
      }
      guard let oldTransaction = transactionToUpdate else {
        print("We are not updating")
        return nil
      }
      
      var usersData: [String: (DocumentReference, DocumentSnapshot)] = [:]
      for userUID in [String](owingAmountPerUser.keys) {
        let userRef = db.collection("User").document(userUID)
        let userDocument: DocumentSnapshot
        do {
          userDocument = try transaction.getDocument(userRef)
        } catch let fetchError as NSError {
          errorPointer?.pointee = fetchError
          return nil
        }
        usersData[userUID] = (userRef, userDocument)
      }
      
      for userUID in [String](oldTransaction.owingAmountPerUser.keys) {
        if usersData[userUID] == nil {
          let userRef = db.collection("User").document(userUID)
          let userDocument: DocumentSnapshot
          do {
            userDocument = try transaction.getDocument(userRef)
          } catch let fetchError as NSError {
            errorPointer?.pointee = fetchError
            return nil
          }
          usersData[userUID] = (userRef, userDocument)
        }
      }
      
      for (userUID, (userRef, userDocument)) in usersData {
        // If user is no longer involved in the transaction
        if oldTransaction.owingAmountPerUser[userUID] != nil && owingAmountPerUser[userUID] == nil {
          guard let oldOwingAmount = oldTransaction.owingAmountPerUser[userUID],
            let oldGroups = userDocument.data()?["groups"] as? [String: [String: Any]],
            let groupToUpdate = oldGroups[group.uid],
            let oldAmount = groupToUpdate["owingAmount"] as? Double else {
            return nil
          }
          
          var newGroups = oldGroups
          newGroups[group.uid] = ["name": group.name, "owingAmount": oldAmount - oldOwingAmount]
          transaction.updateData(["groups": newGroups], forDocument: userRef)
          
          // If the user is newly involved in the transaction
        } else if oldTransaction.owingAmountPerUser[userUID] == nil && owingAmountPerUser[userUID] != nil {
          guard let owingAmount = owingAmountPerUser[userUID],
            let oldGroups = userDocument.data()?["groups"] as? [String: [String: Any]],
            let groupToUpdate = oldGroups[group.uid],
            let oldAmount = groupToUpdate["owingAmount"] as? Double else {
            return nil
          }
          
          var newGroups = oldGroups
          newGroups[group.uid] = ["name": group.name, "owingAmount": oldAmount + owingAmount]
          transaction.updateData(["groups": newGroups], forDocument: userRef)
        } else {
          guard let oldOwingAmount = oldTransaction.owingAmountPerUser[userUID],
            let owingAmount = owingAmountPerUser[userUID],
            let oldGroups = userDocument.data()?["groups"] as? [String: [String: Any]],
            let groupToUpdate = oldGroups[group.uid],
            let oldAmount = groupToUpdate["owingAmount"] as? Double else {
              return nil
          }
          
          var newGroups = oldGroups
          newGroups[group.uid] = ["name": group.name, "owingAmount": oldAmount + owingAmount - oldOwingAmount]
          transaction.updateData(["groups": newGroups], forDocument: userRef)
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
  
  static private func updateUsersForNewTransaction(uid: String, name: String, paidUsers: [String: Double], splitUsers: [String: Double], owingAmountPerUser: [String: Double], createdTimestamp: Date, to group: Group, completion: @escaping (_ transaction: Transaction?) -> Void) {
    db.runTransaction({ (transaction, errorPointer) -> Any? in
      var usersData: [String: (DocumentReference, DocumentSnapshot)] = [:]
      for userUID in [String](owingAmountPerUser.keys) {
        let userRef = db.collection("User").document(userUID)
        let userDocument: DocumentSnapshot
        do {
          userDocument = try transaction.getDocument(userRef)
        } catch let fetchError as NSError {
          errorPointer?.pointee = fetchError
          return nil
        }
        usersData[userUID] = (userRef, userDocument)
      }
      
      for (userUID, (userRef, userDocument)) in usersData {
        guard let owingAmount = owingAmountPerUser[userUID],
          let oldGroups = userDocument.data()?["groups"] as? [String: [String: Any]],
          let groupToUpdate = oldGroups[group.uid],
          let oldAmount = groupToUpdate["owingAmount"] as? Double else {
          return nil
        }
        
        var newGroups = oldGroups
        newGroups[group.uid] = ["name": group.name, "owingAmount": oldAmount + owingAmount]
        transaction.updateData(["groups": newGroups], forDocument: userRef)
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
