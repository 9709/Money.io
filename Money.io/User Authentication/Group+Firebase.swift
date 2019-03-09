//
//  Group+Firebase.swift
//  Money.io
//
//  Created by Jun Oh on 2019-03-06.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit
import Firebase

extension Group {
  
  // MARK: Firebase-related properties
  
  var documentRef: DocumentReference? {
    get {
      return Firestore.firestore().collection("Group").document(uid)
    }
    set(documentRef) {
      if let documentID = documentRef?.documentID {
        uid = documentID
      }
    }
  }
  
}
