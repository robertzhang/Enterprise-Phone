//
//  NSData+Extension.swift
//  EP
//
//  Created by robertzhang on 16/3/22.
//  Copyright © 2016年 robert zhang. All rights reserved.
//

import Foundation

extension NSData {
    class func dataFromJSONFile(fileName: String) -> NSData? {
        if let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "json") {
            do {
                let data = try NSData(contentsOfURL: NSURL(fileURLWithPath: path), options: NSDataReadingOptions.DataReadingMappedIfSafe)
                return data
            } catch let error as NSError {
                print(error.localizedDescription)
                return nil
            }
        } else {
            print("Invalid filename/path.")
            return nil
        }
    }
}
