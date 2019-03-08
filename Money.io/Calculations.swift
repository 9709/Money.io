//
//  Calulations.swift
//  Money.io
//
//  Created by Matthew Chan on 2019-03-04.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import Foundation

class Calculations {
    
    static func updateUserDebt(with amount: Double, and user: User) {
//        user.amountOwing += amount
    }
    
    
    static func totalOwing(with group: [User]) -> Double {
        var arrayOfOwing: [Double] = []
        
        for user in group {
            arrayOfOwing.append(user.amountOwing)
            
        }
        return arrayOfOwing.reduce(0, +)
    }
    
}
