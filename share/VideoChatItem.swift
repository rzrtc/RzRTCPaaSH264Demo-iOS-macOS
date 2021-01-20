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
    
    let videoPlayView: RZVideoPlayView = RZVideoPlayView()
    let videoDecoder: RZVideoDecoder = RZVideoDecoder()

    
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
        videoDecoder.delegate = self
        
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvasView)
        let left = NSLayoutConstraint.init(item: canvasView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0)
        let rigth = NSLayoutConstraint.init(item: canvasView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0)
        let top = NSLayoutConstraint.init(item: canvasView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0)
        let bottom = NSLayoutConstraint.init(item: canvasView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0)
        view.addConstraints([left, rigth, top, bottom])
        
    }
    
}

extension VideoChatItem:RZVideoDecoderDelegate {
    func videoDecoder(_ videoDecoder: RZVideoDecoder, receiveDecodedData data: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>>, yuvStride: UnsafeMutablePointer<Int32>, width: Int32, height: Int32, pix_format: RZYUVType) {
        
        
//        if (pix_format == RZYUVTypeI420) {
//
//            uint8_t *y =  data[0];
//            uint8_t *u =  data[1];
//            uint8_t *v =  data[2];
//            int stride_y = yuvStride[0];
//            int stride_u = yuvStride[1];
//            int stride_v = yuvStride[2];
//
//            [self.playView displayI420:y
//                                     u:u
//                                     v:v
//                              stride_y:stride_y
//                              stride_u:stride_u
//                              stride_v:stride_v
//                                 width:width
//                                height:height];
//
//        }
        
//        data[0]
        
        let y = UnsafeMutableRawPointer(data[0]).bindMemory(to: UInt64.self, capacity: MemoryLayout<UInt8>.stride)
//        let y = rawPointer.load(as: UInt8.self)   // OK

        let u = UnsafeMutableRawPointer(data[1]).bindMemory(to: UInt64.self, capacity: MemoryLayout<UInt8>.stride)
//        let u = rawPointer1.load(as: UInt8.self)   // OK

        let v = UnsafeMutableRawPointer(data[2]).bindMemory(to: UInt64.self, capacity: MemoryLayout<UInt8>.stride)
//        let v = rawPointer2.load(as: UInt8.self)   // OK
        
        let stride_y:Int32 = yuvStride[0]
        let stride_u:Int32 = yuvStride[1]
        let stride_v:Int32 = yuvStride[2]
        
        self.videoPlayView.displayI420(y, u: u, v: v, stride_y: stride_y, stride_u: stride_u, stride_v: stride_v, width: width, height: height)
    }
    
}


extension VideoChatItem: RZVideoSinkProtocol {
    func shouldInitialize() -> Bool {
        return true
    }
    
    func shouldStart() -> Bool {
        return true
    }
    
    func shouldStop() {
        
    }
    
    func shouldDispose() {
        
    }
    
    func bufferType() -> RZVideoBufferType {
        return .H264
    }
    
    func pixelFormat() -> RZVideoPixelFormat {
        return .I420
    }
    
    func renderRawData(_ rawData: UnsafeMutableRawPointer, size: CGSize, pixelFormat: RZVideoPixelFormat, timestamp: Int) {
        self.videoPlayView.displayI420(rawData, frameWidth: Int32(size.width), frameHeight: Int32(size.height))
    }
    
    func renderPacket(_ packet: UnsafeMutableRawPointer, length: Int, bufferType: RZVideoBufferType, timestamp: Int) {
        self.videoDecoder.decodeH264(packet, length: Int32(length), timestamp: Double(timestamp))
    }
    
}
