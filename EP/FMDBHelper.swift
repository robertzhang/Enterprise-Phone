//
//  FMDBHelper.swift
//  EP
//
//  Created by Robert Zhang on 15/10/27.
//  Copyright © 2015年 robertzhangsh@gmail.com. All rights reserved.
//

import Foundation


var dataBase:FMDatabase?
var lock:NSLock?
//创建单例
class FMDBHelper {
    class func shareInstance()->FMDBHelper{
        struct qzSingle{
            static var predicate:dispatch_once_t = 0;
            static var instance:FMDBHelper? = nil
        }
        //保证单例只创建一次
        dispatch_once(&qzSingle.predicate,{
            qzSingle.instance = FMDBHelper()
        })
        return qzSingle.instance!
    }
    //构造方法中对数据库进行创建并打开
    init(){
        let path:String = NSHomeDirectory().stringByAppendingString("/Documents/CompanyContacts263.db")
        lock = NSLock()
        dataBase = FMDatabase(path:path)
        if dataBase!.open(){
            // 企业信息表
            let createOrganizationSql:String = "create table if not exists Organization(ID TEXT PRIMARY KEY, NAME TEXT, TOP_GROUP_NAME TEXT, TYPE TEXT, PHONE TEXT, FAX TEXT, ZIPCODE TEXT, PROVINCE TEXT, CITY TEXT, STREET TEXT, COUNTRY TEXT, DESCRIPTION TEXT)"
            // 企业组织部门表
            let createGroupSql:String = "create table if not exists EPGroup(ID TEXT PRIMARY KEY, PARENT_GROUP_ID TEXT, LABEL TEXT, DESCRIPTION TEXT, WEIGHT TEXT, EXT TEXT, PHONE TEXT, HEAD_IMAGE TEXT, ADMIN_ID TEXT)"
            // 企业员工表
            let createUserSql:String = "create table if not exists User(ID TEXT PRIMARY KEY, ORG_ID TEXT, GROUP_ID TEXT, GROUP_WEIGHT TEXT, FIRST_NAME TEXT, LAST_NAME TEXT, USERID TEXT, DEPARTMENT TEXT, HEADIMAGE TEXT, TITLE TEXT, EXT TEXT, PHONE TEXT, MOBILE TEXT, EASIIO TEXT, EMAIL TEXT)"
            // 通话记录表
            let createCallLogSql:String = "create table if not exists CallLog(ID TEXT PRIMARY KEY, NUMBER TEXT, NAME TEXT, TYPE INTEGER, DATE DATE, DURATION TEXT)"
            
            //在这里要传入两个参数：第一个为创建表的sql，第二个为多参数（个人理解，之前只传入sql但是一直报错，个人理解Swift中可返回多参数，传入多参数可能也如此）
            var isSuccessed:Bool = dataBase!.executeUpdate(createOrganizationSql,withArgumentsInArray: [])
            if isSuccessed {
                print("Organization成功！")
            }else{
                print(dataBase!.lastErrorMessage())
            }
            isSuccessed = dataBase!.executeUpdate(createGroupSql,withArgumentsInArray: [])
            if isSuccessed {
                print("Group成功！")
            }else{
                print(dataBase!.lastErrorMessage())
            }
            isSuccessed = dataBase!.executeUpdate(createUserSql,withArgumentsInArray: [])
            if isSuccessed {
                print("User成功！")
            }else{
                print(dataBase!.lastErrorMessage())
            }
            isSuccessed = dataBase!.executeUpdate(createCallLogSql, withArgumentsInArray: [])
            if isSuccessed {
                print("CallLog成功！")
            }else{
                print(dataBase!.lastErrorMessage())
            }
        }
        
    }
    
    // begin === #mark company contacts database helper =====
    // 插入数据到数据库
    func insert(org: Organization, groups: [EPGroup], users: [ContactCompanyItem]) {
        if !dataBase!.executeUpdate("insert into Organization (ID, NAME , TOP_GROUP_NAME , TYPE , PHONE , FAX , ZIPCODE , PROVINCE , CITY , STREET , COUNTRY , DESCRIPTION ) values (?,?,?,?,?,?,?,?,?,?,?,?)", withArgumentsInArray: org.getArray()) {
            print("insert organization failed: \(dataBase?.lastErrorMessage())")
        } else {
            print("insert Organization 成功！")
        }
        
        for group in groups {
//            print("=====group ==\(group.id)=\(group.admin_id)=\(group.description)=\(group.ext)=\(group.head_image)=\(group.label)=\(group.parent_group_id)=\(group.phone)=\(group.weight)")
            if !(dataBase!.executeUpdate("insert into EPGroup (ID, PARENT_GROUP_ID , LABEL , DESCRIPTION , WEIGHT , EXT , PHONE , HEAD_IMAGE , ADMIN_ID) values (?,?,?,?,?,?,?,?,?)", withArgumentsInArray: group.getArray())){
                print("insert group failed: \(dataBase?.lastErrorMessage())")
            }
        }
        
        print("insert group 成功！")
        
        for user in users {
//            print("====user ==\(user.id)===\(user.department)=\(user.email)=\(user.firstName)=\(user.group_id)=\(user.group_weight)=\(user.headimage)=\(user.lastName)=\(user.org_id)=\(user.phone)=\(user.title)=\(user.userid)=\(user.getArray())")
            if !dataBase!.executeUpdate("insert into User(ID, ORG_ID , GROUP_ID , GROUP_WEIGHT , FIRST_NAME , LAST_NAME , USERID , DEPARTMENT , HEADIMAGE , TITLE , EXT , PHONE , MOBILE , EASIIO , EMAIL) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", withArgumentsInArray: user.getArray()) {
                print("insert user failed: \(dataBase?.lastErrorMessage())")
            }
        }
        
        print("insert user 成功！")
    }
    
