//
//  VideoChatLocalCell.swift
//  rzpaas_sdk_demo_macos
//
//  Created by yxibng on 2021/1/6.
//

import Cocoa

class VideoChatLocalCell: NSCollectionViewItem {

    @IBOutlet weak var uidLabel: NSTextField!
    @IBOutlet weak var videoView: NSView! {
        didSet {
            videoView.wantsLayer = true
            videoView.layer?.backgroundColor = NSColor.init(hex: "929baa")?.cgColor
        }
    }
    
    weak var item: VideoChatItem?
    func configWith(item: VideoChatItem) {
        self.item = item
//        item.addCanvsTo(view: self.videoView)
        self.uidLabel.stringValue = "\(item.uid) (我)"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        let subViews = videoView.subviews
        for view in subViews {
            view.removeFromSuperview()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
