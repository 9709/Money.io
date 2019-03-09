import UIKit
import Firebase

class DataManager {

  static let db = Firestore.firestore()
  
  // MARK: User methods
  
  static func createUser(uid: String, name: String, email: String) {
    db.collection("User").document(uid).setData(["name": name, "email": email])
  }
  
  static func getUser(uid: String, completion: @escaping (User?) -> Void) {
    db.collection("User").document(uid).getDocument { (documentSnapshot, error) in
      if let document = documentSnapshot, document.exists {
        let data = document.data()
        if let name = data?["name"] as? String {
          let user = User(uid: uid, name: name)
          
          if let email = data?["email"] as? String {
            user.email = email
          }
          
          completion(user)
        } else {
          completion(nil)
        }
      } else {
        print("Document does not exist")
        completion(nil)
      }
    }
  }
  
  static func addUser(email: String, to group: Group, completion: @escaping (User?) -> Void) {
    db.collection("User").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
      if let error = error {
        print("Error getting documents: \(error)")
      } else {
        
        guard querySnapshot!.documents.count > 0 else {
          print("Could not find any user with this email")
          return
        }
          
        // querySnapshot's documents should only contain one user (since email is unique)
        let userDocument = querySnapshot!.documents[0]
        let userUID = userDocument.documentID
        if let name = userDocument.data()["name"] as? String {
          let user = User(uid: userUID, name: name)
          user.email = email
          
          db.runTransaction({ (transaction, errorPointer) -> Any? in
            let groupRef = db.collection("Group").document(group.uid)
            let groupDocument: DocumentSnapshot
            
            let userRef = db.collection("User").document(userUID)
            let userDocument: DocumentSnapshot
            do {
              groupDocument = try transaction.getDocument(groupRef)
              userDocument = try transaction.getDocument(userRef)
            } catch let fetchError as NSError {
              errorPointer?.pointee = fetchError
              return nil
            }
            
            if let oldGroups = userDocument.data()?["groups"] as? [String] {
              var newGroups = oldGroups
              newGroups.append(groupDocument.documentID)
              transaction.updateData(["groups": newGroups], forDocument: userRef)
            } else {
              transaction.updateData(["groups": [groupDocument.documentID]], forDocument: userRef)
            }
            
            guard let oldUsers = groupDocument.data()?["users"] as? [String] else {
              print("Error: groupDocument does not have users")
              return nil
            }
            
            var newUsers = oldUsers
            newUsers.append(userUID)
            transaction.updateData(["users": newUsers], forDocument: groupRef)
            return nil
          }, completion: { (object, error) in
            if let error = error {
              print("Transaction failed: \(error)")
            } else {
              completion(user)
            }
          })
        }
        
        
      }
    }

  }
  
  static func getCurrentUser(uid: String, completion: @escaping (User?) -> Void) {
    db.collection("User").document(uid).getDocument { (documentSnapshot, error) in
      if let document = documentSnapshot, document.exists {
        let data = document.data()
        if let name = data?["name"] as? String,
          let email = data?["email"] as? String {
          let user = User(uid: uid, name: name)
          user.email = email
          
          if let groupUIDs = data?["groups"] as? [String] {
            var groups: [Group] = []

            let dispatchGroup = DispatchGroup()
            let dispatchQueue = DispatchQueue(label: "second")
            
            dispatchQueue.async {
              for groupUID in groupUIDs {
                dispatchGroup.enter()
                  getGroup(uid: groupUID) { group in
                    if let group = group {
                      groups.append(group)
                    }
                    dispatchGroup.leave()
                  }
                dispatchGroup.wait()
              }
            }
            
            dispatchGroup.notify(queue: dispatchQueue, execute: {
              user.groups = groups
              completion(user)
            })
          } else {
            completion(user)
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
