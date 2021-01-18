//
//  EngineManager.swift
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

func runOnMainThread(_ work: @escaping ()->()) {
    if Thread.isMainThread {
        work()
    } else {
        DispatchQueue.main.async(execute: DispatchWorkItem.init(block: {
            work()
        }))
    }
}

@objc protocol EngineManagerDelegate {
    @objc optional func shouldHandleInvalidChannelId()
    @objc optional func shouldHandleInvalidUid()
    @objc optional func shouldHandleJoinError(code: Int, message: String?)
    @objc optional func shouldHandleJoinSuccess()
    @objc optional func shouldHandleKickOff()
    @objc optional func shouldHandleConnectLost()
    @objc optional func shouldHandleServiceStopped()
    @objc optional func shouldHandleOnLeaveChannleSuccess()
    @objc optional func shouldHandleSwitchDualStreamFailed(code: Int, message: String?)
    @objc optional func shouldHandleDeviceNoPermission()
}



class EngineManager: NSObject {
    
    static let sharedEngineManager: EngineManager = EngineManager()
    var rtcEngine: RZRtcEngineKit!
    var rtcChannel: RZRtcChannel?
    
    let chatManager = VideoChatManager.init()
    weak var delegate: EngineManagerDelegate?
    
    var channelId: String?
    
    override init() {
        super.init()
        
        let config = RZRtcEngineConfig.init()
        config.codecPriority = .hardware
        config.appId = kAppId
        rtcEngine = RZRtcEngineKit.sharedEngine(with: config, delegate: self)
        
        //设置编码参数
        let encodeConfig = RZVideoEncoderConfiguration.init()
        encodeConfig.dimensions = RZVideoDimension640x480
        encodeConfig.frameRate = RZVideoFrameRate.fps15.rawValue
        encodeConfig.orientationMode = .fixedLandscape
        encodeConfig.mirrorMode = .auto
        
        rtcEngine.setVideoEncoderConfiguration(encodeConfig)
        rtcEngine.setLocalRenderMode(.fit, mirrorMode: .auto)
        
        rtcEngine.enableDualStreamMode(true)
    }
    
    func createChannel(channelId: String) -> Bool {
        self.rtcChannel = self.rtcEngine.createRtcChannel(channelId, profile: .communication, delegate: self)
        return self.rtcChannel != nil
    }
    
    func destroyChannel() {
        self.rtcChannel?.destroy()
        self.rtcChannel = nil
        /*
         清理所有的数据
         */
        self.chatManager.localLeavel()
    }
    
    func joinChannel(by uid: String) -> Bool {
        guard let ret = self.rtcChannel?.join(byUid: uid) else {
            return false
        }
        if ret == RZErrorCode.invalidArgument.rawValue * -1 {
            /*
             进入频道失败
             用户 ID 非法
             */
            runOnMainThread {
                self.delegate?.shouldHandleInvalidUid?()
            }
            return false
        }
        return true
    }
    
    func leaveChannel() {
        self.rtcChannel?.leave()
    }
    
    
    func enableLocalAudio(enable: Bool) {
        self.rtcEngine.enableLocalAudio(enable)
    }
    func enableLocalVideo(enable: Bool)  {
        self.rtcEngine.enableLocalVideo(enable)
    }
    
    func setupLocalVideoCanvas(_ canvas: RZRtcVideoCanvas) {
        self.rtcEngine.setupLocalVideo(canvas)
    }
    
    func setupRemoteVideoCanvas(_ canvas: RZRtcVideoCanvas)  {
        self.rtcChannel?.setupRemoteVideo(canvas)
    }
    
    func muteRemoteAudio(uid: String, mute: Bool)  {
        self.rtcChannel?.muteRemoteAudioStream(uid, mute: mute)
    }
    
    func muteRemoteVideo(uid: String, mute: Bool)  {
        self.rtcChannel?.muteRemoteVideoStream(uid, streamName: "", mute: mute)
    }
    
    func publish() {
        self.rtcChannel?.publish()
    }
    
    func unpublish()  {
        self.rtcChannel?.unpublish()
    }

#if os(OSX)
    
    func allCameras() -> [RZRtcDeviceInfo] {
        return self.rtcEngine.enumerateDevices(.videoCapture) ?? []
    }
    
