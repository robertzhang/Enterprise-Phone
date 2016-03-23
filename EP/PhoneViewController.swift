//
//  File.swift
//  EP_IOS
//
//  Created by Robert Zhang on 25/9/15.
//  Copyright (c) 2015年 Robert Zhang. All rights reserved.
//


import JCDialPad
import FontasticIcons


class PhoneViewController: UIViewController , JCDialPadDelegate{

    // 初始化参数
    var dialpad: JCDialPad = JCDialPad(frame: CGRect(x: 0,y: 0,width:150,height: 280))
    var voiceButton: JCPadButton = JCPadButton()
    var videoButton: JCPadButton = JCPadButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tabBarController?.tabBar.selectedItem?.selectedImage = UIImage(named: "footer_01_selected.png")
        self.tabBarController?.tabBar.tintColor = UIColor(red: 50.0/255.0, green: 205.0/255.0, blue: 50.0/255.0, alpha: 1.0)
        
        dialpad.buttons = JCDialPad.defaultButtons() // 初始化JCDialPad的基本键盘
        
        // 创建视频通话键和语音通话键
        voiceButton.iconView = UIImageView(image: UIImage(named: "call_phone_icon.png"))
        videoButton.iconView = UIImageView(image: UIImage(named: "call_video_icon.png"))
        voiceButton.backgroundColor = UIColor(red: 50.0/255.0, green: 205.0/255.0, blue: 50.0/255.0, alpha: 1.0)
        videoButton.backgroundColor = UIColor(red: 50.0/255.0, green: 50.0/255.0, blue: 205.0/255.0, alpha: 1.0)
        voiceButton.addTarget(self, action: "voicedown", forControlEvents: UIControlEvents.TouchDown)
        voiceButton.addTarget(self, action: "voiceup", forControlEvents: UIControlEvents.TouchUpInside)
        videoButton.addTarget(self, action: "videoedown", forControlEvents: UIControlEvents.TouchDown)
        videoButton.addTarget(self, action: "videoup", forControlEvents: UIControlEvents.TouchUpInside)
        
//        dialpad.buttons.append(videoButton)
        dialpad.buttons.append(videoButton)
        dialpad.buttons.append(voiceButton)
        dialpad.addSubview(videoButton)
        dialpad.addSubview(voiceButton)
        
        dialpad.delegate = self
        
        dialpad.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        
        
        dialpad.backgroundColor = UIColor.whiteColor()
        
        self.view = dialpad
        
    }
    
    func voicedown() {
        voiceButton.backgroundColor = UIColor(red: 150.0/255.0, green: 205.0/255.0, blue: 150.0/255.0, alpha: 1.0)
    }
    func voiceup() {
        voiceButton.backgroundColor = UIColor(red: 50.0/255.0, green: 205.0/255.0, blue: 50.0/255.0, alpha: 1.0)
//        if let number = dialpad.digitsTextField.text {
//            
//        }
        
    }
    func videoedown() {
        videoButton.backgroundColor = UIColor(red: 150.0/255.0, green: 150.0/255.0, blue: 205.0/255.0, alpha: 1.0)
    }
    func videoup() {
        videoButton.backgroundColor = UIColor(red: 50.0/255.0, green: 50.0/255.0, blue: 205.0/255.0, alpha: 1.0)
//        if let number = dialpad.digitsTextField.text{
//            
//        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func dialPad(dialPad: JCDialPad!, shouldInsertText text: String!, forButtonPress button: JCPadButton!) -> Bool {
        return true
    }
    
    
}


