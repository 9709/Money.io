import UIKit

class GroupViewController: UIViewController {
  
  // MARK: Properties
  
  var currentUser: User?
  var group: Group?
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var totalOwingLabel: UILabel!
  @IBOutlet weak var oweStatusLabel: UILabel!
  
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
    
    currentUser = GlobalVariables.singleton.currentUser
    navigationItem.title = group?.name
    tableView.dataSource = self
    tableView.delegate = self
    
    tableView.addSubview(refreshControl)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    populateGroupInformation() {
      return
    }
  }
  
  deinit {
    group = nil
    currentUser = nil
  }
  
  
  // MARK: Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toNewTransactionSegue" {
      if let viewController = segue.destination as? UINavigationController,
        let newTransactionVC = viewController.topViewController as? NewTransactionViewController {
        newTransactionVC.delegate = self
        
        // Siri Shortcut to NewTransactionViewController
        let activity = NSUserActivity(activityType: "com.MatthewChan.Money-io.shortcut.newTransaction")
        activity.title = "Create new transaction"
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        
        self.userActivity = activity
        self.userActivity?.becomeCurrent()
      }
    } else if segue.identifier == "toEditTransactionSegue" {
      if let viewController = segue.destination as? UINavigationController,
        let editTransactionVC = viewController.topViewController as? NewTransactionViewController {
        if let transactionCell = sender as? TransactionTableViewCell,
          let selectedIndexPath = tableView.indexPath(for: transactionCell),
          let monthYear = group?.sortedMonthYear[selectedIndexPath.section],
          let sortedTransactions = group?.sortedTransactions[monthYear] {
          
          let transaction = sortedTransactions[selectedIndexPath.row]
          editTransactionVC.transaction = transaction
          editTransactionVC.delegate = self
        }
      }
    } else if segue.identifier == "toPayBackSegue" {
      if let viewController = segue.destination as? UINavigationController {
        if let payBackVC = viewController.topViewController as? PayBackViewController {
          payBackVC.group = group
          payBackVC.currentUser = currentUser
          payBackVC.delegate = self
          
          // Siri Shortcut to PayBackViewController
          let activity = NSUserActivity(activityType: "com.MatthewChan.Money-io.shortcut.payBack")
          activity.title = "Who do I owe?"
          activity.isEligibleForSearch = true
          activity.isEligibleForPrediction = true
          
          self.userActivity = activity
          self.userActivity?.becomeCurrent()
        }
      }
    }
  }
  // MARK: Siri Shortcut - transitioning from appDelegate -> mainVC -> groupVC -> (newTransactionVC) or (payBackVC)
  
  func siriShortcutNewTransaction() {
    populateGroupInformation {
      self.performSegue(withIdentifier: "toNewTransactionSegue", sender: nil)
    }
  }
  
  func siriShortcutPayBack() {
    populateGroupInformation {
      self.performSegue(withIdentifier: "toPayBackSegue", sender: nil)
    }
  }
  
  
  // MARK: Private helper methods
  
  private func updateTotalOwingAmountLabel() {
    let darkGreen = UIColor(red:0, green:0.80, blue:0, alpha:1.0)

    guard let group = group, let currentUser = currentUser else {
      print("Cannot update owing amount without valid current user or valid group")
      return
    }
    let sum = group.groupOwingAmountForUser(currentUser)
    totalOwingLabel.text = String(format: "$%.2f", abs(sum))
    
    if sum > 0 {
      totalOwingLabel.textColor = .red
      oweStatusLabel.text = "You owe:"
    } else {
      totalOwingLabel.textColor = darkGreen
      oweStatusLabel.text = "You need back:"
    }
    
    if let defaultGroup = currentUser.defaultGroup {
      if group.uid == defaultGroup.uid {
        let userTotalOwing = group.groupOwingAmountForUser(currentUser)
        UserDefaults(suiteName: "group.com.MatthewChan.Money-io.widget")?.set(userTotalOwing, forKey: "userTotalOwing")
      }
    }
  }
  
  private func populateGroupInformation(completion: @escaping () -> Void) {
    if let group = group {
      
      DataManager.getGroup(uid: group.uid) { [weak self] (group: Group?) in
        if let group = group {
          GlobalVariables.singleton.currentGroup = group
          self?.group = group
          
          guard let currentUser = GlobalVariables.singleton.currentUser else {
            print("There must be a current user")
            self?.navigationController?.popViewController(animated: true)
            return
          }
          var currentUserInGroup = false
          for user in group.listOfUsers {
            if user.uid == currentUser.uid {
              currentUserInGroup = true
            }
          }
          if !currentUserInGroup {
            self?.navigationController?.popToRootViewController(animated: true)
            return
          }
          
          OperationQueue.main.addOperation {
            self?.tableView.reloadData()
            
            self?.updateTotalOwingAmountLabel()
            completion()
          }
          
        } else {
          // NOTE: Alert users that group information could not be fetched
          self?.navigationController?.popViewController(animated: true)
        }
      }
    } else {
      
      // NOTE: Alert users that group information could not be fetched
      navigationController?.popViewController(animated: true)
    }
  }
}

