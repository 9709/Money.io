import UIKit
import Firebase

extension DataManager {
  
  // MARK: Group related methods
  
  static func createGroup(name: String, completion: @escaping (Group?) -> Void) {
    var group: Group?
    db.runTransaction({ (transaction, errorPointer) -> Any? in
      guard let currentAuthenticatedUser = Auth.auth().currentUser else {
        return nil
      }
      guard let currentUser = GlobalVariables.singleton.currentUser else {
        return nil
      }
      
      let currentUserRef = db.collection("User").document(currentAuthenticatedUser.uid)
      let currentUserDocument: DocumentSnapshot
      do {
        currentUserDocument = try transaction.getDocument(currentUserRef)
      } catch let fetchError as NSError {
        errorPointer?.pointee = fetchError
        return nil
      }
      
      let groupRef = db.collection("Group").addDocument(data: ["name": name, "users": [currentUser.uid: ["name": currentUser.name, "email": currentUser.email]]])
      group = Group(uid: groupRef.documentID, name: name)
      
      if let oldGroups = currentUserDocument.data()?["groups"] as? [String: [String: Any]] {
        var newGroups = oldGroups
        newGroups[groupRef.documentID] = ["name": name, "owingAmount": 0]
        transaction.updateData(["groups": newGroups], forDocument: currentUserRef)
      } else {
        transaction.updateData(["groups": [groupRef.documentID: ["name": name, "owingAmount": 0]], "defaultGroup": groupRef.documentID], forDocument: currentUserRef)
      }
      
      group?.listOfUsers.append(currentUser)
      group?.listOfOwingAmounts[currentUser.uid] = 0
      
      return nil
    }) { (object, error) in
      if let error = error {
        print("Transaction failed: \(error)")
        completion(nil)
      } else {
        completion(group)
      }
    }
    
  }
  
  static func getGroup(uid: String, completion: @escaping (_ group: Group?) -> Void) {
    db.collection("Group").document(uid).getDocument { (documentSnapshot, error) in
      guard let document = documentSnapshot, document.exists else {
        print("Document does not exist")
        completion(nil)
        return
      }
      
      let data = document.data()
      
      guard let name = data?["name"] as? String else {
        print("Group must have a name")
        completion(nil)
        return
      }
      guard let userInfos = data?["users"] as? [String: [String: String]] else {
        print("Group must have at least one user")
        completion(nil)
        return
      }
      
      let group = Group(uid: uid, name: name)
      
      // Populate group's users
      var users: [User] = []
      for (userUID, userInfo) in userInfos {
        if let userName = userInfo["name"] {
          let user = User(uid: userUID, name: userName)
          
          if let userEmail = userInfo["email"] {
            user.email = userEmail
          }
          users.append(user)
        }
      }
      group.listOfUsers = users
      
      getAllTransactions(of: uid) { (transactions: [Transaction]?) in
        if let transactions = transactions {
          group.listOfTransactions = transactions
          
          group.sortedTransactions = group.sortTransactionsByDate()
          group.sortedMonthYear = group.sortMonthYear()
        }
        completion(group)
      }
    }
  }
}



