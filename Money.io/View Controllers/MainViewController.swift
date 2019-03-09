import UIKit

class MainViewController: UIViewController {
  
  // MARK: Properties
  
  var currentUser: User?
  
  @IBOutlet weak var tableView: UITableView!
  
  // MARK: UIViewController methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.dataSource = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    UserAuthentication.getCurrentUser { [weak self] currentUser in
      if let currentUser = currentUser {
        self?.currentUser = currentUser
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
        let currentUser = currentUser, let groups = currentUser.groups,
        let selectedIndexPath = tableView.indexPath(for: groupCell) {
        groupViewVC.group = groups[selectedIndexPath.row]
        groupViewVC.currentUser = currentUser
        groupViewVC.delegate = self
      }
    }
  }
}

extension MainViewController: GroupViewControllerDelegate {
  
  // MARK: GroupViewControllerDelegate methods
  
  
  
}

extension MainViewController: AddGroupViewControllerDelegate {
  func createGroup(name: String) {
    currentUser?.createGroup(name: name) {
      OperationQueue.main.addOperation {
        self.tableView.reloadData()
      }
    }
  }
}

extension MainViewController: UITableViewDataSource {
  
  // MARK: UITableViewDataSource methods
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let currentUser = currentUser, let groups = currentUser.groups {
      return groups.count
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as? GroupTableViewCell else {
      return UITableViewCell()
    }
    
    cell.group = currentUser?.groups?[indexPath.row]
    cell.configureCell()
    
    return cell
  }
  
  
}
