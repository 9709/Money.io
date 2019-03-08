//
//  GroupMembersViewController.swift
//  Money.io
//
//  Created by Matthew Chan on 2019-03-02.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

class GroupMembersViewController: UIViewController {
    
    // MARK: Properties
    
    var group: Group!
    
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
    
    
    
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddMemberSegue" {
            if let viewController = segue.destination as? UINavigationController {
                if let addMemberVC = viewController.children[0] as? NewEditMemberViewController {
                    addMemberVC.delegate = self
                }
            }
        } else if segue.identifier == "toEditMemberSegue" {
            if let viewController = segue.destination as? UINavigationController,
                let editMemberVC = viewController.children[0] as? NewEditMemberViewController {
                if let cell = sender as? UITableViewCell,
                    let selectedIndexPath = tableView.indexPath(for: cell) {
                    let user = group.listOfUsers[selectedIndexPath.row]
                    editMemberVC.name = user.name
                    editMemberVC.uid = user.uid
                    editMemberVC.delegate = self
                }
            }
        }
    }
    
}




extension GroupMembersViewController: UITableViewDataSource {
    
    // MARK: UITableViewDataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return group.listOfUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupMemberNameCell", for: indexPath)
        
        let font = UIFont.systemFont(ofSize: 20)
        cell.textLabel?.font = font
        cell.textLabel?.text = group.listOfUsers[indexPath.row].name
        return cell
    }
    
}

extension GroupMembersViewController: UITableViewDelegate {
    
    // MARK: UITableViewDelegate methods
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            group.deleteUser(at: indexPath.row)
            tableView.reloadData()
        }
    }
}

extension GroupMembersViewController: NewEditMemberViewControllerDelegate {
    
    // MARK: NewEditMemberViewControllerDelegate methods
    
    func addMember(name: String) {
        group.addUser(name: name)
        tableView.reloadData()
    }
    
    func editMember(uid: Int, name: String) {
        group.editUser(uid: uid, name: name)
        tableView.reloadData()
    }
}

