//
//  CallLogViewController.swift
//  EP_IOS
//
//  Created by Robert Zhang on 25/9/15.
//  Copyright (c) 2015年 Robert Zhang. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI
class   CallLogViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.tabBarController?.tabBar.selectedItem?.selectedImage = UIImage(named: "footer_02_selected.png")
        self.tabBarController?.tabBar.tintColor = UIColor(red: 50.0/255.0, green: 205.0/255.0, blue: 50.0/255.0, alpha: 1.0)
        
//        self.peoplePickerDelegate = self
        self.navigationItem.leftBarButtonItem = nil
        let nodes = TreeNodeHelper.sharedInstance.getSortedNodes(ContactsCompany.sharedInstance._groups, users: ContactsCompany.sharedInstance._users, defaultExpandLevel: 0)
        
        let tableview: TreeTableView = TreeTableView(frame: CGRectMake(0, 64, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-113), withData: nodes)
        self.view.addSubview(tableview)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}