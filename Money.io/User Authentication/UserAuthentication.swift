//
//  UserAuthentication.swift
//  Money.io
//
//  Created by Jun Oh on 2019-03-06.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit
import FirebaseUI

class UserAuthentication {
  
  // MARK: Static functions
  
  static func getCurrentUser(completion: @escaping (User?) -> Void) {
    guard let currentUser = Auth.auth().currentUser else {
      print("No current user")
      completion(nil)
      return
    }
    
    DataManager.getCurrentUser(uid: currentUser.uid, completion: completion)
  }
  
  // MARK: UserAuthentication methods
  
  static func createNewUser(_ name: String, email: String, password: String, completion: @escaping () -> Void) {
    signOutUser()
    
    Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
      guard let authResult = authResult else {
        print("Error: \(error.debugDescription)")
        return
      }
      
      guard let uid = Auth.auth().currentUser?.uid,
        let email = Auth.auth().currentUser?.email else {
        print("Could not get the uid of the current user")
        return
      }
      
      
      DataManager.createUser(uid: uid, name: name, email: email)
      completion()
    }
  }
  
  static func signInUser(withEmail email: String, password: String, completion: @escaping () -> Void) {
    signOutUser()
    
    Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
      guard let authDataResult = authDataResult else {
        print("Error: \(error.debugDescription)")
        return
      }
      completion()
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