    // 查询数据
    func query() -> Bool{
        if let rs = dataBase!.executeQuery("select ID, NAME , TOP_GROUP_NAME , TYPE , PHONE , FAX , ZIPCODE , PROVINCE , CITY , STREET , COUNTRY , DESCRIPTION from Organization", withArgumentsInArray: nil) {
            while rs.next() {
                ContactsCompany.sharedInstance._organization = Organization(id: rs.stringForColumn("ID"), name: rs.stringForColumn("NAME"), top_group_name: rs.stringForColumn("TOP_GROUP_NAME"), type: rs.stringForColumn("TYPE"), phone: rs.stringForColumn("PHONE"), fax: rs.stringForColumn("FAX"), zipcode: rs.stringForColumn("ZIPCODE"), province: rs.stringForColumn("PROVINCE"), city: rs.stringForColumn("CITY"), street: rs.stringForColumn("STREET"), country: rs.stringForColumn("COUNTRY"), description: rs.stringForColumn("DESCRIPTION"))
            }
        } else {
            print("select failed: \(dataBase!.lastErrorMessage())")
            return false
        }

        if let rs = dataBase!.executeQuery("select ID, PARENT_GROUP_ID , LABEL , DESCRIPTION , WEIGHT , EXT , PHONE , HEAD_IMAGE , ADMIN_ID from EPGroup", withArgumentsInArray: nil) {
            while rs.next() {
                ContactsCompany.sharedInstance._groups.append(EPGroup(id: rs.stringForColumn("ID"), parent_group_id: rs.stringForColumn("PARENT_GROUP_ID"), name: rs.stringForColumn("LABEL"), description: rs.stringForColumn("DESCRIPTION"), weight: rs.stringForColumn("WEIGHT"), ext: rs.stringForColumn("EXT"), phone: rs.stringForColumn("PHONE"), head_image: rs.stringForColumn("HEAD_IMAGE"), admin_id: rs.stringForColumn("ADMIN_ID")))
            }
        } else {
            print("select failed: \(dataBase!.lastErrorMessage())")
            return false
        }

        if let rs = dataBase!.executeQuery("select ID, ORG_ID , GROUP_ID , GROUP_WEIGHT , FIRST_NAME , LAST_NAME , USERID , DEPARTMENT , HEADIMAGE , TITLE , EXT , PHONE , MOBILE , EASIIO , EMAIL from User", withArgumentsInArray: nil) {
            while rs.next() {
                var phones = [String:String]()

                phones["ext"] = rs.stringForColumn("EXT")
                phones["phone"] = rs.stringForColumn("PHONE")
                phones["mobile"] = rs.stringForColumn("MOBILE")
                phones["easiio"] = rs.stringForColumn("EASIIO")
                ContactsCompany.sharedInstance._users.append(ContactCompanyItem(id: rs.stringForColumn("ID"), org_id: rs.stringForColumn("ORG_ID"), group_id: rs.stringForColumn("GROUP_ID"), group_weight: rs.stringForColumn("GROUP_WEIGHT"), firstName: rs.stringForColumn("FIRST_NAME"), lastName: rs.stringForColumn("LAST_NAME"), userid: rs.stringForColumn("USERID"), department: rs.stringForColumn("DEPARTMENT"), headimage: rs.stringForColumn("HEADIMAGE"), title: rs.stringForColumn("TITLE"), phone: phones, email: rs.stringForColumn("EMAIL")))
            }
        } else {
            print("select failed: \(dataBase!.lastErrorMessage())")
            return false
        }

        return true
    }
    
    // 清空数据库
    func deleteAllDBData() {
        if dataBase!.executeUpdate("delete from Organization", withArgumentsInArray: nil) {
        dataBase!.executeUpdate("update sqlite_sequence set seq=0 where name='Organization'", withArgumentsInArray: nil)
        }
        if dataBase!.executeUpdate("delete from EPGroup", withArgumentsInArray: nil) {
        dataBase!.executeUpdate("update sqlite_sequence set seq=0 where name='EPGroup'", withArgumentsInArray: nil)
        }
        if dataBase!.executeUpdate("delete from User", withArgumentsInArray: nil) {
        dataBase!.executeUpdate("update sqlite_sequence set seq=0 where name='User'", withArgumentsInArray: nil)
        }
    }
    // end === #mark company contacts database helper =====
    
    
    // begin === #mark call log database helper =====
    // 插入新的通话记录
//    func insert (log: CallLog){
//        if !dataBase!.executeUpdate("insert into Organization (ID TEXT PRIMARY KEY, NUMBER TEXT, NAME TEXT, TYPE INTEGER, DATE DATE, DURATION TEXT) values (?,?,?,?,?,?)", withArgumentsInArray: log.getArray()) {
//            print("insert call log failed: \(dataBase?.lastErrorMessage())")
//        } else {
//            print("insert call log 成功！")
//        }
//    }
    
    
    // end === #mark call log database helper =====
    
}