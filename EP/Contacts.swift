//
//  Contacts.swift
//  EP
//
//  Created by Robert Zhang on 15/10/10.
//  Copyright © 2015年 robertzhangsh@gmail.com. All rights reserved.
//

import Foundation
import AddressBook

// 使用Addressbook framework

struct ContactItem {
    var firstName: String?
    var lastName: String?
    var nikeName: String?
    var imgIconURL: String?
    var phone: NSMutableDictionary? // 电话号码，多个
    var email: NSMutableDictionary? // 邮箱号码，多个
    var address: NSMutableDictionary? // 地址，多个
    var organization: String? // 机构公司
    var jobTitle: String? // 职称
    var department: String? // 部门
    var note: String? // 备注
    
    init (firstName: String, lastName: String, nikeName: String, imgIconURL: String, phone: NSMutableDictionary, email: NSMutableDictionary, address: NSMutableDictionary, organization: String, jobTitle: String, department: String, note: String){
        self.firstName = firstName
        self.lastName = lastName
        self.nikeName = nikeName
        self.imgIconURL = imgIconURL
        self.phone = phone
        self.email = email
        self.address = address
        self.organization = organization
        self.jobTitle = jobTitle
        self.department = department
        self.note = note
    }
    
    init (firstName: String, lastName: String, nikeName: String, imgIconURL: String, phone: NSMutableDictionary) {
//        self(firstName,lastName,nikeName,imgIconURL,phone,nil,nil,nil,nil,nil,nil)
    }
    
}

class ContactsGroups : NSObject{
    var name: String!
    var detail: String?
    var contacts: NSMutableArray?
    
    init (name: String, detail: String, contacts: NSMutableArray) {
        self.name = name
        self.detail = detail
        self.contacts = contacts
        
    }
    init (name: String){
        self.name = name
    }
    
    func compare(object: ContactsGroups) -> NSComparisonResult {
        if self.name < object.name {
            return NSComparisonResult.OrderedAscending
        } else if self.name > object.name {
            return NSComparisonResult.OrderedDescending
        }
        return NSComparisonResult.OrderedSame
    }
}

class Contacts : NSObject{
    
    
    func getSysContacts() -> [[String:String]] {
        var error:Unmanaged<CFError>?
        var addressBook: ABAddressBookRef? = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
        
        let sysAddressBookStatus = ABAddressBookGetAuthorizationStatus()
        
        if sysAddressBookStatus == .Denied || sysAddressBookStatus == .NotDetermined {
            // Need to ask for authorization
            var authorizedSingal:dispatch_semaphore_t = dispatch_semaphore_create(0)
            var askAuthorization:ABAddressBookRequestAccessCompletionHandler = { success, error in
                if success {
                    ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as NSArray
                    dispatch_semaphore_signal(authorizedSingal)
                }
            }
            ABAddressBookRequestAccessWithCompletion(addressBook, askAuthorization)
            dispatch_semaphore_wait(authorizedSingal, DISPATCH_TIME_FOREVER)
        }
        
        
        return analyzeSysContacts(ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as NSArray )
    }
    
    func analyzeSysContacts(sysContacts:NSArray) -> [[String:String]] {
        var allContacts:Array = [[String:String]]()
    
        for contact in sysContacts {
            var currentContact:Dictionary = [String:String]()
            
            /*
            部分单值属性
            */
            // 姓、姓氏拼音
            currentContact["FirstName"] = ABRecordCopyValue(contact, kABPersonFirstNameProperty)?.takeRetainedValue() as! String? ?? ""
            currentContact["FirstNamePhonetic"] = ABRecordCopyValue(contact, kABPersonFirstNamePhoneticProperty)?.takeRetainedValue() as! String? ?? ""
            // 名、名字拼音
            currentContact["LastName"] = ABRecordCopyValue(contact, kABPersonLastNameProperty)?.takeRetainedValue() as! String? ?? ""
            currentContact["LirstNamePhonetic"] = ABRecordCopyValue(contact, kABPersonLastNamePhoneticProperty)?.takeRetainedValue() as! String? ?? ""
            // 昵称
            currentContact["Nikename"] = ABRecordCopyValue(contact, kABPersonNicknameProperty)?.takeRetainedValue() as! String? ?? ""
            
            // 姓名整理
            currentContact["fullName"] = currentContact["LastName"]! + "" + currentContact["FirstName"]! 
            
            // 公司（组织）
            currentContact["Organization"] = ABRecordCopyValue(contact, kABPersonOrganizationProperty)?.takeRetainedValue() as! String? ?? ""
            // 职位
            currentContact["JobTitle"] = ABRecordCopyValue(contact, kABPersonJobTitleProperty)?.takeRetainedValue() as! String? ?? ""
            // 部门
            currentContact["Department"] = ABRecordCopyValue(contact, kABPersonDepartmentProperty)?.takeRetainedValue() as! String? ?? ""
            // 备注
            currentContact["Note"] = ABRecordCopyValue(contact, kABPersonNoteProperty)?.takeRetainedValue() as! String? ?? ""
            // 生日（类型转换有问题，不可用）
            //currentContact["Brithday"] = ((ABRecordCopyValue(contact, kABPersonBirthdayProperty)?.takeRetainedValue()) as NSDate).description
            
            /*
            部分多值属性
            */
            // 电话
            for (key, value) in analyzeContactProperty(contact, property: kABPersonPhoneProperty,keySuffix: "Phone") ?? ["":""] {
                currentContact[key] = value
            }
            // E-mail
            for (key, value) in analyzeContactProperty(contact, property: kABPersonEmailProperty, keySuffix: "Email") ?? ["":""] {
                currentContact[key] = value
            }
            // 地址
            for (key, value) in analyzeContactProperty(contact, property: kABPersonAddressProperty, keySuffix: "Address") ?? ["":""] {
                currentContact[key] = value
            }
            // 纪念日
            for (key, value) in analyzeContactProperty(contact, property: kABPersonDateProperty, keySuffix: "Date") ?? ["":""] {
                currentContact[key] = value
            }
            // URL
            for (key, value) in analyzeContactProperty(contact, property: kABPersonURLProperty, keySuffix: "URL") ?? ["":""] {
                currentContact[key] = value
            }
            // SNS
            for (key, value) in analyzeContactProperty(contact, property: kABPersonSocialProfileProperty, keySuffix: "_SNS") ?? ["":""] {
                currentContact[key] = value
            }
            
            // 图片
            
            
            allContacts.append(currentContact)
        }
        
        return allContacts
    }
    
