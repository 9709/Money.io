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
  func editMember(uid: Int, name: String)
}

class NewEditMemberViewController: UIViewController {
  
  // MARK: Properties
  
  var name: String?
  var uid: Int?
  var delegate: NewEditMemberViewControllerDelegate?
  
  @IBOutlet weak var textField: UITextField!
  
  // MARK: UIViewController methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let name = name {
      textField.text = name
      navigationItem.title = "Edit Member"
    } else {
      navigationItem.title = "Add Member"
    }
  }
  
  // MARK: Actions
  
  @IBAction func cancel(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func save(_ sender: UIBarButtonItem) {
    if let uid = uid {
      if let name = textField.text {
        delegate?.editMember(uid: uid, name: name)
      }
    } else {
      if let name = textField.text {
        delegate?.addMember(name: name)
      }
    }
    dismiss(animated: true, completion: nil)
  }
  
}
