//
//  VideoChatRemoteCell.swift
//  rzpaas_sdk_demo_macos
//
//  Created by yxibng on 2021/1/6.
//

import Cocoa


@objc protocol VideoChatRemoteCellDelegate {
    
    @objc optional func onClickAudioMute(sender: NSButton, item: VideoChatItem)
    @objc optional func onClickVideoMute(sender: NSButton, item: VideoChatItem)
    @objc optional func onClickSwitchHD(sender: NSButton, item: VideoChatItem)
    
}

class VideoChatRemoteCell: NSCollectionViewItem {

    @IBOutlet weak var uidLabel: NSTextField!
    @IBOutlet weak var stateView: NSView!
    @IBOutlet weak var remoteNoSendTipLabel: NSTextField!
    @IBOutlet weak var noReceiveTipLabel: NSTextField!
    @IBOutlet weak var videoView: NSView! {
        didSet {
            videoView.wantsLayer = true
            videoView.layer?.backgroundColor = NSColor.init(hex: "929baa")?.cgColor
        }
    }
    @IBOutlet weak var videoMuteButton: NSButton!
    @IBOutlet weak var audioMuteButton: NSButton!
    @IBOutlet weak var switchHDButton: NSButton!
    
    weak var delegate: VideoChatRemoteCellDelegate?
    weak var chatItem: VideoChatItem?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        let subViews = videoView.subviews
        for view in subViews {
            view.removeFromSuperview()
        }
    }
    
    
    @IBAction func onClickAudioMuteButton(_ sender: NSButton) {
        guard let item = self.chatItem else {
            return
        }
        self.delegate?.onClickAudioMute?(sender: sender, item: item)

    }
    @IBAction func onClickVideoMuteButton(_ sender: NSButton) {
        guard let item = self.chatItem else {
            return
        }
        self.delegate?.onClickVideoMute?(sender: sender, item: item)
    }

    @IBAction func onClickSwitchHDButton(_ sender: NSButton) {
        guard let item = self.chatItem else {
            return
        }
        self.delegate?.onClickSwitchHD?(sender: sender, item: item)
    }
    
    
    func configWith(item: VideoChatItem) {
        self.chatItem = item
        
        item.addCanvsTo(view: self.videoView)
        self.uidLabel.stringValue = "\(item.uid)"
        
        let audioImageName = (item.audioState.remoteNoSend || item.audioState.noReceive) ? "cell_remote_audio_disable" : "cell_remote_audio_enable"
        let audioTitle = item.audioState.noReceive ? "关闭" : "开启"
    
        
        let videoImageName = (item.videoState.remoteNoSend || item.videoState.noReceive) ? "cell_video_disable" : "cell_video_enable"
        let videoTitle = item.videoState.noReceive ? "关闭" : "开启"
        
        self.audioMuteButton.image = NSImage.init(named: audioImageName)
        self.audioMuteButton.title = audioTitle
        
        self.videoMuteButton.image = NSImage.init(named: videoImageName)
        self.videoMuteButton.title = videoTitle
     
        if item.videoState.noReceive || item.videoState.remoteNoSend {
            
            self.videoView.isHidden = true
            self.stateView.isHidden = false

            self.remoteNoSendTipLabel.isHidden = !item.videoState.remoteNoSend
            self.noReceiveTipLabel.isHidden = !item.videoState.noReceive
        } else {
            self.videoView.isHidden = false
            self.stateView.isHidden = true
        }
    
    }
}
