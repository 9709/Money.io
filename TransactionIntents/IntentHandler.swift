//
//  IntentHandler.swift
//  TransactionIntents
//
//  Created by Matthew Chan on 2019-03-09.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import Intents

class CreateTransactionIntentHandler: NSObject, CreateNewTransactionIntentHandling {
    
    func confirm(intent: CreateNewTransactionIntent, completion: @escaping (CreateNewTransactionIntentResponse) -> Void) {
        completion(CreateNewTransactionIntentResponse(code: .ready, userActivity: nil))
    }
    
    func handle(intent: CreateNewTransactionIntent, completion: @escaping (CreateNewTransactionIntentResponse) -> Void) {

        guard let name = intent.name else { return }
        guard let amount = intent.amount else { return }
        guard let paidUser = intent.paidUser else { return }
        guard let splitUsers = intent.splitUsers else { return }
        
//        let printIntentStatment = print("Intent Handler: Created \(amount) dollars \(name) transaction between \(paidUser) and \(splitUsers).")
//        print(printIntentStatment)
        
        print("Intent Handler: \(name)")
        
        completion(CreateNewTransactionIntentResponse(code: .success, userActivity: nil))
    }
    
    
}

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        guard intent is CreateNewTransactionIntent else {
            fatalError("Unhandled intent.")
        }
        return CreateNewTransactionIntent()
    }
    
}
