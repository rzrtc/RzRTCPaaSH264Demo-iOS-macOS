//
//  DeviceListViewController.swift
//  Popover-Test
//
//  Created by yxibng on 2021/1/7.
//

import Cocoa
import RZPaas_macOS

class DeviceListViewController: NSViewController {

    @IBOutlet weak var camButton: NSPopUpButton!
    @IBOutlet weak var micButton: NSPopUpButton!
    @IBOutlet weak var speakerButton: NSPopUpButton!
    
    let  cams = EngineManager.sharedEngineManager.allCameras()
    let  mics = EngineManager.sharedEngineManager.allMicrophone()
    let  speakers = EngineManager.sharedEngineManager.allSpeakers()
    
    
    let currentCam = EngineManager.sharedEngineManager.currentDevice(type: .videoCapture)
    let currentMic = EngineManager.sharedEngineManager.currentDevice(type: .audioRecording)
    let currentSpeker = EngineManager.sharedEngineManager.currentDevice(type: .audioPlayout)
    

    deinit {
        print(#function)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.camButton.removeAllItems()
        for cam in cams {
            
            let item = NSMenuItem.init(title: cam.deviceName ?? "", action: #selector(onClickChooseCam(_:)), keyEquivalent: "")
            item.target = self
            camButton.menu?.addItem(item)
    
            if cam.deviceId == self.currentCam?.deviceId {
                camButton.select(item)
            }
        }
        
        
        self.micButton.removeAllItems()
        for mic in mics {
            
            let item = NSMenuItem.init(title: mic.deviceName ?? "", action: #selector(onClickChooseMic(_:)), keyEquivalent: "")
            item.target = self
            micButton.menu?.addItem(item)
    
            if mic.deviceId == self.currentMic?.deviceId {
                micButton.select(item)
            }
        }
        
        
        
        self.speakerButton.removeAllItems()
        for speaker in speakers {
            
            let item = NSMenuItem.init(title: speaker.deviceName ?? "", action: #selector(onClickChooseSpeaker(_:)), keyEquivalent: "")
            item.target = self
            speakerButton.menu?.addItem(item)
    
            if speaker.deviceId == self.currentSpeker?.deviceId {
                speakerButton.select(item)
            }
        }
    }
    
    
    @IBAction func onClickChooseCam(_ sender: Any) {
        print(#function)
        
        let index = self.camButton.indexOfSelectedItem
        guard index >= 0 && index < self.cams.count else {
            return
        }
        let info = self.cams[index]
        if let id = info.deviceId {
            EngineManager.sharedEngineManager.changeDevice(id: id, type: .videoCapture)
        }
    }
    
    @IBAction func onClickChooseMic(_ sender: Any) {
        print(#function)
        
        let index = self.micButton.indexOfSelectedItem
        guard index >= 0 && index < self.mics.count else {
            return
        }
        let info = self.mics[index]
        if let id = info.deviceId {
            EngineManager.sharedEngineManager.changeDevice(id: id, type: .audioRecording)
        }
    }
    
    @IBAction func onClickChooseSpeaker(_ sender: Any) {
        print(#function)
        
        let index = self.speakerButton.indexOfSelectedItem
        guard index >= 0 && index < self.speakers.count else {
            return
        }
        let info = self.speakers[index]
        if let id = info.deviceId {
            EngineManager.sharedEngineManager.changeDevice(id: id, type: .audioPlayout)
        }
    }
    
}
