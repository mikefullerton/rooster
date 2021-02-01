//
//  File.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/31/21.
//

import Foundation
import AppKit

protocol StopAlarmMenuBarButtonDelegate: AnyObject {
    func stopAlarmMenuBarButtonButtonWasClicked(_ item: StopAlarmMenuBarButton)
}

class StopAlarmMenuBarButton: MenuBarItem, AppControllerAware  {
    
    weak var delegate: StopAlarmMenuBarButtonDelegate?
    private var animation: SwayAnimation?

    init(withDelegate delegate: StopAlarmMenuBarButtonDelegate?) {
        super.init()
        self.delegate = delegate
        self.buttonImage = self.alarmImage
    }

    var alarmImage : NSImage? {
        if let image = NSImage(systemSymbolName: "bell.fill", accessibilityDescription:"stop alarm in menubar") {
            image.size = CGSize(width: 26, height: 26)
            return image
        }
        
        return nil
    }

    @objc override func buttonClicked(_ sender: AnyObject?) {
        if let delegate = self.delegate {
            delegate.stopAlarmMenuBarButtonButtonWasClicked(self)
        }
    }

    func startAnimating() {
        
        if  let button = self.button,
            let layer = button.layer {
            
            button.wantsLayer = true
                
            layer.contentsGravity = .center
            layer.contents = self.alarmImage
            layer.contentsCenter = CGRect(x: 0.5, y: 0.5, width: 0.5, height: 0.5)
        }
        
        if self.animation == nil {
            self.animation = SwayAnimation(withView: self.button!)
        }
        
        self.animation?.startAnimating()
    }

    func stopAnimating() {
        if let animation = self.animation {
            animation.stopAnimating()
        }
    }
    
    override  func visibilityDidChange(toVisible visible: Bool) {
        if visible {
            self.startAnimating()
        } else {
            self.stopAnimating()
        }
    }

}