    func analyzeContactProperty(contact:ABRecordRef, property:ABPropertyID, keySuffix:String) -> [String:String]? {
        var propertyValues:ABMultiValueRef? = ABRecordCopyValue(contact, property)?.takeRetainedValue()
        if propertyValues != nil {
            //var values:NSMutableArray = NSMutableArray()
            var valueDictionary:Dictionary = [String:String]()
            for i in 0 ..< ABMultiValueGetCount(propertyValues) {
                var label:String = ABMultiValueCopyLabelAtIndex(propertyValues, i).takeRetainedValue() as String
                //                    var label:String = ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(propertyValues, i).takeRetainedValue()).takeRetainedValue() as String
                label += keySuffix
                var value = ABMultiValueCopyValueAtIndex(propertyValues, i)
                switch property {
                    // 地址
                case kABPersonAddressProperty :
                    var addrNSDict:NSMutableDictionary = value.takeRetainedValue() as! NSMutableDictionary
                    valueDictionary[label+"_Country"] = addrNSDict.valueForKey(kABPersonAddressCountryKey as String) as? String ?? ""
                    valueDictionary[label+"_State"] = addrNSDict.valueForKey(kABPersonAddressStateKey as String) as? String ?? ""
                    valueDictionary[label+"_City"] = addrNSDict.valueForKey(kABPersonAddressCityKey as String) as? String ?? ""
                    valueDictionary[label+"_Street"] = addrNSDict.valueForKey(kABPersonAddressStreetKey as String) as? String ?? ""
                    valueDictionary[label+"_Contrycode"] = addrNSDict.valueForKey(kABPersonAddressCountryCodeKey as String) as? String ?? ""
                    
                    // 地址整理
                    valueDictionary["fullAddress"] = (valueDictionary[label+"_Country"]! == "" ? valueDictionary[label+"_Contrycode"]! : valueDictionary[label+"_Country"]!) + ", " + valueDictionary[label+"_State"]! + ", " + valueDictionary[label+"_City"]! + ", " + valueDictionary[label+"_Street"]!
                    // SNS
                case kABPersonSocialProfileProperty :
                    var snsNSDict:NSMutableDictionary = value.takeRetainedValue() as! NSMutableDictionary
                    valueDictionary[label+"_Username"] = snsNSDict.valueForKey(kABPersonSocialProfileUsernameKey as String) as? String ?? ""
                    valueDictionary[label+"_URL"] = snsNSDict.valueForKey(kABPersonSocialProfileURLKey as String) as? String ?? ""
                    valueDictionary[label+"_Serves"] = snsNSDict.valueForKey(kABPersonSocialProfileServiceKey as String) as? String ?? ""
                    // IM
                case kABPersonInstantMessageProperty :
                    var imNSDict:NSMutableDictionary = value.takeRetainedValue() as! NSMutableDictionary
                    valueDictionary[label+"_Serves"] = imNSDict.valueForKey(kABPersonInstantMessageServiceKey as String) as? String ?? ""
                    valueDictionary[label+"_Username"] = imNSDict.valueForKey(kABPersonInstantMessageUsernameKey as String) as? String ?? ""
                    // Date
                case kABPersonDateProperty :
                    valueDictionary[label] = (value.takeRetainedValue() as? NSDate)?.description
                default :
                    valueDictionary[label] = value.takeRetainedValue() as? String ?? ""
                }
                
                
//                NSLog("=====@@@@===="+label+"=="+valueDictionary[label]!)
            }
            return valueDictionary
        }else{
            return nil
        }
    }

    
    // 对联系人进行分组
//    func localGrouping() ->
    
}
