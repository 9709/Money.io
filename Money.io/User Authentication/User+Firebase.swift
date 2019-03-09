import UIKit
import Firebase

extension User {
  
  // MARK: Firebase-related properties
  
  var documentRef: DocumentReference? {
    get {
      return Firestore.firestore().collection("User").document(uid)
    }
    set(documentRef) {
      if let documentID = documentRef?.documentID {
        uid = documentID
      }
    }
  }
  var dictionary: [String: Any] {
    if let groups = groups {
      let group = groups.map {
        return $0.uid
      }
      return [
        "name": name,
        "groups": group
      ]
    } else {
      return [
        "name": name
      ]
    }
  }
}
