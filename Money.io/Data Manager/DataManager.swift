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
        completion(nil)
      } else {
        
        guard querySnapshot!.documents.count > 0 else {
          print("Could not find any user with this email")
          completion(nil)
          return
        }
        
        // querySnapshot's documents should only contain one user (since email is unique)
        let userDocument = querySnapshot!.documents[0]
        let userUID = userDocument.documentID
        
        guard let name = userDocument.data()["name"] as? String else {
          print("User does not have a name")
          completion(nil)
          return
        }
        
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
          
          guard let oldUsers = groupDocument.data()?["users"] as? [String: [String: Any]] else {
            print("Error: groupDocument does not have users")
            return nil
          }
          
          var newUsers = oldUsers
          newUsers[userUID] = ["name": user.name, "email": email]
          transaction.updateData(["users": newUsers], forDocument: groupRef)
          
          if let oldGroups = userDocument.data()?["groups"] as? [String: [String: Any]] {
            var newGroups = oldGroups
            newGroups[groupDocument.documentID] = ["name": group.name, "owingAmount": 0]
            transaction.updateData(["groups": newGroups], forDocument: userRef)
          } else {
            transaction.updateData(["groups": [groupDocument.documentID: ["name": group.name, "owingAmount": 0]]], forDocument: userRef)
          }
          return nil
        }) { (object, error) in
          if let error = error {
            print("Transaction failed: \(error)")
            completion(nil)
          } else {
            completion(user)
          }
        }
      }
    }
  }
  
  static func getCurrentUser(uid: String, completion: @escaping (_ currentUser: User?, _ groups: [Group]) -> Void) {
    db.collection("User").document(uid).getDocument { (documentSnapshot, error) in
      guard let document = documentSnapshot, document.exists else {
        print("Document does not exist")
        completion(nil, [])
        return
      }
      
      let data = document.data()
      guard let name = data?["name"] as? String,
        let email = data?["email"] as? String else {
          completion(nil, [])
          return
      }
      
      let user = User(uid: uid, name: name)
      user.email = email
      
      if let groups = data?["groups"] as? [String: [String: Any]] {
        var userGroups: [Group] = []
        for (groupUID, details) in groups {
          if let groupName = details["name"] as? String,
            let owingAmount = details["owingAmount"] as? Double {
            let group = Group(uid: groupUID, name: groupName)
            let userUID = uid
            group.listOfOwingAmounts = [userUID: owingAmount]
            userGroups.append(group)
          }
        }
        completion(user, userGroups)
      } else {
        completion(user, [])
      }
      
    }
  }
}
