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

    var delegate: NewEditMemberViewControllerDelegate?
    
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func save(_ sender: UIBarButtonItem) {
        if let name = textField.text {
            delegate?.addMember(name: name)
        }
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var textField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

}
