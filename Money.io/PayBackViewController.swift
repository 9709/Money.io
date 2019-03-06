//
//  PayBackViewController.swift
//  Money.io
//
//  Created by Matthew Chan on 2019-03-04.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit

class PayBackViewController: UIViewController {

    // MARK: Properties
    
    var group: Group!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
    }
    

    
    
    // MARK: Actions
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func save(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

}




extension PayBackViewController: UITableViewDataSource {
    
    // MARK: UITableViewDataSource methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return group.listOfUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PayBackCell", for: indexPath) as? PayBackTableViewCell else {
            return UITableViewCell()
        }
        
        cell.user = group.listOfUsers[indexPath.row]
        cell.configureCell()
        
        return cell
    }
    

}
