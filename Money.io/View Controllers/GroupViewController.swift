import UIKit

class GroupViewController: UIViewController {
  
  // MARK: Properties
  
  var currentUser = GlobalVariables.singleton.currentUser
  var group: Group?
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var totalOwingLabel: UILabel!
  @IBOutlet weak var oweStatusLabel: UILabel!
  
  // MARK: UIViewController methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = group?.name
    tableView.dataSource = self
    tableView.delegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if let group = group {
      
      DataManager.getGroup(uid: group.uid) { [weak self] (group: Group?) in
        if let group = group, let currentUser = self?.currentUser {
          GlobalVariables.singleton.currentGroup = group
          self?.group = group
          
          OperationQueue.main.addOperation {
            self?.tableView.reloadData()
            
            let sum = group.groupOwingAmountForUser(currentUser)
            self?.totalOwingLabel.text = String(format: "$%.2f", abs(sum))
            
            if sum > 0 {
              self?.totalOwingLabel.textColor = .red
              self?.oweStatusLabel.text = "You owe:"
            } else {
              self?.totalOwingLabel.textColor = .green
              self?.oweStatusLabel.text = "You need back:"
            }
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
  
  // MARK: Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toNewTransactionSegue" {
      if let viewController = segue.destination as? UINavigationController,
        let newTransactionVC = viewController.topViewController as? NewTransactionViewController {
        newTransactionVC.delegate = self
      }
    } else if segue.identifier == "toEditTransactionSegue" {
      if let viewController = segue.destination as? UINavigationController,
        let editTransactionVC = viewController.topViewController as? NewTransactionViewController {
        if let transactionCell = sender as? TransactionTableViewCell,
          let selectedRow = tableView.indexPath(for: transactionCell)?.row {
          let transaction = group?.listOfTransactions[selectedRow]
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
        }
      }
    }
  }
  
}

extension GroupViewController: NewTransactionViewControllerDelegate {
  
  // MARK: NewTransactionViewControllerDelegate methods
  
  func createTransaction(name: String, paidUsers: [String: Double], splitUsers: [String: Double], owingAmountPerUser: [String: Double]) {
    group?.createTransaction(name: name, paidUsers: paidUsers, splitUsers: splitUsers, owingAmountPerUser: owingAmountPerUser) { (success: Bool) in
      if success {
        OperationQueue.main.addOperation {
          self.tableView.reloadData()
        }
      } else {
        // NOTE: Alert user for unsuccessful creation of transaction
      }
    }
  }
  
  func updateTransaction(_ transaction: Transaction, name: String, paidUsers: [String: Double], splitUsers: [String: Double], owingAmountPerUser: [String: Double]) {
    group?.updateTransaction(transaction, name: name, paidUsers: paidUsers, splitUsers: splitUsers, owingAmountPerUser: owingAmountPerUser) { (success: Bool) in
      if success {
        OperationQueue.main.addOperation {
          self.tableView.reloadData()
        }
      } else {
        // NOTE: Alert user for unsuccessful creation of transaction
      }
    }
  }
}

extension GroupViewController: PayBackViewControllerDelegate {
  
  // MARK: PayBackViewControllerDelegate methods
  
  func payBackTransaction(name: String, paidUsers: [String: Double], splitUsers: [String: Double], owingAmountPerUser: [String: Double], completion: @escaping (_ success: Bool) -> Void) {
    group?.createTransaction(name: name, paidUsers: paidUsers, splitUsers: splitUsers, owingAmountPerUser: owingAmountPerUser) { (success: Bool) in
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
      group?.deleteTransaction(at: indexPath.row)
      tableView.reloadData()
    }
  }
  
}

extension GroupViewController: UITableViewDataSource {
  
  // MARK: UITableViewDataSource methods
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let group = group {
      return group.listOfTransactions.count
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as? TransactionTableViewCell else {
      return UITableViewCell()
    }
    
    cell.transaction = group?.listOfTransactions[indexPath.row]
    cell.configureCell()
    
    return cell
  }
  
  
}
