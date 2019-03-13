import UIKit

class MainViewController: UIViewController {
  
  // MARK: Properties
  
  var currentUser: User?
  var groups: [Group]?
  
  @IBOutlet weak var tableView: UITableView!
  
  lazy var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    
    refreshControl.addTarget(self, action: #selector(refreshTable(_:)), for: .valueChanged)
    
    return refreshControl
  }()
  
  // MARK: Refresh Control methods
  
  @objc func refreshTable(_ refreshControl: UIRefreshControl) {
    checkForCurrentUser {
      refreshControl.endRefreshing()
    }
  }
  
  // MARK: UIViewController methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.dataSource = self
    tableView.delegate = self
    
    tableView.addSubview(refreshControl)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    checkForCurrentUser() {
      return
    }
    
  }
  
  deinit {
    currentUser = nil
    groups = nil
  }
  
  // MARK: Siri Shortcut - transitioning from appDelegate -> mainVC -> groupVC -> (newTransactionVC) or (payBackVC)
  
  func siriShortcutNewTransaction() {
    checkForCurrentUser {
      guard let storyboard = self.storyboard else {
        return
      }
      guard let groupVC = storyboard.instantiateViewController(withIdentifier: "groupViewController") as? GroupViewController else {
        return
      }
      
      groupVC.group = self.currentUser?.defaultGroup
      
      self.navigationController?.show(groupVC, sender: nil)
      groupVC.siriShortcutNewTransaction()
    }
  }
  
  
  func siriShortcutPayBack() {
    checkForCurrentUser {
      guard let storyboard = self.storyboard else {
        return
      }
      guard let groupVC = storyboard.instantiateViewController(withIdentifier: "groupViewController") as? GroupViewController else {
        return
      }
      
      groupVC.group = self.currentUser?.defaultGroup
      
      self.navigationController?.show(groupVC, sender: nil)
      groupVC.siriShortcutPayBack()
    }
  }
  
  // MARK: Actions
  
    @IBAction func signOut(_ sender: UIButton) {
        UserAuthentication.signOutUser()
        GlobalVariables.singleton.currentUser = nil
        UserDefaults(suiteName: "group.com.MatthewChan.Money-io.widget")?.removeObject(forKey: "userTotalOwing")
        UserDefaults(suiteName: "group.com.MatthewChan.Money-io.widget")?.removeObject(forKey: "defaultGroupName")
        UserDefaults(suiteName: "group.com.MatthewChan.Money-io.widget")?.set(false, forKey: "defaultGroupIsSet")
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
  
  // MARK: Private helper methods
  
  private func checkForCurrentUser(completion: @escaping () -> Void) {
    UserAuthentication.getCurrentUser { [weak self] (currentUser: User?, groups: [Group], defaultGroup: Group?) in
      if let currentUser = currentUser {
        self?.currentUser = currentUser
        GlobalVariables.singleton.currentUser = currentUser
        
        self?.groups = groups
        
        
        if let defaultGroup = defaultGroup {
          self?.currentUser?.defaultGroup = defaultGroup
          let userTotalOwing = self?.currentUser?.defaultGroup?.listOfOwingAmounts[currentUser.uid]
          UserDefaults(suiteName: "group.com.MatthewChan.Money-io.widget")?.set(userTotalOwing, forKey: "userTotalOwing")
          UserDefaults(suiteName: "group.com.MatthewChan.Money-io.widget")?.set(defaultGroup.name, forKey: "defaultGroupName")
          UserDefaults(suiteName: "group.com.MatthewChan.Money-io.widget")?.set(true, forKey: "defaultGroupIsSet")
        } else {
          UserDefaults(suiteName: "group.com.MatthewChan.Money-io.widget")?.removeObject(forKey: "userTotalOwing")
          UserDefaults(suiteName: "group.com.MatthewChan.Money-io.widget")?.removeObject(forKey: "defaultGroupName")
          UserDefaults(suiteName: "group.com.MatthewChan.Money-io.widget")?.set(false, forKey: "defaultGroupIsSet")
        }
        
        OperationQueue.main.addOperation {
          self?.tableView.reloadData()
          completion()
        }
      } else {
        self?.performSegue(withIdentifier: "toSignedOutSegue", sender: self)
      }
    }
  }
  
  private func sortGroups() {
    
    if groups != nil {
      groups = groups!.sorted(by: { (former, latter) -> Bool in
        if former.name < latter.name {
          return true
        } else {
          return false
        }
      })
      
      for index in 0..<groups!.count {
        if groups?[index].uid == currentUser?.defaultGroup?.uid {
          if let defaultGroup = groups?.remove(at: index) {
            groups?.insert(defaultGroup, at: 0)
            break
          }
        }
      }
    }
  }
}

extension MainViewController: AddGroupViewControllerDelegate {
  
  // MARK: AddGroupViewControllerDelegate methods
  
  func createGroup(name: String, completion: @escaping (_ success: Bool) -> Void) {
    DataManager.createGroup(name: name) { (group: Group?) in
      if let group = group {
        self.groups?.append(group)
        
        OperationQueue.main.addOperation {
          self.tableView.reloadData()
          completion(true)
        }
      } else {
        completion(false)
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

extension MainViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    return UISwipeActionsConfiguration(actions: [])
  }
  
  
  func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let flag = setDefault(at: indexPath)
    return UISwipeActionsConfiguration(actions: [flag])
  }
  
  func setDefault(at indexPath: IndexPath) -> UIContextualAction {
    guard let groupToSetDefault = groups?[indexPath.row] else {
      print("No group to set default")
      return UIContextualAction()
    }
    guard let currentUser = currentUser else {
      print("No current user for default group to be set")
      return UIContextualAction()
    }
    
    let action = UIContextualAction(style: .normal, title: " Set \nDefault") { (action, view, completion) in
      
      DataManager.setDefaultGroup(groupToSetDefault, for: currentUser) { (success: Bool) in
        if success {
          self.currentUser?.defaultGroup = groupToSetDefault
          self.sortGroups()
          let userTotalOwing = groupToSetDefault.listOfOwingAmounts[currentUser.uid]
          UserDefaults(suiteName: "group.com.MatthewChan.Money-io.widget")?.set(userTotalOwing, forKey: "userTotalOwing")
          UserDefaults(suiteName: "group.com.MatthewChan.Money-io.widget")?.set(groupToSetDefault.name, forKey: "defaultGroupName")
          
          OperationQueue.main.addOperation {
            self.tableView.reloadData()
          }
        } else {
          // NOTE: Notify user for failure of setting default group
        }
      }
      
    }
    
    action.backgroundColor = .orange
    //        action.backgroundColor = groups.isImportant ? UIColor.orange : UIColor.gray
    
    return action
  }
  
}
