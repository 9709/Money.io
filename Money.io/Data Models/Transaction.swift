import UIKit

struct Transaction {
    
    // MARK: Properties
    
    var uid: String
    var name: String
    
    var paidAmountPerUser: [String: Double]
    var splitAmountPerUser: [String: Double]
    var owingAmountPerUser: [String: Double]
    
    var createdTimestamp: Date
    
    var totalAmount: Double {
        var totalAmount: Double = 0
        for amount in paidAmountPerUser {
            totalAmount += amount.value
        }
        return totalAmount
    }
    
    // MARK: Transaction methods
    
    func determineUserOwingAmount() -> [(String, String, Double)] {
        var paidUserUIDs: [String: Double] = [:]
        var owingUserUIDs: [String: Double] = [:]
        
        var fullTransactionDetails: [String: Double] = [:]
        
        for user in paidAmountPerUser {
            fullTransactionDetails[user.key] = user.value
            if !splitAmountPerUser.keys.contains(user.key) {
                paidUserUIDs[user.key] = user.value
            }
        }
        for user in splitAmountPerUser {
            if fullTransactionDetails.keys.contains(user.key), let oldAmount = fullTransactionDetails[user.key] {
                fullTransactionDetails[user.key] = oldAmount - user.value
                if let newAmount = fullTransactionDetails[user.key] {
                    if newAmount > 0 {
                        paidUserUIDs[user.key] = newAmount
                    } else if newAmount < 0 {
                        owingUserUIDs[user.key] = 0 - newAmount
                    }
                }
            } else {
                fullTransactionDetails[user.key] = 0 - user.value
                owingUserUIDs[user.key] = user.value
            }
        }
        
        var totalOwingAmount: Double = 0
        for paidUserUID in paidUserUIDs {
            totalOwingAmount += paidUserUID.value
        }
        
        var paidToOwingTuples: [(String, String, Double)] = []
        for owingUserUID in owingUserUIDs {
            for paidUserUID in paidUserUIDs {
                let owingAmount = owingUserUID.value * (paidUserUID.value / totalOwingAmount)
                paidToOwingTuples.append((paidUserUID.key, owingUserUID.key, owingAmount))
            }
        }
        
        return paidToOwingTuples
    }
}

