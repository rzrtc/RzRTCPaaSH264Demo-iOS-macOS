//
//  ViewController.swift
//  rzpaas_sdk_demo_ios
//
//  Created by ding yusong on 2021/1/5.
//

import UIKit
import RZPaas_iOS


class ViewController: UIViewController, RZRtcEngineDelegate, RZRtcChannelDelegate {
    
    @IBOutlet weak var channelIdTextField: UITextField!
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var joinChannelBtn: UIButton! {
        didSet {
            self.joinChannelBtn.layer.borderWidth = 0.5;
            self.joinChannelBtn.layer.borderColor = UIColor.white.cgColor;
            self.joinChannelBtn.layer.cornerRadius = 4;
        }
    }
    
    
    var inJoinState = false
    
    let keyForUid = "com.paas.demo.key.uid"
    let keyForChannelId = "com.paas.demo.key.channelId"
    
    func loadOldInput() {
        
        let uid = UserDefaults.standard.string(forKey: keyForUid) ?? ""
        let channelId = UserDefaults.standard.string(forKey: keyForChannelId) ?? ""
        self.userIdTextField.text = uid
        self.channelIdTextField.text = channelId
    }
    
    func saveNewInput()  {
        
        let uid = self.userIdTextField.text
        let channelId = self.channelIdTextField.text
        
        UserDefaults.standard.setValue(uid, forKey: keyForUid)
        UserDefaults.standard.setValue(channelId, forKey: keyForChannelId)
        UserDefaults.standard.synchronize()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.loadOldInput()
        
        //要求启动获取权限
        AVCaptureDevice.requestAccess(for: .audio) { (ret) in
            if ret {
                print("获取了麦克风录制权限")
            } else {
                print("获取麦克风录制权限失败")
            }
        }
        
        AVCaptureDevice.requestAccess(for: .video) { (ret) in
            if ret {
                print("获取了摄像头使用权限")
            } else {
                print("获取摄像头使用权限失败")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    
    // 点击进入频道按钮
    @IBAction func btnClick(_ sender: Any) {
        
        if self.inJoinState {
            return
        }
        
        //        self.validateInput()
        
        let uid = self.userIdTextField.text
        let channelId = self.channelIdTextField.text
        
        //        if uid.isEmpty || channelId.isEmpty {
        //            return
        //        }
        
        self.saveNewInput()
        
        EngineManager.sharedEngineManager.delegate = self
        
        var ret = EngineManager.sharedEngineManager.createChannel(channelId: channelId!)
        if !ret {
            return
        }
        
        
        ret = EngineManager.sharedEngineManager.joinChannel(by: uid!)
        if !ret {
            return
        }
        self.inJoinState = true
        
    }
}


extension ViewController {
    
    func validateInput() {
        //        let normalColor = UIColor.white
        //        let emptyColor = UIColor.init(hex: "ffa62f")!
        
        //        if ((self.userIdTextField.text?.isEmpty) != nil) {
        //            self.uidTipLabel.isHidden = false
        //            self.uidLine.backgroundColor = emptyColor
        //        } else {
        //            self.uidTipLabel.isHidden = true
        //            self.uidLine.backgroundColor = normalColor
        //        }
        //
        //        if self.channelIdInput.stringValue.isEmpty {
        //            self.channelIdTipLabel.isHidden = false
        //            self.channelIdLine.backgroundColor = emptyColor
        //        } else {
        //            self.channelIdTipLabel.isHidden = true
        //            self.channelIdLine.backgroundColor = normalColor
        //        }
    }
    
}

extension ViewController: EngineManagerDelegate {
    func shouldHandleInvalidChannelId() {
        
        let title = "进入频道失败"
        let message = "当前频道ID不合法"
        let btnTitle = "确定"
        RZAlertHelper.shared.presentAlert(title: title, message: message, btnTitle: btnTitle, hiddenClose: true) {
        }
    }
    
    func shouldHandleInvalidUid() {
        let title = "进入频道失败"
        let message = "当前用户ID不合法"
        let btnTitle = "确定"
        RZAlertHelper.shared.presentAlert(title: title, message: message, btnTitle: btnTitle, hiddenClose: true) {
            EngineManager.sharedEngineManager.destroyChannel()
        }
    }
    
    func shouldHandleJoinSuccess() {
        
        //reset state
        self.inJoinState = false
        //save channel id
        EngineManager.sharedEngineManager.channelId = self.channelIdTextField.text
        
        let channelViewController:ChannelViewController = ChannelViewController.init()
        self.navigationController?.pushViewController(channelViewController, animated: true)
    }
    
    func shouldHandleJoinError(code: Int, message: String?) {        
        /*
         1. 频道ID合法，频道创建成功，
         2. 进频道uid合法，进入成功
         2. 连接调度服务器失败
         3. 调用leave channel
         4. 收到on leave success 的通知， 销毁channel
         */

        self.inJoinState = false
        EngineManager.sharedEngineManager.leaveChannel()
        
        let title = "进入频道失败"
        let message = "获取服务器资源失败\n错误码\(code)"
        let btnTitle = "确定"
        RZAlertHelper.shared.presentAlert(title: title, message: message, btnTitle: btnTitle, hiddenClose: true) {
        }
    }
    
    func shouldHandleOnLeaveChannleSuccess() {
        EngineManager.sharedEngineManager.destroyChannel()
    }
}


