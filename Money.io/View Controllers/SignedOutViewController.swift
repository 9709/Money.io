import UIKit

class SignedOutViewController: UIViewController {
  
  // MARK: UIViewController methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    UserAuthentication.getCurrentUser { (currentUser: User?, groups: [Group], defaultGroup: Group?) in
      if currentUser != nil {
        self.dismiss(animated: true, completion: nil)
      }
    }
  }
  
  // MARK: Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toCreateNewAccountSegue" {
      if let navigationVC = segue.destination as? UINavigationController,
        let loginVC = navigationVC.topViewController as? LoginViewController {
        loginVC.newAccount = true
      }
    } else if segue.identifier == "toSignInSegue" {
      if let navigationVC = segue.destination as? UINavigationController,
        let loginVC = navigationVC.topViewController as? LoginViewController {
        loginVC.newAccount = false
      }
    }
  }
}
