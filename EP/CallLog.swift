//
//  CallLog.swift
//  EP
//
//  Created by Robert Zhang on 15/11/2.
//  Copyright © 2015年 robertzhangsh@gmail.com. All rights reserved.
//

import Foundation


struct CallLog {
    var number: String?
    var name: String?
    var calltype: Int? // 0-incoming; 1- outgoing; 2- missed
    var calldate: NSDate?
    var duration: String?
    
    init (number: String, name: String, type: Int, date: NSDate, duration: String) {
        self.number = number
        self.name = name
        self.calltype = type
        self.calldate = date
        self.duration = duration
    }
    
    
//    func getArray() -> [AnyObject]{
//        var a = [String]()
////        a.append()
//        append(&a,data: number)
//        append(&a,data: name)
//        append(&a,data: calltype)
//        append(&a,data: calldate)
//        append(&a,data: duration)
//        return a
//    }
    
    private func append(inout a:[String],data: String?){
        if let b = data {
            a.append(b)
        } else {
            a.append("")
        }
    }
}

class CallLogGroup {
    var groups: [CallLog]?
    var count: Int?
}

class CallLogHelper: NSObject {
    
    private var _callLogs: [CallLog] = [] // 通话记录集合
    
    // 单例模式
    class var sharedInstance: CallLogHelper {
        struct Static {
            static var instance: CallLogHelper?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) { // 该函数意味着代码仅会被运行一次，而且此运行是线程同步
            Static.instance = CallLogHelper()
        }
        return Static.instance!
    }
    
    func getCallLogs() -> [CallLog] {
        return _callLogs
    }
    
    // 处理CallLog集合,合并通话记录。合并规则为：合并若干个相邻的同类型当天记录
    func CombineHandle(logs: [CallLog]) {
        var formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = NSLocale(localeIdentifier: "zh_CN")
        var lastdate: NSDate
        for item in logs{
//            lastdate = item.date!
//            item.date!.compare(<#T##other: NSDate##NSDate#>)
        }
    }
    
    
    
    
    
    
    
    
    
    
    
}