    func allMicrophone() -> [RZRtcDeviceInfo] {
        return self.rtcEngine.enumerateDevices(.audioRecording) ?? []
    }
    
    func allSpeakers() -> [RZRtcDeviceInfo] {
        return self.rtcEngine.enumerateDevices(.audioPlayout) ?? []
    }
    
    func changeDevice(id: String, type: RZMediaDeviceType) {
        self.rtcEngine.setDevice(type, deviceId: id)
    }
    
    func currentDevice(type: RZMediaDeviceType) -> RZRtcDeviceInfo? {
        return self.rtcEngine.getDeviceInfo(type)
    }
    
#endif
    
#if os(iOS)
    
    func switchCamera() -> Int{
        return Int(self.rtcEngine.switchCamera())
    }
    
#endif

    func switchDualSteam(uid: String, to high: Bool) {
        let type = high ? RZVideoStreamType.high : RZVideoStreamType.low
        self.rtcChannel?.setRemoteVideoStreamTypeForUser(uid, streamName: nil, streamType: type)
        /*
        1. 大小流切换没有回调
        2. 如果切换失败，会有warning 抛出
        3. 切换之后，默认切换成功，记录一下状态
         */
        self.chatManager.remoteVideoDualStreamChange(uid: uid, high: high)
    }    
}

extension EngineManager: RZRtcEngineDelegate {
    
    func rtcEngine(_ engine: RZRtcEngineKit, didOccurError errorCode: Int32, message: String) {
        if errorCode == RZErrorCode.invalidChannelId.rawValue {
            /*
             创建频道失败，
             channelId 非法
             */
            runOnMainThread {
                self.delegate?.shouldHandleInvalidChannelId?()
            }
        }
    }
    
    func rtcEngine(_ engine: RZRtcEngineKit, localAudioStateChange state: RZLocalAudioState, error: RZLocalAudioError) {
                
        switch state {
        case .stopped, .failed:
            print("local audio stoped")
            if error == .deviceNoPermission {
                print("error, local audio has no permission to start")
                runOnMainThread {
                    self.delegate?.shouldHandleDeviceNoPermission?()
                }
            }
        case .recording:
            print("local audio start recording")
        case .sending:
            print("local audio is sending to remote")
        case .noSend:
            print("local user choose not to send audio to remote")
        @unknown default:
            fatalError()
        }
    }
    
    func rtcEngine(_ engine: RZRtcEngineKit, localVideoStateChange state: RZLocalVideoStreamState, error: RZLocalVideoStreamError) {
        
        switch state {
        case .stopped, .failed:
            print("local video stoped")
            if error == .deviceNoPermission {
                print("error, local video has no permission to start")
                runOnMainThread {
                    self.delegate?.shouldHandleDeviceNoPermission?()
                }
            }
        case .capturing:
            print("local video start recording")
        case .sending:
            print("local video is sending to remote")
        case .noSend:
            print("local user choose not to send video to remote")
        @unknown default:
            fatalError()
        }
    }
}

extension EngineManager: RZRtcChannelDelegate {
    
    func rtcChannel(_ rtcChannel: RZRtcChannel, didOccurError errorCode: Int32, message: String) {
        
        if errorCode >= RZErrorCode.lookupScheduleServerFailed.rawValue &&
            errorCode <= RZErrorCode.noAvailableServerResources.rawValue ||
            errorCode == RZErrorCode.invalidAppId.rawValue {
            runOnMainThread {
                //join channel, but occur error, should leave
                self.delegate?.shouldHandleJoinError?(code: Int(errorCode), message: message)
            }
        }
    }
        
    func rtcChannel(_ rtcChannel: RZRtcChannel, didOccurWarning warningCode: Int32, message: String) {
    
        if warningCode >= RZWarningCode.vpmDualNoLowStream.rawValue &&
            warningCode <= RZWarningCode.vpmDualSwitchHighFailed.rawValue {
            //TODO: switch dual stream failed
            runOnMainThread {
                self.delegate?.shouldHandleSwitchDualStreamFailed?(code: Int(warningCode), message: message)
            }
        }
    }
    
