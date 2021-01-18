//
//  RZAlertHelper.swift
//  rzpaas_sdk_demo_ios
//
//  Created by ding yusong on 2021/1/8.
//

import UIKit
import SnapKit

class RZAlertHelper: NSObject {
    
    
    static let shared = RZAlertHelper.init()
    
    
    func presentAlert(title:String, message:String, btnTitle:String, hiddenClose:Bool ,callBack:@escaping ()->Void) {
        
        let backgroundView = UIView.init()
        backgroundView.backgroundColor = UIColor.init(red: 56.0/255.0, green: 69.0/255.0, blue: 63.0/255.0, alpha: 0.4)
            
        guard let appWindow = UIApplication.shared.delegate?.window else {
            return
        }
        
        guard let window = appWindow else {
            return
        }

        window.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(window)
        }

        let alert = Bundle.main.loadNibNamed("RZAlertView", owner: nil, options: nil)?[0] as! RZAlertView

        alert.titleLabel.text = title
        alert.messageLabel.text = message
        
        alert.layer.cornerRadius = 6
        alert.layer.masksToBounds = true
        
        alert.checkBtn.layer.cornerRadius = 6
        alert.checkBtn.layer.masksToBounds = true
        
        alert.checkBtn.setTitle(btnTitle, for: UIControl.State.normal)
//        alert.btnClick = {[weak self] in
//            callBack()
//            backgroundView.removeFromSuperview()
//        }
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
