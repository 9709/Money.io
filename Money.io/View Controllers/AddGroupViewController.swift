import UIKit

protocol AddGroupViewControllerDelegate {
  func createGroup(name: String, completion: @escaping (_ success: Bool) -> Void)
}

class AddGroupViewController: UIViewController {
  
  // MARK: Properties
  
  var delegate: AddGroupViewControllerDelegate?
  
  @IBOutlet weak var nameTextField: UITextField!
  
  // MARK: UIViewController methods

  override func viewDidLoad() {
    super.viewDidLoad()
    
    nameTextField.delegate = self
  }
  
  deinit {
    delegate = nil
  }
  
  // MARK: Actions
  
    @IBAction func cancel(_ sender: UIButton) {
          dismiss(animated: true, completion: nil)
    }
  
    @IBAction func save(_ sender: UIButton) {
        if let name = nameTextField.text, name != "" {
            delegate?.createGroup(name: name) { (success: Bool) in
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    // NOTE: Alert the user for unsuccessful group creation
                }
            }
            showSpinner()
        } else {
            // NOTE: Alert the user for missing name of the new group
        }
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

extension AddGroupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
}
