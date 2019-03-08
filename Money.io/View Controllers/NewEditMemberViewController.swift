//
//  NewEditMemberViewController.swift
//  Money.io
//
//  Created by Matthew Chan on 2019-03-02.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

protocol NewEditMemberViewControllerDelegate {
  func addMember(name: String)
}




class NewEditMemberViewController: UIViewController {

  
  // MARK: Properties
  
  var name: String?
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
    if let name = textField.text {
      delegate?.addMember(name: name)
    }
  }
    
}
