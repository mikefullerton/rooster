//
//  File.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/31/21.
//

import Foundation
import AppKit

class StopAlarmMenuBarButton: MenuBarItem  {
    
    private var animation: SwayAnimation?

    override init() {
        super.init()
        self.buttonImage = self.alarmImage

        if  let button = self.button {
            
            button.wantsLayer = true
            button.layerContentsRedrawPolicy = .onSetNeedsDisplay
            button.canDrawSubviewsIntoLayer = true
            
            if let layer = button.layer {
                layer.contentsGravity = .center
                layer.contents = self.alarmImage
                    
                self.animation = SwayAnimation(withView: button)
            }
        }
    }

    var alarmImage : NSImage? {
        if let image = NSImage(systemSymbolName: "bell.fill", accessibilityDescription:"stop alarm in menubar") {
            image.size = CGSize(width: 26, height: 26)
            return image
        }
        
        return nil
    }

    @objc override func buttonClicked(_ sender: AnyObject?) {
        NSApp.activate(ignoringOtherApps: true)
        self.alarmNotificationController.handleUserClickedStopAll()
    }

    func startAnimating() {
        self.animation?.startAnimating()
    }

    func stopAnimating() {
        self.animation?.stopAnimating()
    }
    
    override  func visibilityDidChange(toVisible visible: Bool) {
        if visible {
            self.startAnimating()
        } else {
            self.stopAnimating()
        }
    }
    
    func updateVisibility() {
        self.isVisible = self.prefs.options.contains(.showStopAlarmIcon) && self.alarmNotificationController.alarmsAreFiring
    }
    
    override func dataModelDidReload(_ dataModel: DataModel) {
        self.updateVisibility()
    }
    
    @objc override func preferencesDidChange(_ sender: Notification) {
        self.updateVisibility()
    }
}
