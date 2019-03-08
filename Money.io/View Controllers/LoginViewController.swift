import UIKit

class LoginViewController: UIViewController {
  
  // MARK: Properties

  var newAccount: Bool?
  var userAuthentication: UserAuthentication?
  
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var saveButton: UIBarButtonItem!
  
  // MARK: UIViewController methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let newAccount = newAccount {
      if newAccount {
        saveButton.title = "Create"
      } else {
        nameTextField.isHidden = true
        saveButton.title = "Login"
      }
    }
  }
  
  // MARK: Actions
  
  @IBAction func save(_ sender: UIBarButtonItem) {
    if let email = emailTextField.text,
      let password = passwordTextField.text,
      let newAccount = newAccount {
      
      if newAccount {
        if let name = nameTextField.text {
          UserAuthentication.createNewUser(name, email: email, password: password) {
            self.dismiss(animated: true, completion: nil)
          }
        }
      } else {
        UserAuthentication.signInUser(withEmail: email, password: password) {
          self.dismiss(animated: true, completion: nil)
        }
      }
    }
  }
  
  @IBAction func cancel(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }
}
