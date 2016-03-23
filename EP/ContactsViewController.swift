//
//  ContactsViewController.swift
//  EP_IOS
//
//  Created by Robert Zhang on 25/9/15.
//  Copyright (c) 2015年 Robert Zhang. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI


class ContactsViewController: UITableViewController , TreeTableViewCellDelegate{
    
    @IBOutlet weak var segmentbar: UISegmentedControl!
    
    var date: [[String:String]]? //本地所有数据
    var localcontacts: [AnyObject] = [] //本地分组后的通讯录
    var searchFilterDate: [[String:String]]? // 查询后的结果
    
    var localtableview: UITableView?
    var companytableview: TreeTableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // tab bar 的设置
        self.tabBarController?.tabBar.selectedItem?.selectedImage = UIImage(named: "footer_03_selected.png")
        self.tabBarController?.tabBar.tintColor = UIColor(red: 50.0/255.0, green: 205.0/255.0, blue: 50.0/255.0, alpha: 1.0)
        
//        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        // searchBar设置
//        self.searchBar.delegate = self
//        self.searchBar.sizeToFit()
//        self.searchBar.showsScopeBar = false
        
        // 处理通讯录内容
        readAllPeople()
        
        localtableview = self.tableView
        let nodes = TreeNodeHelper.sharedInstance.getSortedNodes(ContactsCompany.sharedInstance._groups, users: ContactsCompany.sharedInstance._users, defaultExpandLevel: 0)
    
        // 创建treeableView视图
        companytableview = TreeTableView(frame: CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)), withData: nodes)
        // 设置treeableview视图的上下间距
        companytableview?.contentInset = UIEdgeInsetsMake(20.0+(self.navigationController?.navigationBar.bounds.height)!, 0, (self.tabBarController?.tabBar.bounds.height)!, 0)
        companytableview?.scrollIndicatorInsets = UIEdgeInsetsMake(20.0+(self.navigationController?.navigationBar.bounds.height)!, 0, (self.tabBarController?.tabBar.bounds.height)!, 0)
        companytableview?.treeTableViewCellDelegate = self
    }
    
    // ------------- search 相关 begin---------------
//    func filterContentForSearchText(searchText: NSString, scope: Int) {
//        if (searchText.length == 0) {
//            self.searchFilterDate = self.date
//        }
//        
//        var temp:[String:String]
//        let scopePredicate = NSPredicate(format: "SELF.fullName contains[c] %@", searchText)
//        
//    }
//    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
//        self.searchBar.showsScopeBar = true
//        self.searchBar.sizeToFit()
//        return true
//    }
//    
//    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
//        self.searchBar.showsScopeBar = false
//        self.searchBar.resignFirstResponder()
//        self.searchBar.sizeToFit()
//    }
//    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
//        self.filterContentForSearchText("", scope: -1)
//        self.searchBar.showsScopeBar = false
//        self.searchBar.resignFirstResponder()
//        self.searchBar.sizeToFit()
//    }
//    // 输入文本框内容发生变化的时候被调用
//    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
//        
//    }
    // ------------- search 相关 end ---------------
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.localcontacts.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let contacts = (self.localcontacts[section] as! ContactsGroups).contacts
        return (contacts?.count)!
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (localcontacts[section] as! ContactsGroups).name
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        var indexs: [String] = []
        for item in localcontacts {
            indexs.append((item as! ContactsGroups).name)
        }
        return indexs
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier: String = "contactItem"

        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ContactsTableViewCell
        
        let item: ContactsGroups = localcontacts[indexPath.section] as! ContactsGroups
        let rowDict = item.contacts?.objectAtIndex(indexPath.row) as! NSDictionary
        
