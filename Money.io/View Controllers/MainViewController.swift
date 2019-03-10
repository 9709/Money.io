import UIKit

class MainViewController: UIViewController {
  
  // MARK: Properties
  
  var currentUser: User?
  var groups: [Group]?
  
  @IBOutlet weak var tableView: UITableView!
  
  // MARK: UIViewController methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.dataSource = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    UserAuthentication.getCurrentUser { [weak self] (currentUser: User?, groups: [Group]) in
      if let currentUser = currentUser {
        self?.currentUser = currentUser
        GlobalVariables.singleton.currentUser = currentUser
        
        self?.groups = groups
        OperationQueue.main.addOperation {
          self?.tableView.reloadData()
        }
      } else {
        self?.performSegue(withIdentifier: "toSignedOutSegue", sender: self)
      }
    }
  }
  
  // MARK: Actions
  
  @IBAction func signOut(_ sender: UIBarButtonItem) {
    UserAuthentication.signOutUser()
    GlobalVariables.singleton.currentUser = nil
    performSegue(withIdentifier: "toSignedOutSegue", sender: self)
  }
  
  // MARK: Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toAddGroupSegue" {
      if let navigationVC = segue.destination as? UINavigationController,
        let addGroupVC = navigationVC.topViewController as? AddGroupViewController {
        addGroupVC.delegate = self
      }
    } else if segue.identifier == "toGroupViewSegue" {
      if let groupViewVC = segue.destination as? GroupViewController,
        let groupCell = sender as? GroupTableViewCell,
        let groups = groups,
        let selectedIndexPath = tableView.indexPath(for: groupCell) {
        groupViewVC.group = groups[selectedIndexPath.row]
      }
    }
  }
}

extension MainViewController: AddGroupViewControllerDelegate {
  
  // MARK: AddGroupViewControllerDelegate methods
  
  func createGroup(name: String) {
    DataManager.createGroup(name: name) { (group: Group?) in
      if let group = group {
        self.groups?.append(group)
        
        OperationQueue.main.addOperation {
          self.tableView.reloadData()
        }
      } else {
        // NOTE: Alert the user for unsuccessful creation of group
      }
    }
  }
}

extension MainViewController: UITableViewDataSource {
  
  // MARK: UITableViewDataSource methods
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let groups = groups {
      return groups.count
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as? GroupTableViewCell else {
      return UITableViewCell()
    }
    
    cell.group = groups?[indexPath.row]
    cell.configureCell()
    
    return cell
  }
  
  
}
