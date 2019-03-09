import UIKit

extension DataManager {
  
  // MARK: Transaction related methods
  
  static func createTransaction(name: String, details: [String: Double], to group: Group, completion: @escaping (Transaction) -> Void) {
    let transactionRef = db.collection("Group").document(group.uid).collection("Transactions").addDocument(data: ["name": name, "details": details])
    let uid = transactionRef.documentID
    let transaction = Transaction(uid: uid, name: name, userIDPaidAmount: details)
    completion(transaction)
  }
  
  static func getAllTransactions(of groupUID: String, completion: @escaping ([Transaction]?) -> Void) {
    db.collection("Group").document(groupUID).collection("Transactions").getDocuments{ (querySnapshot, error) in
      if let error = error {
        print("Error getting documents: \(error)")
        completion(nil)
      } else {
        var transactions: [Transaction] = []
        for transactionDocument in querySnapshot!.documents {
          if let name = transactionDocument.data()["name"] as? String,
            let details = transactionDocument.data()["details"] as? [String: Double] {
            transactions.insert(Transaction(uid: transactionDocument.documentID, name: name, userIDPaidAmount: details), at: 0)
          }
        }
        completion(transactions)
      }
    }
  }
}