//        let rowDict = date![row] as NSDictionary
        cell.contactTitle.text = rowDict.objectForKey("fullName") as? String
        for (key,value) in rowDict {
            if key.componentsSeparatedByString("Phone").count > 1 {
                cell.contactSubTitle.text = value as? String
                break
            }
        }
        cell.contactImg.image = UIImage(named: "default_icon.png")
        
        return cell
    }
    
    // 用来设置tableview的选择
    @IBAction func segmentedControlAction(sender: AnyObject) {
        let seg = sender as! UISegmentedControl
        let index = seg.selectedSegmentIndex
        if index == 0 {
            self.tableView = self.localtableview!
        } else {
            self.tableView = self.companytableview!
        }
    }
    
    
    // # delete begin ------------ table View 内容的修改，暂时不考虑内容内容修改 ------------
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        if sourceIndexPath != destinationIndexPath{
            let object: [String : String] = date![sourceIndexPath.row]
            date!.removeAtIndex(sourceIndexPath.row)
            if destinationIndexPath.row > date?.count {
                date!.append(object)
            } else {
                date?.insert(object, atIndex: destinationIndexPath.row)
            }
        }
    }
    // # delete end ------------ table View 内容的修改，暂时不考虑内容内容修改 ------------
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                if self.segmentbar.selectedSegmentIndex == 0 {
                    let contacts = (self.localcontacts[indexPath.section] as! ContactsGroups).contacts
                    let object = contacts![indexPath.row]
                    (segue.destinationViewController as! DetailViewController).type = 0
                    (segue.destinationViewController as! DetailViewController).detailItem = object as! [String : String]
                } else {
                    let node = (self.tableView as! TreeTableView).mNodes![indexPath.row]
                    let user = TreeNodeHelper.sharedInstance.getUserforUserID(node.id!)
                    (segue.destinationViewController as! DetailViewController).type = 1
                    (segue.destinationViewController as! DetailViewController).data = user
                }
            }
        }
    }
    
    // mark TreeTableViewCellDelegated 的实现
    func cellClick(){
        self.performSegueWithIdentifier("showDetail", sender: self)
    }
    
    
    
    // 获取本地通讯录数据源
    func readAllPeople() {
        let instance: Contacts! = Contacts()
        date = instance.getSysContacts() //加载数据源
        
        let sectionData = sectionSource(date) // 分组
        self.localcontacts = sortedSectionSource(sectionData) //排序
    }
    
    // 对数据源进行分组
    func sectionSource (data: [[String:String]]?) -> [ContactsGroups] {
        var contacts: [ContactsGroups] = []
        var chars: String
        var array: NSMutableArray
        var groupname: String
        var ms: NSMutableString = ""
        
        for item in data! {
            chars = (item as NSDictionary).objectForKey("LastName") as! String
            if chars.isEmpty{
                chars = (item as NSDictionary).objectForKey("FirstName") as! String
            }
            if chars.isEmpty {
                continue
            }
            ms = NSMutableString(string: chars)
            CFStringTransform(ms, nil, kCFStringTransformToLatin, false)//中文拼音
            CFStringTransform(ms, nil, kCFStringTransformStripDiacritics, false)//去除音标
            
            groupname = (ms.uppercaseString as NSString).substringWithRange(NSMakeRange(0, 1))
            var isExist = true
            for bb in contacts {
                if (bb.name == groupname) {
                    bb.contacts?.addObject(item)
                    isExist = false
                    break
                }
            }
            if isExist {
                array = NSMutableArray()
                array.addObject(item)
                contacts.append(ContactsGroups(name: groupname,detail: "", contacts: array))
            }
        }
        return contacts
    }
    
    /*
    * 对分组后的数据进行排序
    * return [AnyObject]  -- 完成排序的数组
    */
    func sortedSectionSource(data: [ContactsGroups]) -> [AnyObject] {
        let selector = Selector.init("compare:")
        let result = NSMutableArray(array: data).sortedArrayUsingSelector(selector)
        
        // 测试
//        var a: ContactsGroups
//        for item in result {
//            a = item as! ContactsGroups
//            NSLog("section ------- \(a.name)--\(a.contacts!.count)")
//        }
        return result
    }
    
    
}
