//
//  ContactsNew.swift
//  EP
//
//  Created by Robert Zhang on 15/10/13.
//  Copyright © 2015年 robertzhangsh@gmail.com. All rights reserved.
//
import UIKit
import Foundation


// 公司实例
struct Organization {
    var id: String
    var name: String?
    var top_group_name: String?
    var type: String?
    var phone: String?
    var fax: String?
    var zipcode: String?
    var province: String?
    var city: String?
    var street: String?
    var country: String?
    var description: String?
    init (id: String, name: String?, top_group_name: String?, type: String?, phone: String?, fax: String?, zipcode: String?, province: String?, city: String?, street: String?, country: String?, description: String?) {
        self.id = id
        self.name = name
        self.top_group_name = top_group_name
        self.type = type
        self.phone = phone
        self.fax = fax
        self.zipcode = zipcode
        self.province = province
        self.city = city
        self.street = street
        self.country = country
        self.description = description
       
    }
    
    init () {
        self.id = "-1"
        self.name = nil
        self.top_group_name = nil
        self.type = nil
        self.phone = nil
        self.fax = nil
        self.zipcode = nil
        self.province = nil
        self.city = nil
        self.street = nil
        self.country = nil
        self.description = nil
        
    }
    
    func getArray() -> [AnyObject]{
        var a = [String]()
        a.append(id)
        a.append(name!)
        a.append(top_group_name!)
        a.append(type!)
        a.append(phone!)
        a.append(fax!)
        a.append(zipcode!)
        a.append(province!)
        a.append(city!)
        a.append(street!)
        a.append(country!)
        a.append(description!)
        return a
    }
    
}


// 组织实例 --- 继承AnyObject是为了让其和ContactCompanyItem存入同一数组
class EPGroup: AnyObject{
    var id: String
    var parent_group_id: String?
    var label: String?
    var description: String?
    var weight: String?
    var ext: String?
    var phone: String?
    var head_image: String?
    var admin_id: String?
    
    init (id: String, parent_group_id: String?, name: String?,description: String?, weight: String?, ext: String?, phone: String?,head_image: String?, admin_id: String?) {
        self.id = id
        self.parent_group_id = parent_group_id
        self.label = name
        self.description = description
        self.weight = weight
        self.ext = ext
        self.phone = phone
        self.head_image = head_image
        self.admin_id = admin_id
    }
    
    init () {
        self.id = "-2"
        self.parent_group_id = nil
        self.label = nil
        self.description = nil
        self.weight = nil
        self.ext = nil
        self.phone = nil
        self.head_image = nil
        self.admin_id = nil
    }
    
    func getArray() -> [AnyObject]{
        var a = [String]()
        a.append(id)
        append(&a, data: parent_group_id)
        append(&a, data: label)
        append(&a, data: description)
        append(&a, data: weight)
        append(&a, data: ext)
        append(&a, data: phone)
        append(&a, data: head_image)
        append(&a, data: admin_id)
        return a
    }
    
    private func append(inout a:[String],data: String?){
        if let b = data {
            a.append(b)
        } else {
            a.append("")
        }
    }
}

// 用户实例
class ContactCompanyItem: AnyObject{
    var id: String
    var org_id: String?
    var group_id: String?
    var group_weight: String?
    var firstName: String?
    var lastName: String?
    var userid: String?
    var department: String? // 部门
    var headimage: String?
    var title: String? // 职称
//    var extphone: String? // ext phone
//    var phonephone: String?  // phone
//    var mobilephone: String? // mobile phone
//    var easiiophone: String? // easiio phone
    var phone: [String:String]? // 电话号码，多个
    var email: String? // 邮箱号码，多个
    
    init (id: String, org_id: String?, group_id: String?, group_weight: String?, firstName: String?, lastName: String?, userid: String?, department: String?, headimage: String?, title: String?, phone: [String:String], email: String?) {
        self.id = id
        self.org_id = org_id
        self.group_id = group_id
        self.group_weight = group_weight
        self.firstName = firstName
        self.lastName = lastName
        self.userid = userid
        self.department = department
        self.headimage = headimage
        self.title = title
        self.phone = phone
        self.email = email
    }
    
    init () {
        self.id = "-3"
        self.org_id = nil
        self.group_id = nil
        self.group_weight = nil
        self.firstName = nil
        self.lastName = nil
        self.userid = nil
        self.department = nil
        self.headimage = nil
        self.title = nil
        self.phone = nil
        self.email = nil
    }
    
