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
      if let uid = uid {
        return Firestore.firestore().collection("User").document(uid)
      } else {
        return nil
      }
    }
    set(documentRef) {
      uid = documentRef?.documentID
    }
  }
  
}
