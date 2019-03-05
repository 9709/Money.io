//
//  GroupViewController.swift
//  Money.io
//
//  Created by Matthew Chan on 2019-03-02.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

class GroupViewController: UIViewController {
    
    // MARK: Properties
    
    var group: Group!
    var user: User?
    var transaction: Transaction?
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: HARDCODE GROUP AND USERS
        group = Group(name: "LHL")
        
        group.addUser(name: "Matthew")
        group.addUser(name: "Jun")
        group.addUser(name: "Jenny")
        group.addUser(name: "Josh")
        group.addUser(name: "Spencer")
        group.addUser(name: "Jason")
        group.addUser(name: "Roland")
        group.addUser(name: "Danny")
        group.addUser(name: "Sam")
        group.addUser(name: "Amir")
        
        
        // Setting currentUser
        for user in group.listOfUsers {
            let uid = user.uid
            if uid == 0 {
                GlobalVariables.singleton.currentUser = user
                print((GlobalVariables.singleton.currentUser.name, GlobalVariables.singleton.currentUser.uid))
            }
        }
        
        // MARK: HARDCODE TRANSACTION
        group.addTransaction(Transaction(name: "Breakfast", amount: 40.00, paidUser: group.listOfUsers[2], splitUsers: [
            group.listOfUsers[1],
            group.listOfUsers[2],
            group.listOfUsers[3],
            group.listOfUsers[4]
            ]))
        
        group.addTransaction(Transaction(name: "Lunch", amount: 40.00, paidUser: group.listOfUsers[2], splitUsers: [
            group.listOfUsers[1],
            group.listOfUsers[2],
            group.listOfUsers[3],
            group.listOfUsers[4]
            ]))
        
        group.addTransaction(Transaction(name: "Dinner", amount: 40.00, paidUser: group.listOfUsers[2], splitUsers: [
            group.listOfUsers[1],
            group.listOfUsers[2],
            group.listOfUsers[3],
            group.listOfUsers[4]
            ]))
        
        group.addTransaction(Transaction(name: "Party", amount: 40.00, paidUser: group.listOfUsers[2], splitUsers: [
            group.listOfUsers[1],
            group.listOfUsers[2],
            group.listOfUsers[3],
            group.listOfUsers[4]
            ]))
        
        
        for transaction in group.listOfTransactions {
            let amountPerPerson = transaction.amount/Double(transaction.splitUsers.count)
            for user in group.listOfUsers {
                if transaction.splitUsers.contains(where: { (splitUser) -> Bool in
                    splitUser.uid == user.uid
                }) {
                    Caluclations.updateUserDebt(with: amountPerPerson, and: user)
                }
                print(user.name, user.amountOwing)
            }
        }
        
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGroupMembersSegue" {
            if let viewController = segue.destination as? UINavigationController {
                if let groupMembersVC = viewController.children[0] as? GroupMembersViewController {
                    groupMembersVC.group = group
                }
            }
        } else if segue.identifier == "toNewTransactionSegue" {
            if let viewController = segue.destination as? UINavigationController {
                if let newTransactionVC = viewController.children[0] as? NewTransactionViewController {
                    newTransactionVC.group = group
                    newTransactionVC.delegate = self
                }
            }
        } else if segue.identifier == "toEditTransactionSegue" {
            if let viewController = segue.destination as? UINavigationController {
                if let editTransactionVC = viewController.children[0] as? NewTransactionViewController {
                    if let transactionCell = sender as? TransactionTableViewCell,
                        let selectedRow = tableView.indexPath(for: transactionCell)?.row {
                        let transaction = group.listOfTransactions[selectedRow]
                        editTransactionVC.transaction = transaction
                        editTransactionVC.group = group
                        editTransactionVC.delegate = self
                    }
                }
            }
        }
    }
    
    @IBAction func payBackButton(_ sender: UITapGestureRecognizer) {
        
    }
    
    
    
}





extension GroupViewController: NewTransactionViewControllerDelegate {
    
    // MARK: NewTransactionViewControllerDelegate methods
    
    func addTransaction(_ transaction: Transaction) {
        group.addTransaction(transaction)
        tableView.reloadData()
    }
    
    func updateTransaction() {
        tableView.reloadData()
    }
}




extension GroupViewController: UITableViewDelegate {
    
    // MARK: UITableViewDelegate methods
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            group.deleteTransaction(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
}




extension GroupViewController: UITableViewDataSource {
    
    // MARK: UITableViewDataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return group.listOfTransactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as? TransactionTableViewCell else {
            return UITableViewCell()
        }
        
        cell.transaction = group.listOfTransactions[indexPath.row]
        cell.configureCell()
        
        return cell
    }
    
    
}
