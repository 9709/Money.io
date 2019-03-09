import UIKit
import Firebase

extension DataManager {
  
  // MARK: Group related methods
  
  static func createGroup(name: String, completion: @escaping (Group?) -> Void) {
    var group: Group?
    db.runTransaction({ (transaction, errorPointer) -> Any? in
      guard let currentUser = Auth.auth().currentUser else {
        return nil
      }
      
      let currentUserRef = db.collection("User").document(currentUser.uid)
      let currentUserDocument: DocumentSnapshot
      do {
        currentUserDocument = try transaction.getDocument(currentUserRef)
      } catch let fetchError as NSError {
        errorPointer?.pointee = fetchError
        return nil
      }
      
      let groupRef = db.collection("Group").addDocument(data: ["name": name, "users": [currentUser.uid]])
      group = Group(uid: groupRef.documentID, name: name)
      
      if let oldGroups = currentUserDocument.data()?["groups"] as? [String] {
        var newGroups = oldGroups
        newGroups.append(groupRef.documentID)
        transaction.updateData(["groups": newGroups], forDocument: currentUserRef)
      } else {
        transaction.updateData(["groups": [groupRef.documentID]], forDocument: currentUserRef)
      }
      
      // Add document listener for realtime updates
      //      groupRef.addSnapshotListener({ (documentSnapshot, error) in
      //        if let document = documentSnapshot, document.exists {
      //
      //        } else {
      //
      //        }
      //      })
      
      let semaphore = DispatchSemaphore(value: 0)
      UserAuthentication.getCurrentUser(completion: { (currentUser) in
        if let currentUser = currentUser {
          group?.listOfUsers.append(currentUser)
        }
        semaphore.signal()
      })
      semaphore.wait()
      return nil
    }) { (object, error) in
      if let error = error {
        print("Transaction failed: \(error)")
      } else {
        completion(group)
      }
    }
    
  }
  
  static func getGroup(uid: String, completion: @escaping (Group?) -> Void) {
    db.collection("Group").document(uid).getDocument { (documentSnapshot, error) in
      if let document = documentSnapshot, document.exists {
        let data = document.data()
        
        if let name = data?["name"] as? String {
          let group = Group(uid: uid, name: name)
          
          if let userUIDs = data?["users"] as? [String] {
            
            var users: [User] = []
            var transactions: [Transaction] = []
            
            let dispatchGroup = DispatchGroup()
            let dispatchQueue = DispatchQueue(label: "third")
            dispatchQueue.async {
              
              for userUID in userUIDs {
                dispatchGroup.enter()
                getUser(uid: userUID) { user in
                  if let user = user {
                    users.append(user)
                  }
                  dispatchGroup.leave()
                }
                dispatchGroup.wait()
              }
              
              dispatchGroup.enter()
              getAllTransactions(of: uid) { (transactionList) in
                if let transactionList = transactionList {
                  transactions = transactionList
                }
                dispatchGroup.leave()
              }
              dispatchGroup.wait()
            }
            
            dispatchGroup.notify(queue: dispatchQueue, execute: {
              group.listOfUsers = users
              group.listOfTransactions = transactions
              completion(group)
            })
          } else {
            completion(group)
          }
        } else {
          completion(nil)
        }
        
      } else {
        print("Document does not exist")
        completion(nil)
      }
    }
  }
}
