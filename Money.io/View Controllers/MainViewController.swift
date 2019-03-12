import UIKit

class MainViewController: UIViewController {
    
    // MARK: Properties
    
    var currentUser: User?
    var groups: [Group]?
    var defaultGroup: Group?
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: UIViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkForCurrentUser() {
            return
        }
        
    }
    
    // MARK: Private helper methods
    
    private func checkForCurrentUser(completion: @escaping () -> Void) {
        UserAuthentication.getCurrentUser { [weak self] (currentUser: User?, groups: [Group]) in
            if let currentUser = currentUser {
                self?.currentUser = currentUser
                GlobalVariables.singleton.currentUser = currentUser
                
                self?.groups = groups
                if self?.groups != nil && groups.count > 0 {
                    self?.groups![0].isDefault = true
                    self?.defaultGroup = self?.groups![0]
                    let userTotalOwing = self?.defaultGroup!.listOfOwingAmounts[currentUser.uid]
                    UserDefaults.init(suiteName: "group.com.MatthewChan.Money-io.widget")?.set(userTotalOwing, forKey: "userTotalOwing")
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
    
    // MARK: Siri Shortcut - transitioning from appDelegate -> mainVC -> groupVC -> (newTransactionVC) or (payBackVC)
    
    func siriShortcutNewTransaction() {
        checkForCurrentUser {
            guard let storyboard = self.storyboard else {
                return
            }
            guard let groupVC = storyboard.instantiateViewController(withIdentifier: "groupViewController") as? GroupViewController else {
                return
            }
            
            groupVC.group = self.defaultGroup
            
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
            
            groupVC.group = self.defaultGroup
            
            self.navigationController?.show(groupVC, sender: nil)
            groupVC.siriShortcutPayBack()
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
            if let groupViewVC = segue.destination as? GroupViewController {
                if let groupCell = sender as? GroupTableViewCell,
                    let groups = groups,
                    let selectedIndexPath = tableView.indexPath(for: groupCell) {
                    groupViewVC.group = groups[selectedIndexPath.row]
                }
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

extension MainViewController: UITableViewDelegate {
    
    
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let flag = setDefault(at: indexPath)
        return UISwipeActionsConfiguration(actions: [flag])
    }
    
    func setDefault(at indexPath: IndexPath) -> UIContextualAction {
        let groups = self.groups?[indexPath.row]
        let action = UIContextualAction(style: .normal, title: " Set \nDefault") { (action, view, completion) in
            if let groups = groups {
                if self.groups != nil {
                    for group in self.groups! {
                        group.isDefault = false
                    }
                }
                groups.isDefault = true
                if let currentUser = self.currentUser {
                    let userTotalOwing = groups.listOfOwingAmounts[currentUser.uid]
                    UserDefaults.init(suiteName: "group.com.MatthewChan.Money-io.widget")?.set(userTotalOwing, forKey: "userTotalOwing")
                }
                completion(true)
            }
        }
        //        action.image = UIImage(named: "Pin")
        action.backgroundColor = UIColor.orange
        //        action.backgroundColor = groups.isImportant ? UIColor.orange : UIColor.gray
        
        return action
    }
    
}
