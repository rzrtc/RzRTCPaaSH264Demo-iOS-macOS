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
    
    var remoteItem: VideoChatItem?    
    
    func localJoin(uid: String) {
        localItem.uid = uid
        EngineManager.sharedEngineManager.sourceManager.masterVideoSink = localItem
    }
    
    /*
     清理所有的数据
     */
    func localLeavel() {
        self.localItem.uid = ""
        self.remoteItem = nil
    }
    
    func remoteJoin(uid: String) {
        guard (self.remoteItem == nil) else {
            return;
        }
        
        self.remoteItem = VideoChatItem.init()
        self.remoteItem?.isLocal = false
        self.remoteItem?.uid = uid
    }
    
    func remoteLeave(uid: String) {
        guard (self.remoteItem != nil) else {
            return
        }
        
        guard self.remoteItem?.uid == uid else {
            return
        }
        
        self.remoteItem?.videoPlayView.removeFromSuperview()
        self.remoteItem = nil
    }
    
    
    func remoteAudioOnlineStateChange(uid: String, online: Bool)  {

    }
    
    func remoteAudioSendStateChange(uid: String, state: Bool)  {

    }
    
    func remoteAudioNoReceiveStateChange(uid: String, mute: Bool)  {

    }
    
    
    func remoteVideoOnlineStateChange(uid: String, online: Bool, streamName:String) {
        guard self.remoteItem?.uid == uid else {
            return
        }
        
        self.remoteItem?.videoState.online = online
        self.remoteItem?.videoState.streamName = streamName
        self.delegate?.videoOnlineStateChange?(online: online)
    }
    
    func remoteVideoSendStateChange(uid: String, state: Bool)  {

    }
    
    func remoteVideoNoReceiveStateChange(uid: String, mute: Bool)  {
    }
    
    func remoteVideoDualStreamChange(uid: String, high: Bool) {
    }
}
