//
//  RZAlertHelper.swift
//  rzpaas_sdk_demo_macos
//
//  Created by ding yusong on 2021/1/8.
//

import Cocoa
import SnapKit

class RZAlertHelper: NSObject {
    static let shared = RZAlertHelper.init()
    
    func presentAlert(title:String, message:String, btnTitle:String, hiddenClose:Bool, callBack:@escaping ()->Void) {
        
        let backgroundView = RZMView.init()
        backgroundView.isMaskView = true
        backgroundView.layer?.backgroundColor = NSColor.init(red: 56.0/255.0, green: 69.0/255.0, blue: 63.0/255.0, alpha: 0.4).cgColor
                        
        guard let window = NSApplication.shared.windows[0].contentView else {
            return
        }
        
        window.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(window)
        }

        let alert = RZAlertView.instantiateView(for: RZAlertView.self)
        
        alert.titleLabel.stringValue = title
        alert.messageLabel.stringValue = message
                
        alert.layer?.cornerRadius = 6
        alert.layer?.masksToBounds = true
        alert.layer?.backgroundColor = CGColor.init(red: 1, green: 1, blue: 1, alpha: 1)
        
        alert.checkBtn.wantsLayer = true
        
        alert.checkBtn.bezelStyle = .texturedSquare
        alert.checkBtn.isBordered = false //Important

        
        alert.checkBtn.layer?.backgroundColor = NSColor.init(hex: "1e6ceb")?.cgColor
        alert.checkBtn.layer?.cornerRadius = 6
        alert.checkBtn.layer?.masksToBounds = true
        
        let pstyle = NSMutableParagraphStyle()
        pstyle.alignment = .center

        alert.checkBtn.attributedTitle = NSAttributedString(string: btnTitle, attributes: [ NSAttributedString.Key.foregroundColor : NSColor.white, NSAttributedString.Key.paragraphStyle : pstyle ])
                
        alert.btnClick = {
            callBack()
            backgroundView.removeFromSuperview()
        }
        alert.removeClick = {
            backgroundView.removeFromSuperview()
        }
        
        if hiddenClose {
            alert.closeBtn.isHidden = hiddenClose
        }

        backgroundView.addSubview(alert)
        alert.snp.makeConstraints { (make) in
            make.width.equalTo(240)
            make.height.equalTo(280)
            make.center.equalTo(backgroundView)
        }
    }

}
