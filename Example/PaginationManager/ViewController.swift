//
//  ViewController.swift
//  PaginationManager
//
//  Created by TaimurAyaz on 10/01/2016.
//  Copyright (c) 2016 TaimurAyaz. All rights reserved.
//

import UIKit
import PaginationManager

class ViewController: UITableViewController {
    
    var numberOfItems: Int = 40
    
    var paginationManager: PaginationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        paginationManager = PaginationManager(scrollView: tableView, direction: .vertical)
        paginationManager?.delegate = self
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItems
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("kExampleCellId", forIndexPath: indexPath)
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
}

extension ViewController: PaginationManagerDelegate {
    
    func paginationManagerDidExceedThreshold(manager: PaginationManager, threshold: CGFloat, reset: PaginationManagerResetBlock) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.numberOfItems += 20
            self.tableView.reloadData()
            reset(shouldReset: true)
        }
    }
}