    func rtcChannel(_ rtcChannel: RZRtcChannel, didJoinChannelWithUid uid: String, elapsed: Int) {
        runOnMainThread {
            self.chatManager.localJoin(uid: uid)
            self.delegate?.shouldHandleJoinSuccess?()
        }
    }

    func rtcChannel(_ rtcChannel: RZRtcChannel, didLeaveChannelWith stats: RZChannelStats) {
        runOnMainThread {
            self.delegate?.shouldHandleOnLeaveChannleSuccess?()
        }
    }
    
    
    func rtcChannel(_ rtcChannel: RZRtcChannel, didJoinedOfUid uid: String, elapsed: Int) {
        runOnMainThread {
            self.chatManager.remoteJoin(uid: uid)
        }
    }
    
    func rtcChannel(_ rtcChannel: RZRtcChannel, didOfflineOfUid uid: String, reason: RZUserOfflineReason) {
        runOnMainThread {
            self.chatManager.remoteLeave(uid: uid)
        }
    }
    
    
    func rtcChannel(_ rtcChannel: RZRtcChannel, onAudioSubscribeStateChangedOf uid: String, newState state: RZStreamSubscribeState, elapsed: Int) {
        
        
        if state == .online {
            runOnMainThread {
                self.chatManager.remoteAudioOnlineStateChange(uid: uid, online: true)
            }
            return
        }
        
        if state == .offline {
            runOnMainThread {
                self.chatManager.remoteAudioOnlineStateChange(uid: uid, online: false)
            }
            return
        }
        
        if state == .noRecv {
            runOnMainThread {
                self.chatManager.remoteAudioNoReceiveStateChange(uid: uid, mute: true)
            }
            return
        }
        
        if state == .noSend {
            runOnMainThread {
                self.chatManager.remoteAudioSendStateChange(uid: uid, state: false)
            }
            return
        }
        
        
        if [RZStreamSubscribeState.subscribing,
            RZStreamSubscribeState.subscribed,
            RZStreamSubscribeState.frozen].contains(state) {
            
            runOnMainThread {
                self.chatManager.remoteAudioNoReceiveStateChange(uid: uid, mute: false)
                self.chatManager.remoteAudioSendStateChange(uid: uid, state: true)
            }
        }
        
    }
    
    func rtcChannel(_ rtcChannel: RZRtcChannel, onVideoSubscribeStateChangedOf uid: String, streamName: String, newState state: RZStreamSubscribeState, elapsed: Int) {
        
        if state == .online {
            runOnMainThread {
                self.chatManager.remoteVideoOnlineStateChange(uid: uid, online: true)
            }
            return
        }
        
        if state == .offline {
            runOnMainThread {
                self.chatManager.remoteVideoOnlineStateChange(uid: uid, online: false)
            }
            return
        }
        
        if state == .noRecv {
            runOnMainThread {
                self.chatManager.remoteVideoNoReceiveStateChange(uid: uid, mute: true)
            }
            return
        }
        
        if state == .noSend {
            runOnMainThread {
                self.chatManager.remoteVideoSendStateChange(uid: uid, state: false)
            }
            return
        }
        
        
        if [RZStreamSubscribeState.subscribing,
            RZStreamSubscribeState.subscribed,
            RZStreamSubscribeState.frozen].contains(state) {
            
            runOnMainThread {
                self.chatManager.remoteVideoNoReceiveStateChange(uid: uid, mute: false)
                self.chatManager.remoteVideoSendStateChange(uid: uid, state: true)
            }
        }
        
        
    }
    
    
    func rtcChannel(_ rtcChannel: RZRtcChannel, connectionChangedTo state: RZConnectionStateType, reason: RZConnectionChangedReason) {
    
        if state == .failed {
            
            if reason == .changedRejectedByServer {
                //kicked off
                runOnMainThread {
                    self.delegate?.shouldHandleKickOff?()
                }
                 return
            }
            
            /*
             重连20分钟没有连上，需要退出频道
             */
            runOnMainThread {
                self.delegate?.shouldHandleServiceStopped?()
            }
            return
        }

    }
    
    func rtcChannelConnectionDidLost(_ rtcChannel: RZRtcChannel) {
        runOnMainThread {
            self.delegate?.shouldHandleConnectLost?()
        }
    }
        
}




