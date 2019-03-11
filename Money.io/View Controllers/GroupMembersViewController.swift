import UIKit

class GroupMembersViewController: UIViewController {
  
  // MARK: Properties
  
  var group = GlobalVariables.singleton.currentGroup
  
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
      if let viewController = segue.destination as? UINavigationController,
        let addMemberVC = viewController.topViewController as? NewEditMemberViewController {
        addMemberVC.delegate = self
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
    let font = UIFont.systemFont(ofSize: 20)
    cell.textLabel?.font = font
    cell.textLabel?.text = group?.listOfUsers[indexPath.row].name
    cell.detailTextLabel?.text = group?.listOfUsers[indexPath.row].email
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
      group.addUser(email: email) { (success: Bool) in
        if success {
          OperationQueue.main.addOperation {
            self.tableView.reloadData()
          }
        } else {
          // NOTE: Alert user for unsuccessful addition of user
        }
      }
    }
  }
}

