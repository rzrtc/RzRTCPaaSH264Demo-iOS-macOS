//
//  VideoChatViewController.swift
//  rzpaas_sdk_demo_macos
//
//  Created by yxibng on 2021/1/6.
//

import Cocoa

class RZMCollectionView: NSCollectionView {
    override func keyDown(with event: NSEvent) {
        //do nothing to prevent key event
    }
}

class VideoChatViewController: NSViewController {

    
    var inLeaveState = false
    var isKickedOff = false
    
    enum CellIdentifier: String {
        case local = "VideoChatLocalCell"
        case remote = "VideoChatRemoteCell"
    }
    
    @IBOutlet weak var channelIdLabel: NSTextField!
    @IBOutlet weak var collectionView: RZMCollectionView! {
        didSet {
            
            collectionView.register(NSNib.init(nibNamed: CellIdentifier.local.rawValue, bundle: nil),
                                    forItemWithIdentifier: .init(CellIdentifier.local.rawValue))
            collectionView.register(NSNib.init(nibNamed: CellIdentifier.remote.rawValue, bundle: nil),
                                    forItemWithIdentifier: .init(CellIdentifier.remote.rawValue))
            
            collectionView.delegate = self
            collectionView.dataSource = self
            
            let layout = NSCollectionViewFlowLayout.init()
            layout.minimumLineSpacing = 1
            layout.minimumInteritemSpacing = 1
            layout.itemSize = CGSize.init(width: 300, height: 224)
            collectionView.collectionViewLayout = layout
        }
    }
    
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
        engineManager.setupLocalVideoCanvas(engineManager.chatManager.localItem.canvas)
        
        self.channelIdLabel.stringValue = "频道ID: \(engineManager.channelId ?? "")"
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = "Video Chat"
        if let closeButton = self.view.window?.standardWindowButton(.closeButton) {
            closeButton.target = self
            closeButton.action = #selector(onClickLeaveChannel(sender:))
        }
    }
    
    @objc func onClickLeaveChannel(sender: Any) {
        self.leaveChannle()
    }
    
    @IBAction func onClickShowMore(_ sender: NSButton) {
        
        let popover = NSPopover.init()
        
        popover.contentSize = CGSize.init(width: 375, height: 200)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = DeviceListViewController.init()
        
        let rect = sender.convert(sender.bounds, to: NSApp.mainWindow?.contentView)
        popover.show(relativeTo: rect, of: NSApp.mainWindow?.contentView ?? self.view, preferredEdge: .minY)
    }
}



extension VideoChatViewController: VideoChatManagerDelegate {
    
    func shouldAddItem(item: VideoChatItem, at Index: NSInteger) {
        self.collectionView.insertItems(at: Set.init(arrayLiteral: IndexPath.init(item: Index, section: 0)))
    }
    
    func shouldRemoveItem(item: VideoChatItem, at Index: NSInteger) {
        self.collectionView.deleteItems(at: Set.init(arrayLiteral: IndexPath.init(item: Index, section: 0)))
    }
    
    func shouldReloadItem(item: VideoChatItem, at Index: NSInteger) {
        self.collectionView.reloadItems(at: Set.init(arrayLiteral: IndexPath.init(item: Index, section: 0)))
    }
    
    
    func videoOnlineStateChange(item: VideoChatItem, at Index: NSInteger, online: Bool) {
        if !online || item.isLocal{
            return
        }
        EngineManager.sharedEngineManager.setupRemoteVideoCanvas(item.canvas)
    }
    
    func shouldReloadAll() {
        self.collectionView.reloadData()
    }
}


extension VideoChatViewController : NSCollectionViewDelegate, NSCollectionViewDataSource{
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return EngineManager.sharedEngineManager.chatManager.chatItems.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let chatItem = EngineManager.sharedEngineManager.chatManager.chatItems[indexPath.item]
        if chatItem.isLocal {
            let cell = collectionView.makeItem(withIdentifier: .init(CellIdentifier.local.rawValue), for: indexPath)  as! VideoChatLocalCell
            cell.configWith(item: chatItem)
            return cell
        } else {
            let cell = collectionView.makeItem(withIdentifier: .init(CellIdentifier.remote.rawValue), for: indexPath) as! VideoChatRemoteCell
            cell.configWith(item: chatItem)
            cell.delegate = self
            return cell
        }
    }
}

extension VideoChatViewController : VideoChatRemoteCellDelegate {
    func onClickAudioMute(sender: NSButton, item: VideoChatItem) {
        
        let nextState = !item.audioState.noReceive
        EngineManager.sharedEngineManager.muteRemoteAudio(uid: item.uid, mute: nextState)
        
    }
    
    func onClickVideoMute(sender: NSButton, item: VideoChatItem) {
        let nextState = !item.videoState.noReceive
        EngineManager.sharedEngineManager.muteRemoteVideo(uid: item.uid, mute: nextState)
    }
    
    func onClickSwitchHD(sender: NSButton, item: VideoChatItem) {
        let nextState = !item.videoState.isHD
        EngineManager.sharedEngineManager.switchDualSteam(uid: item.uid, to: nextState)
    }
}

extension VideoChatViewController: EngineManagerDelegate {
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
        RZAlertHelper.shared.presentAlert(title: title, message: message, btnTitle: btnTitle, hiddenClose: false) {
            self.leaveChannle()
        }
    }
}


extension VideoChatViewController {
    
    
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
        let stroyboard = NSStoryboard.init(name: "Main", bundle: nil)
        if let loginPage = stroyboard.instantiateController(withIdentifier: "LoginViewController") as? LoginViewController {
            if let closeButton = self.view.window?.standardWindowButton(.closeButton) {
                closeButton.target = loginPage
                closeButton.action = #selector(LoginViewController.onClickClose(sender:))
            }
            
            self.view.window?.contentViewController = loginPage
        }
    }
}
