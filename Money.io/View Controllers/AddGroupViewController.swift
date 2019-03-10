import UIKit

protocol AddGroupViewControllerDelegate {
  func createGroup(name: String)
}

class AddGroupViewController: UIViewController {
  
  // MARK: Properties
  
  var delegate: AddGroupViewControllerDelegate?
  
  @IBOutlet weak var nameTextField: UITextField!
  
  // MARK: UIViewController methods

  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  // MARK: Actions
  
  @IBAction func cancel(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func save(_ sender: UIBarButtonItem) {
    if let name = nameTextField.text {
      delegate?.createGroup(name: name)
      dismiss(animated: true, completion: nil)
    } else {
      // NOTE: Alert the user for missing name of the new group
    }
  }
}
