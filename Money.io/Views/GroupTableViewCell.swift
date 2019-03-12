import UIKit

class GroupTableViewCell: UITableViewCell {
  
  // MARK: Properties
  
  var currentUser: User?
  var group: Group?
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var borrowedLabel: UILabel!
  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var defaultLabel: UILabel!
  
  // MARK: GroupTableViewCell methods
  
  func configureCell() {
    currentUser = GlobalVariables.singleton.currentUser
    if let group = group, let currentUser = currentUser {
      nameLabel.text = group.name
      
      if let owingAmount = group.listOfOwingAmounts[currentUser.uid] {
        if owingAmount > 0 {
          borrowedLabel.text = "You borrowed"
          borrowedLabel.textColor = .red
          
          amountLabel.text = String(format: "$%.2f", abs(owingAmount))
          amountLabel.textColor = .red
        } else if owingAmount < 0 {
          borrowedLabel.text = "You lent out"
          borrowedLabel.textColor = .green
          
          amountLabel.text = String(format: "$%.2f", abs(owingAmount))
          amountLabel.textColor = .green
        } else {
          borrowedLabel.text = ""
          
          amountLabel.text = "Not Involved"
          amountLabel.textColor = .gray
        }
      }
      
      if group.uid == currentUser.defaultGroup?.uid {
        defaultLabel.isHidden = false
      } else {
        defaultLabel.isHidden = true
      }
    }
  }
  
  override func prepareForReuse() {
    currentUser = nil
    group = nil
    nameLabel.text = ""
    borrowedLabel.text = ""
    borrowedLabel.textColor = .black
    amountLabel.text = ""
    amountLabel.textColor = .black
  }
}
