//
//  ChannelViewController.swift
//  rzpaas_sdk_demo_ios
//
//  Created by ding yusong on 2021/1/6.
//

import UIKit

class ChannelViewController: UIViewController{
    
    var inLeaveState = false
    var isKickedOff = false
    
    @IBOutlet weak var localDisplayViewContainer: UIView!
    @IBOutlet weak var remoteDisplayViewContainer: UIView!

    @IBOutlet weak var localDisplayView: RZVideoPlayView!
    @IBOutlet weak var remoteDisplayView: RZVideoPlayView!
    
    @IBOutlet weak var remoteIdContainer: UIView!{
        didSet {
            self.remoteIdContainer.layer.cornerRadius = 12.0;
            self.remoteIdContainer.layer.masksToBounds = true;
        }
    }
    @IBOutlet weak var localIdContainer: UIView!{
        didSet {
            self.localIdContainer.layer.cornerRadius = 12.0;
            self.localIdContainer.layer.masksToBounds = true;
        }
    }
    @IBOutlet weak var localIdLabel: UILabel!
    @IBOutlet weak var remoteIdLabel: UILabel!
    
    
    @IBOutlet weak var channelIdLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let engineManager = EngineManager.sharedEngineManager
        //change engine delegate to self
        engineManager.delegate = self
        
        engineManager.chatManager.delegate = self
        engineManager.enableLocalAudio(enable: true)
        engineManager.enableLocalVideo(enable: true)
        engineManager.publish()
        
        /*
         设置本地用户的视频容器
         */
        engineManager.chatManager.localItem.videoPlayView = self.localDisplayView
        engineManager.chatManager.remoteItem.videoPlayView = self.remoteDisplayView
        
        engineManager.setLocalVideoRenderer(engineManager.chatManager.localItem)
        
        self.channelIdLabel.text = "频道ID: \(engineManager.channelId ?? "")"
        self.localIdLabel.text = "\(engineManager.chatManager.localItem.uid)(我)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func leaveChannelClick(_ sender: Any) {
        self.leaveChannle()
    }
    
}

extension ChannelViewController {
    func leaveChannle()  {
        if self.isKickedOff {
            self.quitAfterKickoff()
            return
        }
        if self.inLeaveState {
            //正在退出频道
            return
        }
        /*
         1. 标记正在退出频道，防止重复触发
         2. 销毁资源
         3. 调用sdk 退出频道
         4. 等待退出频道的通知，收到通知，销毁频道，离开页面
         */
        self.inLeaveState = true
        self.stopPublishAndCleanResource()
        EngineManager.sharedEngineManager.leaveChannel()
    }
    
    func quitAfterKickoff() {
        if self.isKickedOff {
            /*
             1. 如果已经被踢出频道，不需要调用离开频道
             2. 直接销毁资源
             3. 销毁频道
             4. 离开页面
             */
            self.stopPublishAndCleanResource()
            self.destroyChannleAndReturn()
        }
    }
    
    func stopPublishAndCleanResource() {
        /*
         停止音视频采集发送
         */
        EngineManager.sharedEngineManager.enableLocalAudio(enable: false)
        EngineManager.sharedEngineManager.enableLocalVideo(enable: false)
        EngineManager.sharedEngineManager.unpublish()
    }
    
    func destroyChannleAndReturn() {
        /*
         1. 销毁频道
         2. 本地预览设置为空
         3. 离开页面
         */
        EngineManager.sharedEngineManager.destroyChannel()
        EngineManager.sharedEngineManager.setupLocalVideoCanvas(.init())
        self.backToLoginPage()        
    }
    
    func backToLoginPage() {
        self.navigationController?.popViewController(animated: true)
        EngineManager.sharedEngineManager.setLocalVideoRenderer(VideoChatItem.init())
    }
    
}


extension ChannelViewController:EngineManagerDelegate {
    func shouldHandleKickOff() {
        
        //set kickoff flag
        self.isKickedOff = true
        
        let title = "已断开连接"
        let message = "检测到你在其他设备登录\n请返回登录后重试"
        let btnTitle = "返回登录页面"
        RZAlertHelper.shared.presentAlert(title: title, message: message, btnTitle: btnTitle, hiddenClose: false) {
            /*
             1. 此时不需要再调用leave channle
             2. 释放资源
             3. 直接退出
             */
            self.quitAfterKickoff()
        }
        
        
    }
    func shouldHandleConnectLost() {
        
        let title = "已断开连接"
        let message = "网络连接丢失"
        let btnTitle = "返回登录页面"
        RZAlertHelper.shared.presentAlert(title: title, message: message, btnTitle: btnTitle, hiddenClose: false) {
            self.leaveChannle()
        }
        
    }
    func shouldHandleServiceStopped() {
        
        let title = "已断开连接"
        let message = "服务已停止"
        let btnTitle = "返回登录页面"
        RZAlertHelper.shared.presentAlert(title: title, message: message, btnTitle: btnTitle, hiddenClose: false) {
            self.leaveChannle()
        }
    }
    
    func shouldHandleOnLeaveChannleSuccess() {
        /*
         1. 调用 leave channle, 收到了leave channle 的通知
         2. 此时可以销毁频道
         3. 之后离开页面
         */
        self.destroyChannleAndReturn()
    }
    
    func shouldHandleSwitchDualStreamFailed(code: Int, message: String?) {
        
        let title = "切换大小流失败"
        let message = ""
        let btnTitle = "确定"
        RZAlertHelper.shared.presentAlert(title: title, message: message, btnTitle: btnTitle, hiddenClose: false) {
        }
    }
    
    func shouldHandleDeviceNoPermission() {
        let title = "提示"
        let message = "需要摄像头麦克风权限"
        let btnTitle = "确定"
        RZAlertHelper.shared.presentAlert(title: title, message: message, btnTitle: btnTitle, hiddenClose: true) {
            self.leaveChannle()
        }
    }
}

extension ChannelViewController: VideoChatManagerDelegate {
        
    func videoOnlineStateChange(online: Bool) {
        if !online{
            self.remoteDisplayViewContainer.isHidden = true
            return
        }
        let item = EngineManager.sharedEngineManager.chatManager.remoteItem
        EngineManager.sharedEngineManager.setupRemoteVideoCanvas(item, uid: item.uid,streamName: item.videoState.streamName);
        self.remoteIdLabel.text = "\(item.uid)"
        self.remoteDisplayViewContainer.isHidden = false
    }
    
}



