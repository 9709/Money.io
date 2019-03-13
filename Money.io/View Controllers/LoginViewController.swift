import UIKit

class LoginViewController: UIViewController {
  
  // MARK: Properties
  
  var newAccount: Bool?
  
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginOrCreate: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
  
  // MARK: UIViewController methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    passwordTextField.delegate = self

    if let newAccount = newAccount {
      if newAccount {
        loginOrCreate.setTitle("Create", for: .normal)
        titleLabel.text = "Create New Account"
      } else {
        nameTextField.isHidden = true
        loginOrCreate.setTitle("Login", for: .normal)
        titleLabel.text = "Login"
      }
    }
  }
  
  deinit {
    newAccount = nil
  }
  
  // MARK: Actions
  
    @IBAction func loginOrCreate(_ sender: UIButton) {
        guard let email = emailTextField.text,
            let password = passwordTextField.text else {
                // NOTE: Alert the user for missing email/password
                return
        }
        
        if let newAccount = newAccount {
            
            // NOTE: Make sure email and password is in a right format
            //        Alert the user if either is not in right format (invalid email format without @ or ., password < 6 characters, etc)
            
            if newAccount {
                guard let name = nameTextField.text else {
                    // NOTE: Alert the user for missing name
                    return
                }
                
                // NOTE: Check if name is in right format?
                
                UserAuthentication.createNewUser(name, email: email, password: password) { (success: Bool) in
                    if success {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        // NOTE: Alert the user for unsuccessful user creation
                    }
                }
                showSpinner()
            } else {
                UserAuthentication.signInUser(withEmail: email, password: password) { (success: Bool) in
                    if success {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        // NOTE: Alert the user for unsuccessful sign in
                    }
                }
                showSpinner()
            }
        }
    }
    
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
  // MARK: Private helper methods
  
  private func showSpinner() {
    let spinner = UIActivityIndicatorView(style: .gray)
    spinner.translatesAutoresizingMaskIntoConstraints = false
    spinner.startAnimating()
    view.addSubview(spinner)
    spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
  }
}


extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passwordTextField.resignFirstResponder()
        return true
    }
}
