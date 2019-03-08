import UIKit

class GroupTableViewCell: UITableViewCell {
  
  // MARK: Properties
  
  var group: Group?
  
  // MARK: UITableViewCell methods
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  // MARK: GroupTableViewCell methods
  
  func configureCell() {
    textLabel?.text = group?.name
  }
}
