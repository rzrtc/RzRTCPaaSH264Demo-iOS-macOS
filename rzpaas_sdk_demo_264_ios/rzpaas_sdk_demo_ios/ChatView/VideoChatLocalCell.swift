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
//        item.addCanvsTo(view: self.videoView)
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
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        idContainerView.layer.cornerRadius = 10.0
        idContainerView.layer.masksToBounds = true
    }
    
}
