//
//  LoginViewController.swift
//  EP
//
//  Created by robertzhang on 27/9/15.
//  Copyright (c) 2015年 robertzhangsh@gmail.com. All rights reserved.
//

import UIKit
import SwiftyJSON

class LoginViewController: UIViewController , UITextFieldDelegate{
    
    
    @IBOutlet weak var userTextField: ElasticTextField!
    @IBOutlet weak var passwordTextField: ElasticTextField!
    
    
    @IBOutlet weak var goto: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 给viewcontroller的view添加一个点击事件，用于关闭键盘
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("backgroundTap")))
        // 确定按钮的颜色
        goto.backgroundColor = UIColor(red: 30.0/255.0, green: 144.0/255.0, blue: 205.0/255.0, alpha: 0.7)
        
//        userTextField.keyboardType = UIKeyboardType.Default
        userTextField.returnKeyType = UIReturnKeyType.Next
        userTextField.borderStyle = UITextBorderStyle.RoundedRect
        userTextField.delegate = self
        
//        passwordTextField.keyboardType = UIKeyboardType.Default
        passwordTextField.returnKeyType = UIReturnKeyType.Done
        passwordTextField.borderStyle = UITextBorderStyle.RoundedRect
        passwordTextField.delegate = self
        
        goto.addTarget(self, action: "pressed", forControlEvents: UIControlEvents.TouchUpInside)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // #mark textField delegate begin -----
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        UIView.beginAnimations("ResizeForKeyboard", context: nil)
        UIView.setAnimationDuration(0.30)
        let rect = CGRectMake(0.0,20.0,self.view.frame.size.width,self.view.frame.size.height)
        self.view.frame = rect
        UIView.commitAnimations()
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        var frame = textField.frame
        let offset = CGFloat(-35.0)
        UIView.beginAnimations("ResizeForKeyboard", context: nil)
        UIView.setAnimationDuration(0.30)
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        let rect = CGRectMake(0.0, offset, width, height)
        self.view.frame = rect
        NSLog("---\(self.view.frame.origin.y)---\(self.view.frame.size.height)--\(offset)")
        UIView.commitAnimations()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.view.frame = CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height)
    }
    // #mark textField delegate end -----
    
    
    func backgroundTap() {
        if self.view.frame.origin.y < 0 {
            UIView.beginAnimations("ResizeForKeyboard", context: nil)
            UIView.setAnimationDuration(0.30)
            var rect = CGRectMake(0.0,20.0,self.view.frame.size.width,self.view.frame.size.height)
            self.view.frame = rect
            UIView.commitAnimations()
        }
        userTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    var alert:UIAlertView?
    func pressed() {
        alert = UIAlertView(title: "正在登陆", message: "正在登陆请稍候...", delegate: nil, cancelButtonTitle: nil)
        
        let activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activity.center = CGPointMake(alert!.bounds.size.width / 2.0, alert!.bounds.size.height-40.0)
        activity.startAnimating()
        alert!.addSubview(activity)
        alert!.show()
        
        self.view.addSubview(activity)
        
        guard let jsonData = NSData.dataFromJSONFile("enterprise") else {
            return
        }
        let jsonObject = JSON(data: jsonData)
        if ContactsCompany.sharedInstance.parseJSON(jsonObject.object as! Dictionary) {//解析json数据
            FMDBHelper.shareInstance().deleteAllDBData()
            FMDBHelper.shareInstance().insert(ContactsCompany.sharedInstance._organization!, groups: ContactsCompany.sharedInstance._groups, users: ContactsCompany.sharedInstance._users)
        } else {
            FMDBHelper.shareInstance().query()
        }
        
        //计时器模仿登陆效果
        NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "closeAlert", userInfo: nil, repeats: false)

    }
    
    func closeAlert() {
        alert!.dismissWithClickedButtonIndex(0, animated: false) //关闭alert view
        self.performSegueWithIdentifier("second", sender: self)
    }
    
    
}
