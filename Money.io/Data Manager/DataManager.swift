//
//  DataManager.swift
//  Money.io
//
//  Created by Jun Oh on 2019-03-05.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit
import Firebase

class DataManager {

  static let db = Firestore.firestore()
  
  // MARK: Transaction methods
  
  // MARK: User methods
  
  static func createUser(uid: String, name: String) {
    db.collection("User").document(uid).setData(["name": name])
  }
  
  static func getUser(uid: String, completion: @escaping (User?) -> Void) {
    db.collection("User").document(uid).getDocument { (documentSnapshot, error) in
      if let document = documentSnapshot, document.exists {
        let data = document.data()
        if let name = data?["name"] as? String {
          var user: User = User(name: name)
          user.uid = uid
          
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
  
  static func getCurrentUser(uid: String, completion: @escaping (User?) -> Void) {
    db.collection("User").document(uid).getDocument { (documentSnapshot, error) in
      if let document = documentSnapshot, document.exists {
        let data = document.data()
        if let name = data?["name"] as? String {
          var user: User = User(name: name)
          user.uid = uid
          
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
  
  // MARK: Group methods
  
  static func createGroup(name: String, completion: @escaping (Group) -> Void) {
    var group = Group(name: name)
    
    db.runTransaction({ (transaction, errorPointer) -> Any? in
      guard let currentUser = Auth.auth().currentUser else {
        return nil
      }
      
      let currentUserRef = db.collection("User").document(currentUser.uid)
      var currentUserDocument: DocumentSnapshot
      do {
        currentUserDocument = try transaction.getDocument(currentUserRef)
      } catch let fetchError as NSError {
        errorPointer?.pointee = fetchError
        return nil
      }
      
      let groupRef = db.collection("Group").addDocument(data: ["name": group.name, "users": [currentUser.uid]])
      group.uid = groupRef.documentID
      
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
          group.addUser(currentUser)
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
          var group = Group(name: name)
          group.uid = uid
          
          if let userUIDs = data?["users"] as? [String] {

            var users: [User] = []

            let dispatchGroup = DispatchGroup()
            let dispatchQueue = DispatchQueue(label: "third")
            dispatchQueue.async {

              for userUID in userUIDs {
                dispatchGroup.enter()
                DataManager.getUser(uid: userUID) { user in
                  if let user = user {
                    users.append(user)
                  }
                  dispatchGroup.leave()
                }
                dispatchGroup.wait()
              }
            }
            dispatchGroup.notify(queue: dispatchQueue, execute: {
              group.listOfUsers = users
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
