//
//  VideoChatRemoteCell.swift
//  rzpaas_sdk_demo_ios
//
//  Created by ding yusong on 2021/1/8.
//

import UIKit

@objc protocol VideoChatRemoteCellDelegate {
    
    @objc optional func onClickAudioMute(sender: UIButton, item: VideoChatItem)
    @objc optional func onClickVideoMute(sender: UIButton, item: VideoChatItem)
    @objc optional func onClickSwitchHD(sender: UIButton, item: VideoChatItem)
}



class VideoChatRemoteCell: UICollectionViewCell {
    
    // 视频绘制canvas
    @IBOutlet weak var videoView: UIView!
    
    // stateView
    @IBOutlet weak var stateView: UIView!
    
    // 用户ID 展示
    @IBOutlet weak var uidLabel: UILabel!
    @IBOutlet weak var idContainerView: UIView!
    
    // 流加载状态展示
    @IBOutlet weak var streamStopTipsLabel: UILabel!
    @IBOutlet weak var streamStopTipsImageView: UIImageView!
    @IBOutlet weak var loadingActivity: UIActivityIndicatorView!
    
    // 是否接受远端视频流 按钮
    @IBOutlet weak var videoMuteButton: UIButton!
    
    // 是否接受远端音频流 按钮
    @IBOutlet weak var audioMuteButton: UIButton!
    
    // HD切换大小流按钮
    @IBOutlet weak var HDBtn: UIButton!
    
    weak var delegate: VideoChatRemoteCellDelegate?
    weak var chatItem: VideoChatItem?
    
    func configWith(item: VideoChatItem) {
        self.chatItem = item
        
        item.addCanvsTo(view: self.videoView)
        self.uidLabel.text = "\(item.uid)"
        
        let audioImageName = (item.audioState.remoteNoSend || item.audioState.noReceive) ? "audio_remote_mute" : "audio_remote_unmute"
        let audioTitle = item.audioState.noReceive ? "关闭" : "开启"
        
        
        let videoImageName = (item.videoState.remoteNoSend || item.videoState.noReceive) ? "video_remote_mute" : "video_remote_unmute"
        let videoTitle = item.videoState.noReceive ? "关闭" : "开启"
        
        self.audioMuteButton.setImage(UIImage.init(named: audioImageName), for: UIControl.State.normal)
        self.audioMuteButton.setTitle(audioTitle, for: UIControl.State.normal)
        
        
        self.videoMuteButton.setImage(UIImage.init(named: videoImageName), for: UIControl.State.normal)
        self.videoMuteButton.setTitle(videoTitle, for: UIControl.State.normal)
                
        if item.videoState.online == false {
            self.videoView.isHidden = true
            self.stateView.isHidden = false
            
            self.loadingActivity.isHidden = false
            self.loadingActivity.startAnimating()
            self.streamStopTipsImageView.isHidden = true
            self.streamStopTipsLabel.text = "加载中"
        }
        else {
            if item.videoState.noReceive {
                
                self.videoView.isHidden = true
                self.stateView.isHidden = false
                
                self.loadingActivity.isHidden = true
                self.loadingActivity.stopAnimating()
                self.streamStopTipsImageView.isHidden = false
                self.streamStopTipsLabel.text = "本地停止拉流"
            }
            else {
                self.videoView.isHidden = false
                self.stateView.isHidden = true
                
                self.loadingActivity.isHidden = true
                self.loadingActivity.stopAnimating()
                self.streamStopTipsImageView.isHidden = true
                self.streamStopTipsLabel.text = ""
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.idContainerView.layer.cornerRadius = 10.0
        self.idContainerView.layer.masksToBounds = true
        self.videoMuteButton.layer.cornerRadius = 12.0
        self.videoMuteButton.layer.masksToBounds = true
        self.audioMuteButton.layer.cornerRadius = 12.0
        self.audioMuteButton.layer.masksToBounds = true
        self.HDBtn.layer.cornerRadius = 12.0
        self.HDBtn.layer.masksToBounds = true
    }
    
    @IBAction func onClickAudioMuteButton(_ sender: UIButton) {
        guard let item = self.chatItem else {
            return
        }
        self.delegate?.onClickAudioMute?(sender: sender, item: item)
        
    }
    @IBAction func onClickVideoMuteButton(_ sender: UIButton) {
        guard let item = self.chatItem else {
            return
        }
        self.delegate?.onClickVideoMute?(sender: sender, item: item)
    }
    
    @IBAction func onClickSwitchHDButton(_ sender: UIButton) {
        guard let item = self.chatItem else {
            return
        }
        self.delegate?.onClickSwitchHD?(sender: sender, item: item)
    }
    
}
