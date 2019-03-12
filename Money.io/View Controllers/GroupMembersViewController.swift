import UIKit

class GroupMembersViewController: UIViewController {
  
  // MARK: Properties
  
  var group: Group?
  
  var users: [User]?
  
  @IBOutlet weak var tableView: UITableView!
  
  lazy var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    
    refreshControl.addTarget(self, action: #selector(refreshTable(_:)), for: .valueChanged)
    
    return refreshControl
  }()
  
  // MARK: Refresh Control methods
  
  @objc func refreshTable(_ refreshControl: UIRefreshControl) {
    populateGroupInformation {
      refreshControl.endRefreshing()
    }
  }
  
  // MARK: UIViewController methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    group = GlobalVariables.singleton.currentGroup
    tableView.dataSource = self
    tableView.delegate = self
    
    tableView.addSubview(refreshControl)
    
    sortUsers()
  }
  
  deinit {
    group = nil
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
  
  // MARK: Private helper methods
  
  private func populateGroupInformation(completion: @escaping () -> Void) {
    guard let group = group  else {
      // NOTE: Alert users that group information could not be fetched
      dismiss(animated: true, completion: nil)
      return
    }
    
    DataManager.getGroup(uid: group.uid) { [weak self] (group: Group?) in
      if let group = group {
        GlobalVariables.singleton.currentGroup = group
        self?.group = group
        
        OperationQueue.main.addOperation {
          self?.tableView.reloadData()
          completion()
        }
        
      } else {
        // NOTE: Alert users that group information could not be fetched
        self?.navigationController?.popViewController(animated: true)
      }
    }
  }
  
  private func sortUsers() {
    guard let group = group else {
      print("Cannot display members without valid group")
      return
    }
    
    users = group.listOfUsers
    users = users?.sorted(by: { (former, latter) -> Bool in
      if former.name < latter.name {
        return true
      } else {
        return false
      }
    })
    
    guard let users = users else {
      print("No users to sort")
      return
    }
    
    guard let currentUser = GlobalVariables.singleton.currentUser else {
      print("No current user for the app")
      return
    }
    
    for index in 0..<users.count {
      if users[index].uid == currentUser.uid {
        if let user = self.users?.remove(at: index) {
          self.users?.insert(user, at: 0)
          break
        }
      }
    }
  }
  
}




extension GroupMembersViewController: UITableViewDataSource {
  
  // MARK: UITableViewDataSource methods
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let users = users {
      return users.count
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "GroupMemberNameCell", for: indexPath)
    let font = UIFont.systemFont(ofSize: 20)
    cell.textLabel?.font = font
    cell.textLabel?.text = users?[indexPath.row].name
    cell.detailTextLabel?.text = users?[indexPath.row].email
    return cell
  }
  
}

extension GroupMembersViewController: UITableViewDelegate {
  
  // MARK: UITableViewDelegate methods
  
//  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//    if editingStyle == .delete {
//      group?.deleteUser(at: indexPath.row)
//      tableView.reloadData()
//    }
//  }
}

extension GroupMembersViewController: NewEditMemberViewControllerDelegate {
  
  // MARK: NewEditMemberViewControllerDelegate methods
  
  func addMember(email: String, completion: @escaping (_ success: Bool) -> Void) {
    if let group = group {
      group.addUser(email: email) { (success: Bool) in
        if success {
          self.populateGroupInformation {
            OperationQueue.main.addOperation {
              self.sortUsers()
              self.tableView.reloadData()
              completion(success)
            }
          }
        } else {
          completion(success)
        }
      }
    }
  }
}

