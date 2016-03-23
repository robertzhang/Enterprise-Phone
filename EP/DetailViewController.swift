//
//  DetailViewController.swift
//  EP
//
//  Created by Robert Zhang on 15/10/12.
//  Copyright © 2015年 robertzhangsh@gmail.com. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {
    
    var type: Int? // 0: 表示数据为本地通讯录数据，1：表示数据为企业通讯录数据
    var detailItem :[String:String]? // 存放从本地通讯录获取的一条用户数据
    var data: ContactCompanyItem? // 存放从企业通讯录获取的一条用户数据
    
    @IBOutlet weak var headImg: UIImageView!

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var department: UILabel!
    @IBOutlet weak var userid: UILabel!
    @IBOutlet weak var useridvoice: UIImageView!
    @IBOutlet weak var useridvideo: UIImageView!
    
    @IBOutlet weak var ext: UILabel!
    @IBOutlet weak var extvoice: UIImageView!
    @IBOutlet weak var extvideo: UIImageView!
    
    @IBOutlet weak var mobile: UILabel!
    @IBOutlet weak var mobilevoice: UIImageView!
    
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var phonevoice: UIImageView!
    @IBOutlet weak var email: UILabel!
    
    
    @IBOutlet weak var useridcell: UITableViewCell!
    @IBOutlet weak var extcell: UITableViewCell!
    @IBOutlet weak var mobilecell: UITableViewCell!
    @IBOutlet weak var phonecell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if type == 0 {
//            self.headImg.image = UIImage(named: "default_icon.png")
            self.username.text = detailItem!["fullName"]
            self.department.text = detailItem!["Department"]
            
            self.headImg.image = UIImage(named: "default_icon.png")
            // 获取电话号码
            let keys = (detailItem! as NSDictionary).allKeys //获取所有的key
            let pred = NSPredicate(format: "SELF CONTAINS %@", "_Phone") // 用于过滤的Predicate
            var ks = (keys as NSArray).filteredArrayUsingPredicate(pred) //从keys中过滤出含“_Phone”的key集合
            if ks.count > 0 {
                self.phone.text = detailItem![ks[0] as! String]
            } else {
                self.phonecell.hidden = true
            }
            
            self.phonevoice.userInteractionEnabled = true
            self.phonevoice.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("voice_phone")))

            
            // 隐藏以下内容
            self.useridcell.hidden = true
            self.extcell.hidden = true
            self.mobilecell.hidden = true
            
        } else {
            
            self.headImg.sd_setImageWithURL(NSURL(string: "https://webapi.easipbx.com:9443"+data!.headimage!), placeholderImage: UIImage(named: "default_icon.png"))
            self.username.text = data!.firstName! + data!.lastName!
            if let dep = TreeNodeHelper.sharedInstance.getGroupNameforGroupID(data!.group_id) { //可能返回的是nil
                self.department.text = dep
            }
            self.userid.text = data!.userid!
            self.ext.text = data!.phone!["ext"]
            self.mobile.text = data!.phone!["mobile"]
            self.phone.text = data!.phone!["phone"]
            self.email.text = data!.email!
            
            self.useridvoice.userInteractionEnabled = true
            self.useridvoice.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("voice_voip")))
            self.useridvideo.userInteractionEnabled = true
            self.useridvideo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("video")))
            self.extvoice.userInteractionEnabled = true
            self.extvoice.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("voice_voip")))
            self.extvideo.userInteractionEnabled = true
            self.extvideo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("video")))
            self.mobilevoice.userInteractionEnabled = true
            self.mobilevoice.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("voice_mobile")))
            self.phonevoice.userInteractionEnabled = true
            self.phonevoice.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("voice_phone")))
            
        }
        
    }

    func voice_voip() {
        let number: String
        number = self.userid.text!
        
    }
    
    func voice_mobile() {
        let number: String
        number = self.mobile.text!
        
    }
    
    func voice_phone() {
        let number: String
        number = self.phone.text!
        if !number.isEmpty {
            // 去除号码中的无用字符
            number.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "[]{}(#%-*+=_)\\|~(＜＞$%^&*)_+ ")).joinWithSeparator("")
            
        }
    }
    
    func video() {
        let number: String
        number = self.userid.text!
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
