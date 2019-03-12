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
        
        // Widet "Show More" button
//        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let userTotalOwing = UserDefaults.init(suiteName: "group.com.MatthewChan.Money-io.widget")?.value(forKey: "userTotalOwing") as? Double {
            if userTotalOwing > 0 {
                owingLable.text = "You owe:"
                sumLabel.textColor = UIColor.red
                sumLabel.text = String(format: "$%.2f", abs(userTotalOwing))
            } else {
                owingLable.text = "You need back:"
                sumLabel.textColor = UIColor.green
                sumLabel.text = String(format: "$%.2f", abs(userTotalOwing))
            }
        }
        
    }
    
    
    @IBAction func launchAppButton(_ sender: UIButton) {
        
        if let url = URL(string: "money://") {
            extensionContext?.open(url, completionHandler: nil)
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    
    
    // MARK: Expand widget "Show More"
    
//    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
//        let expanded = activeDisplayMode == .expanded
//        preferredContentSize = expanded ? CGSize(width: maxSize.width, height: 200) : maxSize
//    }
    
}
