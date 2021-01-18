//
//  RZAlertView.swift
//  rzpaas_sdk_demo_macos
//
//  Created by ding yusong on 2021/1/8.
//

import Cocoa

class RZAlertView: NSView {

    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var messageLabel: NSTextField!
    @IBOutlet weak var checkBtn: NSButton!
    @IBOutlet weak var closeBtn: NSButton!

    var btnClick:(()->())?
    var removeClick:(()->())?

    func btnClickDefault() {
        
    }
    
    @IBAction func onBtnClick(_ sender: Any) {
        (self.btnClick ?? btnClickDefault)()
    }
    @IBAction func onCloseClick(_ sender: Any) {
        (self.removeClick ?? btnClickDefault)()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

    }
    

    internal override func awakeFromNib() {
       super.awakeFromNib()
        self.wantsLayer = true
        self.layer?.backgroundColor = CGColor.white
        
        self.checkBtn.wantsLayer = true
        self.checkBtn.layer?.backgroundColor =  NSColor.init(red: 56.0/255.0, green: 69.0/255.0, blue: 63.0/255.0, alpha: 0.4).cgColor
    }
    
    public static func instantiateView<View: NSView>(for type: View.Type = View.self) -> View {
        let bundle = Bundle(for: type)
        let nibName = String(describing: type)

        guard bundle.path(forResource: nibName, ofType: "nib") != nil else {
            return View(frame: .zero)
        }

        var topLevelArray: NSArray?
        bundle.loadNibNamed(NSNib.Name(nibName), owner: nil, topLevelObjects: &topLevelArray)
        guard let results = topLevelArray as? [Any],
            let foundedView = results.last(where: {$0 is Self}),
            let view = foundedView as? View else {
                fatalError("NIB with name \"\(nibName)\" does not exist.")
        }
        return view
    }
}
