import UIKit

protocol NewEditMemberViewControllerDelegate {
  func addMember(email: String, completion: @escaping (_ success: Bool) -> Void)
}




class NewEditMemberViewController: UIViewController {

  
  // MARK: Properties
  
  var delegate: NewEditMemberViewControllerDelegate?
  
  @IBOutlet weak var textField: UITextField!
  
  // MARK: UIViewController methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: Actions
  
  @IBAction func cancel(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func save(_ sender: UIBarButtonItem) {
    if let email = textField.text {
      delegate?.addMember(email: email) { (success: Bool) in
        if success {
          self.dismiss(animated: true, completion: nil)
        } else {
          // NOTE: Alert the user for unsuccessful search of user
        }
      }
      showSpinner()
    } else {
      // NOTE: Alert the user for missing email of the new user
    }
  }
  
  private func showSpinner() {
    let spinner = UIActivityIndicatorView(style: .gray)
    spinner.translatesAutoresizingMaskIntoConstraints = false
    spinner.startAnimating()
    view.addSubview(spinner)
    spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
  }
}
