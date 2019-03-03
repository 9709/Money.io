//
//  NewTransactionViewController.swift
//  Money.io
//
//  Created by Jun Oh on 2019-03-03.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

class NewTransactionViewController: UIViewController {
  
  // MARK: Properties
  
  var group: Group?
  
  @IBOutlet weak var paidByButton: UIButton!
  
  // MARK: UIViewController methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  // MARK: Actions
  
  @IBAction func cancel(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func save(_ sender: UIBarButtonItem) {
  }
  
  // MARK: Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toPaidBySegue" {
      if let viewController = segue.destination as? UINavigationController {
        if let paidByVC = viewController.children[0] as? PaidByViewController {
          paidByVC.group = group
          paidByVC.delegate = self
        }
      }
    }
  }
  
}

extension NewTransactionViewController: PaidByViewControllerDelegate {
  
  // MARK: PaidByViewControllerDelegate methods
  
  func updatePaidByMember(uid: Int) {
    
    if let name = group?.findUserName(from: uid) {
      let title = NSAttributedString(string: name)
      paidByButton.setAttributedTitle(title, for: .normal)
    }
    
  }
}