extension GroupViewController: NewTransactionViewControllerDelegate {
  
  // MARK: NewTransactionViewControllerDelegate methods
  
  func createTransaction(name: String, paidUsers: [String: Double], splitUsers: [String: Double], owingAmountPerUser: [String: Double], completion: @escaping (_ success: Bool) -> Void) {
    group?.createTransaction(name: name, paidUsers: paidUsers, splitUsers: splitUsers, owingAmountPerUser: owingAmountPerUser, payback: false) { (success: Bool) in
      if success {
        OperationQueue.main.addOperation {
          self.tableView.reloadData()
          completion(success)
        }
      } else {
        completion(success)
      }
    }
  }
  
  func updateTransaction(_ transaction: Transaction, name: String, paidUsers: [String: Double], splitUsers: [String: Double], owingAmountPerUser: [String: Double], createdTimestamp: Date, payback: Bool, completion: @escaping (_ success: Bool) -> Void) {
    group?.updateTransaction(transaction, name: name, paidUsers: paidUsers, splitUsers: splitUsers, owingAmountPerUser: owingAmountPerUser, createdTimestamp: createdTimestamp, payback: payback) { (success: Bool) in
      if success {
        OperationQueue.main.addOperation {
          self.tableView.reloadData()
          completion(success)
        }
      } else {
        completion(success)
      }
    }
  }
  
}
extension GroupViewController: PayBackViewControllerDelegate {
  
  // MARK: PayBackViewControllerDelegate methods
  
  func payBackTransaction(name: String, paidUsers: [String: Double], splitUsers: [String: Double], owingAmountPerUser: [String: Double], completion: @escaping (_ success: Bool) -> Void) {
    group?.createTransaction(name: name, paidUsers: paidUsers, splitUsers: splitUsers, owingAmountPerUser: owingAmountPerUser, payback: true) { (success: Bool) in
      if success {
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

extension GroupViewController: UITableViewDelegate {
  
  // MARK: UITableViewDelegate methods
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      guard let group = group else {
        print("No group")
        return
      }
      let monthYear = group.sortedMonthYear[indexPath.section]
      
      guard let sortedTransactions = group.sortedTransactions[monthYear] else {
        print("No transaction to delete")
        return
      }
      
      let transaction = sortedTransactions[indexPath.row]
      group.deleteTransaction(transaction) { (success: Bool) in
        if success {
          OperationQueue.main.addOperation {
            self.updateTotalOwingAmountLabel()
            self.tableView.reloadData()
          }
        } else {
          // NOTE: Alert user for unsuccessful deletion of transaction
        }
      }
    }
    
  }
  
}

extension GroupViewController: UITableViewDataSource {
  
  // MARK: UITableViewDataSource methods
  
  func numberOfSections(in tableView: UITableView) -> Int {
    if let sectionCount = group?.sortedMonthYear.count {
      return sectionCount
    }
    return 1
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if let sortedMonthYear = group?.sortedMonthYear {
      if sortedMonthYear.count > 0 {
        return sortedMonthYear[section]
      }
    }
    return nil
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let group = group {
      let monthYear = group.sortedMonthYear[section]
      if let sortedTransactions = group.sortedTransactions[monthYear] {
        return sortedTransactions.count
      }
    }
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as? TransactionTableViewCell else {
      return UITableViewCell()
    }
    
    
    guard let group = group else {
      print("We need group to populate the cells")
      return UITableViewCell()
    }
    
    let monthYear = group.sortedMonthYear[indexPath.section]
    if let sortedTransactions = group.sortedTransactions[monthYear] {
      cell.transaction = sortedTransactions[indexPath.row]
      cell.configureCell()
    }
    return cell
  }
  
}

