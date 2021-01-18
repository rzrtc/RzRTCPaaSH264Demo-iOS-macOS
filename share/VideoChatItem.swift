//
//  VideoChatItem.swift
//  rzpaas_sdk_demo_macos
//
//  Created by yxibng on 2021/1/6.
//

#if os(iOS)
import UIKit
import RZPaas_iOS

typealias VIEW_CLASS = UIView
#endif

#if os(OSX)
import Cocoa
import RZPaas_macOS

typealias VIEW_CLASS = NSView
#endif



class VideoChatItem: NSObject {

    class StreamState {
        var online = false
        var remoteNoSend = true
        var noReceive = false
    }
    
    class VideoStreamState : StreamState{
        var isHD = true
    }

    var uid: String = ""
    var isLocal: Bool = false
    var isFront:Bool! = true
    
    
    let audioState = StreamState()
    let videoState = VideoStreamState()
    
    //video canvas
    let canvas: RZRtcVideoCanvas = {
        let canvas = RZRtcVideoCanvas.init()
        canvas.view = VIEW_CLASS.init()
        canvas.mirrorMode = .auto
        canvas.renderMode = .fit
        return canvas
    }()
    
    
    func addCanvsTo(view: VIEW_CLASS) {
        self.canvas.view?.removeFromSuperview()
        
        guard let canvasView = self.canvas.view else  {
            return
        }
        
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvasView)
        let left = NSLayoutConstraint.init(item: canvasView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0)
        let rigth = NSLayoutConstraint.init(item: canvasView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0)
        let top = NSLayoutConstraint.init(item: canvasView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0)
        let bottom = NSLayoutConstraint.init(item: canvasView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0)
        view.addConstraints([left, rigth, top, bottom])
        
    }
    
}
