import UIKit

extension DataManager {
  
  // MARK: Transaction related methods
  
  static func createTransaction(name: String, paidUsers: [String: Double], splitUsers: [String: Double], to group: Group, completion: @escaping (Transaction) -> Void) {
    let transactionRef = db.collection("Group").document(group.uid).collection("Transactions").addDocument(data: ["name": name, "paidUsers": paidUsers, "splitUsers": splitUsers])
    let uid = transactionRef.documentID
    let transaction = Transaction(uid: uid, name: name, paidUsers: paidUsers, splitUsers: splitUsers)
    completion(transaction)
  }
  
  static func updateTransaction(uid: String, name: String, paidUsers: [String: Double], splitUsers: [String: Double], to group: Group, completion: @escaping (Transaction) -> Void) {
    db.collection("Group").document(group.uid).collection("Transactions").document(uid).updateData(["name": name, "paidUsers": paidUsers, "splitUsers": splitUsers])
    let transaction = Transaction(uid: uid, name: name, paidUsers: paidUsers, splitUsers: splitUsers)
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
            let paidUsers = transactionDocument.data()["paidUsers"] as? [String: Double],
            let splitUsers = transactionDocument.data()["splitUsers"] as? [String: Double] {
            transactions.insert(Transaction(uid: transactionDocument.documentID, name: name, paidUsers: paidUsers, splitUsers: splitUsers), at: 0)
          }
        }
        completion(transactions)
      }
    }
  }
}
