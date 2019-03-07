//
//  PayBackViewController.swift
//  Money.io
//
//  Created by Matthew Chan on 2019-03-04.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

protocol PayBackViewControllerDelegate {
    func updateTotal()
}


class PayBackViewController: UIViewController {
    
    // MARK: Properties
    
    var group: Group!
    var user: User?
    var payBackUsers: [User] = []
    
    var delegate: PayBackViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for user in group.listOfUsers {
            if user === GlobalVariables.singleton.currentUser {
                continue
            }
            payBackUsers.append(user)
        }
        
        tableView.dataSource = self
    }
    
    
    
    
    // MARK: Actions
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func save(_ sender: UIBarButtonItem) {
        delegate?.updateTotal()
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPayBackAmountSegue" {
            if let viewController = segue.destination as? UINavigationController {
                if let payBackAmountVC = viewController.children[0] as? PayBackAmountViewController {
                    if let payBackCell = sender as? PayBackTableViewCell,
                        let selectedRow = tableView.indexPath(for: payBackCell)?.row {
                        let user = payBackUsers[selectedRow]
                        payBackAmountVC.user = user
                        payBackAmountVC.delegate = self
                    }
                }
            }
        }
    }
    
}


extension PayBackViewController: UITableViewDataSource {
    
    // MARK: UITableViewDataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payBackUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PayBackCell", for: indexPath) as? PayBackTableViewCell else {
            return UITableViewCell()
        }
        
        cell.user = payBackUsers[indexPath.row]
        cell.configureCell()
        
        return cell
    }
}



extension PayBackViewController: PayBackAmountViewControllerDelegate {
    
    func payBackTransaction(_ transaction: Transaction) {
        group.addTransaction(transaction)
        tableView.reloadData()
        
    }
}
