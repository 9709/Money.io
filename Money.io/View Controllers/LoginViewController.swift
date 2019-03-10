import UIKit

class LoginViewController: UIViewController {
  
  // MARK: Properties

  var newAccount: Bool?
  
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
      
      // NOTE: Make sure email and password is in a right format
      //        Alert the user if either is not in right format (invalid email format without @ or ., password < 6 characters, etc)
      
      if newAccount {
        if let name = nameTextField.text {
          
          // NOTE: Check if name is in right format?
          
          UserAuthentication.createNewUser(name, email: email, password: password) { (success: Bool) in
            
            if success {
              self.dismiss(animated: true, completion: nil)
            } else {
              // NOTE: Alert the user for unsuccessful user creation
            }
          }
          
        } else {
          // NOTE: Alert the user for missing name
        }
      } else {
        UserAuthentication.signInUser(withEmail: email, password: password) { (success: Bool) in
          if success {
            self.dismiss(animated: true, completion: nil)
          } else {
            // NOTE: Alert the user for unsuccessful sign in
          }
        }
      }
    } else {
      // NOTE: Alert the user for missing email/password
    }
  }
  
  @IBAction func cancel(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }
}