    func getArray() -> [AnyObject]{
        var a = [String]()
        a.append(id)
        append(&a,data: org_id)
        append(&a,data: group_id)
        append(&a,data: group_weight)
        append(&a,data: firstName)
        append(&a,data: lastName)
        append(&a,data: userid)
        append(&a,data: department)
        append(&a,data: headimage)
        append(&a,data: title)
        append(&a,data: phone!["ext"])
        append(&a,data: phone!["phone"])
        append(&a,data: phone!["mobile"])
        append(&a,data: phone!["easiio"])
        append(&a,data: email)
        return a
    }
    
    private func append(inout a:[String],data: String?){
        if let b = data {
            a.append(b)
        } else {
            a.append("")
        }
    }
}

class ContactsCompany{
    
    var _organization: Organization? // 公司信息
    var _groups: [EPGroup] = []// 部门信息
    var _users: [ContactCompanyItem] = [] //用户信息
    
    // 单例模式
    class var sharedInstance: ContactsCompany {
        struct Static {
            static var instance: ContactsCompany?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) { // 该函数意味着代码仅会被运行一次，而且此运行是线程同步
            Static.instance = ContactsCompany()
        }
        return Static.instance!
    }
    
    /**
     解析json数据 : return false 表示不用更新数据库，true表示需要更新数据库
     */
    func parseJSON(jsonStr: [NSObject : AnyObject]) -> Bool{
        if let status = jsonStr["response"]!["status"] {
            if (status as! String) != "ok" {
//                return
            }
        }
        
        let update_time = jsonStr["response"]!["update_time"] as! NSNumber // 最后一次更新的时间
        var userDefault = NSUserDefaults.standardUserDefaults()
        var old_update_time = userDefault.integerForKey("update_time")
        if old_update_time == update_time{
            return false
        } else {
            userDefault.setInteger(update_time.integerValue, forKey: "update_time")
        }
        
        
        
        // 解析出organization
        let org = jsonStr["response"]!["organization"]! as! NSDictionary
        self._organization = Organization(id: (org["id"] as! String),
                name: (org["name"]!.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)),//也可不这样用
                top_group_name: (org["top_group_name"]!.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)),
                type: (org["type"] as! String),
                phone: (org["phone"] as! String),
                fax: (org["fax"] as! String),
                zipcode: (org["zipcode"] as? String),
                province: (org["province"]!.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)),
                city: (org["city"]!.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)),
                street: (org["street"]!.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)),
                country: (org["country"]!.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)),
                description: (org["description"]!.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)))

        // 解析出groups
        let groupJson = jsonStr["response"]!["groups"] as! NSArray
        var dic: NSDictionary
        for item in groupJson {
            dic = item as! NSDictionary
            self._groups.append(EPGroup(id: (dic["id"] as! String), parent_group_id: (dic["parent_group_id"] as? String), name: (dic["name"] as? String), description: (dic["description"] as? String), weight: (dic["weight"] as! String), ext: (dic["ext"] as? String), phone: (dic["phone"] as? String), head_image: (dic["head_image"] as? String), admin_id: (dic["admin_id"] as? String)))
        }
        
        //解析出users
        let usersJson = jsonStr["response"]!["users"] as! NSArray
        for item in usersJson {
            dic = item as! NSDictionary
            
            var phones = [String: String]()
            for phone in item["contactinfo"]!["Phone"] as! NSArray {
                phones[phone["phoneLabel"] as! String] = phone["phoneNumber"] as? String
            }
            
            
            self._users.append(ContactCompanyItem(id: (dic["id"] as! String), org_id: (dic["org_id"] as? String), group_id: (dic["group_id"] as? String), group_weight: (dic["group_weight"] as? String), firstName: (dic["firstname"] as? String), lastName: (dic["lastname"] as? String), userid: (dic["userid"] as? String), department: (dic["department"] as? String), headimage: (dic["headimage"] as? String), title: (dic["title"] as? String), phone: phones, email: (dic["contactinfo"]!["Email"]![0]["emailAddress"] as? String)))
            
        }
//        for item in usersJson {
//         var a = item["department"] as? String
//        NSLog("======\(item)===")
//        }
//        for item in _users {
//         var a =  item
//        NSLog("------Users:  \(a.email)-")
//        }
        NSLog("---\(_groups.count)-------\(_users.count)---")
        return true
    }
    
    
}

