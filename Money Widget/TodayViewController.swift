//
//  TodayViewController.swift
//  Money Widget
//
//  Created by Matthew Chan on 2019-03-06.
//  Copyright © 2019 Matthew Chan. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var owingLable: UILabel!
    @IBOutlet weak var sumLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let owe = UserDefaults.init(suiteName: "group.com.MatthewChan.Money-io.widget")?.value(forKey: "owe") {
            owingLable.text = owe as? String
        }
        if let sum = UserDefaults.init(suiteName: "group.com.MatthewChan.Money-io.widget")?.value(forKey: "sum") {
            if owingLable.text!.contains("You owe:") {
                sumLabel.textColor = UIColor.red
                sumLabel.text = sum as? String
            } else {
                sumLabel.textColor = UIColor.green
                sumLabel.text = sum as? String
            }
        }
        
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        let expanded = activeDisplayMode == .expanded
        preferredContentSize = expanded ? CGSize(width: maxSize.width, height: 200) : maxSize
    }
    
}
