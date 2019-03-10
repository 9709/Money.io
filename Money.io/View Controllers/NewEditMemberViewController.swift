import UIKit

protocol NewEditMemberViewControllerDelegate {
  func addMember(email: String)
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
      delegate?.addMember(email: email)
      dismiss(animated: true, completion: nil)
    } else {
      // NOTE: Alert the user for missing email of the new user
    }
  }
    
}
