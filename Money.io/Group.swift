//
//  Group.swift
//  Money.io
//
//  Created by Matthew Chan on 2019-03-02.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

class Group {

    var listOfUsers: [User] = []
    var name: String
    let uid: Int
    static private var groupCount = 0
    
    init(name: String) {
        self.name = name
        self.uid = Group.groupCount
        Group.groupCount += 1
    }
    
    func addUser(_ user: User) {
        listOfUsers.append(user)
    }
    
    func deleteUser(at index: Int) {
        listOfUsers.remove(at: index)
    }
    
}
