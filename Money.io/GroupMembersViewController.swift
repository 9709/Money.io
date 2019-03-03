//
//  GroupMembersViewController.swift
//  Money.io
//
//  Created by Matthew Chan on 2019-03-02.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

class GroupMembersViewController: UIViewController {
    
    var group: Group!
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddMemberSegue" {
            if let viewController = segue.destination as? UINavigationController {
                if let addMemberVC = viewController.children[0] as? NewEditMemberViewController {
                    addMemberVC.delegate = self
                }
            }
        }
    }

}


extension GroupMembersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return group.listOfUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupMemberNameCell", for: indexPath)
        cell.textLabel?.text = group.listOfUsers[indexPath.row].name
        return cell
    }
    
}

extension GroupMembersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            group.deleteUser(at: indexPath.row)
            tableView.reloadData()
        }
    }
}

extension GroupMembersViewController: NewEditMemberViewControllerDelegate {
    func addMember(name: String) {
        group.addUser(User(name: name))
        tableView.reloadData()
    }
}

