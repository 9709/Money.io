//
//  PaidByViewController.swift
//  Money.io
//
//  Created by Jun Oh on 2019-03-03.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

protocol PaidByViewControllerDelegate {
    func updatePaidByMember(user: User)
}



class PaidByViewController: UIViewController {
    
    // MARK: Properties
    
    var group: Group?
    var user: User?
    var delegate: PaidByViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    // MARK: UIViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    
    
    // MARK: Actions
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}




extension PaidByViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let user = group?.listOfUsers[indexPath.row] {
            delegate?.updatePaidByMember(user: user)
        }
        dismiss(animated: true, completion: nil)
    }
}

extension PaidByViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = group?.listOfUsers.count else {
            return 0
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath)
        
        let font = UIFont.systemFont(ofSize: 20)
        cell.textLabel?.font = font
        cell.textLabel?.text = group?.listOfUsers[indexPath.row].name
        
        return cell
    }
    
}
