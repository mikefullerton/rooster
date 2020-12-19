//
//  UIWindow+Utilities.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/16/20.
//

import Foundation
import UIKit

extension UIWindow {
    var nsWindow: AnyObject? {
        guard let nsWindows = NSClassFromString("NSApplication")?.value(forKeyPath: "sharedApplication.windows") as? [AnyObject] else { return nil }
        for nsWindow in nsWindows {
            let uiWindows = nsWindow.value(forKeyPath: "uiWindows") as? [UIWindow] ?? []
            if uiWindows.contains(self) {
                return nsWindow
            }
        }
        print("failed to get nsWindow")
        return nil
    }
    
    var nsFrame : CGRect? {
        get {
            if let nsWindow = self.nsWindow,
               let frame = nsWindow.value(forKey:"frame") as? CGRect {
             
                return frame;
            }
            return nil
        }
        
        set(newFrame) {
            if let nsWindow = self.nsWindow {
                nsWindow.setValue(newFrame, forKey:"frame")
            }
            
        }
            
    }
    
    func setFrameAndBecomeVisible(newFrame: CGRect, counter: Int = 0) {
        if let _ = self.nsWindow {
            self.nsFrame = newFrame
            self.makeKeyAndVisible()
            return
        }

        if counter < 5 {
            DispatchQueue.main.async {
                self.setFrameAndBecomeVisible(newFrame: newFrame, counter: counter + 1)
            }
        }
    }
}
