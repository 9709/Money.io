import Foundation

class GlobalVariables {
  
  // MARK: Properties
  
  static let singleton = GlobalVariables()
  var currentUser: User?
  var currentGroup: Group?
}
