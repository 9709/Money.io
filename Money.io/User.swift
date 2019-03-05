//
//  User.swift
//  Money.io
//
//  Created by Matthew Chan on 2019-03-02.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

class User {
    
    var name: String
    let uid: Int
    var amountOwing: Double = 0
    static private var userCount = 0
    
    
    init(name: String) {
        self.name = name
        self.uid = User.userCount
        User.userCount += 1
    }

}
