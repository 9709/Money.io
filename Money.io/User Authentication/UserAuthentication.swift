import UIKit
import FirebaseUI

class UserAuthentication {
  
  // MARK: UserAuthentication methods
  
  static func getCurrentUser(completion: @escaping (_ currentUser: User?, _ groups: [Group], _ defaultGroup: Group?) -> Void) {
    guard let currentUser = Auth.auth().currentUser else {
      
      // There is no current user in Firebase Authentication session
      completion(nil, [], nil)
      return
    }
    
    DataManager.getCurrentUser(uid: currentUser.uid, completion: completion)
  }
  
  static func createNewUser(_ name: String, email: String, password: String, completion: @escaping (_ success: Bool) -> Void) {
    signOutUser()
    
    Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
      guard authResult != nil else {
        print("Error: \(error.debugDescription)")
        completion(false)
        return
      }
      
      guard let uid = Auth.auth().currentUser?.uid,
        let email = Auth.auth().currentUser?.email else {
        print("Could not get the uid of the current user")
        completion(false)
        return
      }
      
      DataManager.createUser(uid: uid, name: name, email: email)
      completion(true)
    }
  }
  
  static func signInUser(withEmail email: String, password: String, completion: @escaping (_ success: Bool) -> Void) {
    signOutUser()
    
    Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
      guard authDataResult != nil else {
        print("Error: \(error.debugDescription)")
        completion(false)
        return
      }
      
      completion(true)
    }
  }
  
  static func signOutUser() {
    if Auth.auth().currentUser != nil {
      do {
        try Auth.auth().signOut()
      } catch let error {
        print("Error: \(error)")
      }
    }
  }
  

}
