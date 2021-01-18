//
//  VideoChatLocalCell.swift
//  rzpaas_sdk_demo_ios
//
//  Created by ding yusong on 2021/1/8.
//

import UIKit

class VideoChatLocalCell: UICollectionViewCell {

    
    // 用户ID 展示
    @IBOutlet weak var uidLabel: UILabel!
    @IBOutlet weak var idContainerView: UIView!

//    // 流加载状态展示
//    @IBOutlet weak var streamStopTipsLabel: UILabel!
//    @IBOutlet weak var streamStopTipsImageView: UIImageView!
//    @IBOutlet weak var loadingActivity: UIActivityIndicatorView!

    // 前后置摄像头切换 按钮
    @IBOutlet weak var cameraSwitchBtn: UIButton!
    

    @IBOutlet weak var stateView: UIView!
    
    @IBOutlet weak var videoView: UIView! {
        didSet {
//            videoView.wantsLayer = true
//            videoView.layer?.backgroundColor = NSColor.init(hex: "929baa")?.cgColor
        }
    }
        
    weak var item: VideoChatItem?
    func configWith(item: VideoChatItem) {
        self.item = item
        item.addCanvsTo(view: self.videoView)
        self.uidLabel.text = "\(item.uid) (我)"
        
        self.videoView.isHidden = false
        self.stateView.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        let subViews = videoView.subviews
        for view in subViews {
            view.removeFromSuperview()
        }
    }
    
    @IBAction func onClickSwitchCameraButton(_ sender: UIButton) {
        let ret = EngineManager.sharedEngineManager.switchCamera()
        
        if (ret == 0) {
            //切换成功
            self.item?.isFront = !(self.item?.isFront)!
            let title = self.item?.isFront == true ? "前置" : "后置"            
            self.cameraSwitchBtn.setTitle(title, for: .normal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        idContainerView.layer.cornerRadius = 10.0
        idContainerView.layer.masksToBounds = true
        cameraSwitchBtn.layer.cornerRadius = 12.0
        cameraSwitchBtn.layer.masksToBounds = true
    }
    
}
