//
//  VideoChatManager.swift
//  rzpaas_sdk_demo_macos
//
//  Created by yxibng on 2021/1/6.
//

#if os(iOS)
import UIKit
import RZPaas_iOS
#endif

#if os(OSX)
import Cocoa
import RZPaas_macOS
#endif

@objc protocol VideoChatManagerDelegate: NSObjectProtocol {
    
    /*
     1. 远端用户视频上下线的回调
     2. 目前的处理是在收到远端用户视频上线的时候， 给远端用户设置显示视图
     */
    @objc optional func videoOnlineStateChange(online: Bool)
}

class VideoChatManager: NSObject {
    weak var delegate: VideoChatManagerDelegate?

    var localItem: VideoChatItem = {
        let item = VideoChatItem.init()
        item.isLocal = true
        return item
    }()
    
    var remoteItem: VideoChatItem = {
        let item = VideoChatItem.init()
        item.isLocal = false
        return item
    }()
    
    
    func localJoin(uid: String) {
        localItem.uid = uid
        EngineManager.sharedEngineManager.sourceManager.masterVideoSink = localItem
    }
    
    /*
     清理所有的数据
     */
    func localLeavel() {
        self.localItem.uid = ""
        self.remoteItem.uid = ""
    }
    
    func remoteJoin(uid: String) {
        if self.remoteItem.uid.count > 0 {
            return
        }
        self.remoteItem.uid = uid
    }
    
    func remoteLeave(uid: String) {
        if self.remoteItem.uid != uid{
            return
        }
    }
    
    
    func remoteAudioOnlineStateChange(uid: String, online: Bool)  {

    }
    
    func remoteAudioSendStateChange(uid: String, state: Bool)  {

    }
    
    func remoteAudioNoReceiveStateChange(uid: String, mute: Bool)  {

    }
    
    
    func remoteVideoOnlineStateChange(uid: String, online: Bool) {
        if self.remoteItem.uid != uid {
            return
        }
        self.remoteItem.videoState.online = online
        self.delegate?.videoOnlineStateChange?(online: online)
    }
    
    func remoteVideoSendStateChange(uid: String, state: Bool)  {

    }
    
    func remoteVideoNoReceiveStateChange(uid: String, mute: Bool)  {
    }
    
    func remoteVideoDualStreamChange(uid: String, high: Bool) {
    }
}
