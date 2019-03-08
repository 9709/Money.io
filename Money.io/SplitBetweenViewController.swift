//
//  SplitBetweenViewController.swift
//  Money.io
//
//  Created by Jun Oh on 2019-03-03.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

protocol SplitBetweenViewControllerDelegate {
    func updateSplitBetweenMembers(members: [User])
}





class SplitBetweenViewController: UIViewController {
    
    // MARK: Properties
    
    var group: Group?
    var members: [User]?
    var delegate: SplitBetweenViewControllerDelegate?
    
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
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        members = []
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in selectedIndexPaths {
                if let user = group?.listOfUsers[indexPath.row] {
                    members?.append(user)
                }
            }
            delegate?.updateSplitBetweenMembers(members: members!)
        }
        dismiss(animated: true, completion: nil)
    }
}





extension SplitBetweenViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
}




extension SplitBetweenViewController: UITableViewDataSource {
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
        
        if let members = members {
            for index in 0..<members.count {
                if let user = group?.listOfUsers[indexPath.row] {
                    if members[index] === user {
                        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                        cell.accessoryType = .checkmark
                        self.members?.remove(at: index)
                        break
                    }
                }
            }
        }
        
        return cell
    }
    
    
}
