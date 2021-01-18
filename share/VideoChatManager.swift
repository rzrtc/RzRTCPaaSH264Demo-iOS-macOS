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
    
    @objc optional func shouldAddItem(item: VideoChatItem, at Index: NSInteger)
    @objc optional func shouldRemoveItem(item: VideoChatItem, at Index: NSInteger)
    @objc optional func shouldReloadItem(item: VideoChatItem, at Index: NSInteger)
    @objc optional func shouldReloadAll()
    /*
     1. 远端用户视频上下线的回调
     2. 目前的处理是在收到远端用户视频上线的时候， 给远端用户设置显示视图
     */
    @objc optional func videoOnlineStateChange(item: VideoChatItem, at Index: NSInteger, online: Bool)
}

class VideoChatManager: NSObject {
    
    weak var delegate: VideoChatManagerDelegate? {
        didSet {
            self.delegate?.shouldReloadAll?()
        }
    }
    
    var chatItems: [VideoChatItem] = []
    
    let localItem: VideoChatItem = {
        let item = VideoChatItem.init()
        item.isLocal = true
        return item
    }()
    
    
    
    func localJoin(uid: String) {
        
        localItem.uid = uid
        
        if self.chatItems.contains(localItem) {
            return
        }
        self.chatItems.insert(localItem, at: 0)
        self.delegate?.shouldAddItem?(item: localItem, at: 0)
    }
    
    /*
     清理所有的数据
     */
    func localLeavel() {
        self.chatItems.removeAll()
        self.delegate?.shouldReloadAll?()
    }
    
    func remoteJoin(uid: String) {
        
        if let _ = self.findItemBy(uid: uid) {
            //already join
            return
        }
        let item = VideoChatItem.init()
        item.uid = uid
        item.canvas.uid = uid
        self.chatItems.append(item)
        self.delegate?.shouldAddItem?(item: item, at: self.chatItems.count-1)
    }
    
    func remoteLeave(uid: String) {
        guard let tuple = self.findItemBy(uid: uid) else {
            return
        }
        let item = tuple.0
        let index = tuple.1
        self.chatItems.remove(at: index)
        self.delegate?.shouldRemoveItem?(item: item, at: index)
    }
    
    
    func remoteAudioOnlineStateChange(uid: String, online: Bool)  {
        guard let tuple = self.findItemBy(uid: uid) else {
            return
        }
        let item = tuple.0
        let index = tuple.1
        item.audioState.online = online
        self.delegate?.videoOnlineStateChange?(item: item, at: index, online: online)
        self.delegate?.shouldReloadItem?(item: item, at: index)
    }
    
    func remoteAudioSendStateChange(uid: String, state: Bool)  {
        guard let tuple = self.findItemBy(uid: uid) else {
            return
        }
        let item = tuple.0
        let index = tuple.1
        item.audioState.remoteNoSend = !state
        self.delegate?.shouldReloadItem?(item: item, at: index)
    }
    
    func remoteAudioNoReceiveStateChange(uid: String, mute: Bool)  {
            
        guard let tuple = self.findItemBy(uid: uid) else {
            return
        }
        let item = tuple.0
        let index = tuple.1
        item.audioState.noReceive = mute
        self.delegate?.shouldReloadItem?(item: item, at: index)
    }
    
    
    func remoteVideoOnlineStateChange(uid: String, online: Bool) {
        guard let tuple = self.findItemBy(uid: uid) else {
            return
        }
        let item = tuple.0
        let index = tuple.1
        item.videoState.online = online
        self.delegate?.shouldReloadItem?(item: item, at: index)
    }
    
    func remoteVideoSendStateChange(uid: String, state: Bool)  {
        guard let tuple = self.findItemBy(uid: uid) else {
            return
        }
        let item = tuple.0
        let index = tuple.1
        item.videoState.remoteNoSend = !state
        self.delegate?.shouldReloadItem?(item: item, at: index)
    }
    
    func remoteVideoNoReceiveStateChange(uid: String, mute: Bool)  {
        guard let tuple = self.findItemBy(uid: uid) else {
            return
        }
        let item = tuple.0
        let index = tuple.1
        item.videoState.noReceive = mute
        self.delegate?.shouldReloadItem?(item: item, at: index)
    }
    
    func remoteVideoDualStreamChange(uid: String, high: Bool) {
        guard let tuple = self.findItemBy(uid: uid) else {
            return
        }
        let item = tuple.0
        let index = tuple.1
        item.videoState.isHD = high
        self.delegate?.shouldReloadItem?(item: item, at: index)
    }
}


fileprivate extension VideoChatManager {
    func findItemBy(uid: String) -> (VideoChatItem, Int)? {
        if let index = self.chatItems.firstIndex(where: {$0.uid == uid}) {
            return (self.chatItems[index], index)
        }
        return nil
    }
}
