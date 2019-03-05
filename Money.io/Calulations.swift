//
//  Calulations.swift
//  Money.io
//
//  Created by Matthew Chan on 2019-03-04.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import Foundation

var user: User?

class Caluclations {
    
    static func updateUserDebt(with amount: Double, and user: User) {
        user.amountOwing += amount
    }
    
}
