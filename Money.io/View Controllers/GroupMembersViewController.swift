import UIKit

class GroupMembersViewController: UIViewController {
    
    // MARK: Properties
    
    var group: Group?
    
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
        }
    }
    
}




extension GroupMembersViewController: UITableViewDataSource {
    
    // MARK: UITableViewDataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      if let group = group {
        return group.listOfUsers.count
      }
      return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupMemberNameCell", for: indexPath)
        cell.textLabel?.text = group?.listOfUsers[indexPath.row].name
        return cell
    }
    
}

extension GroupMembersViewController: UITableViewDelegate {
    
    // MARK: UITableViewDelegate methods
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            group?.deleteUser(at: indexPath.row)
            tableView.reloadData()
        }
    }
}

extension GroupMembersViewController: NewEditMemberViewControllerDelegate {
  
  // MARK: NewEditMemberViewControllerDelegate methods
  
  func addMember(email: String) {
    if let group = group {
      group.addUser(email: email) { [weak self] in
        OperationQueue.main.addOperation {
          self?.tableView.reloadData()
        }
      }
    }
  }
}

