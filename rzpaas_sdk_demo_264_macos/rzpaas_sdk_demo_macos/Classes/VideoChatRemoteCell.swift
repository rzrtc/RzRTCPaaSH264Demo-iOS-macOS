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
        
    func configWith(item: VideoChatItem) {
        self.chatItem = item
        
//        item.addCanvsTo(view: self.videoView)
        self.uidLabel.stringValue = "\(item.uid)"
     
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
