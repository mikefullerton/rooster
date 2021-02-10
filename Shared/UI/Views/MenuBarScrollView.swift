//
//  MenuBarScrollView.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/10/21.
//

import Foundation
import Cocoa

protocol MenuBarScrollViewDelegate : AnyObject {
    func menuBarScrollViewWillAppear(_ scrollView: MenuBarScrollView)
    func menuBarScrollViewWillDisappear(_ scrollView: MenuBarScrollView)
    func menuBarScrollViewDidAppear(_ scrollView: MenuBarScrollView)
    func menuBarScrollViewDidDisappear(_ scrollView: MenuBarScrollView)
}

class MenuBarScrollView : NSScrollView {

    weak var menuBarDelegate: MenuBarScrollViewDelegate?

    override func viewWillMove(toWindow newWindow: NSWindow?) {
        super.viewWillMove(toWindow: newWindow)
        
        if newWindow != nil {
            self.menuBarDelegate?.menuBarScrollViewWillAppear(self)
            self.needsDisplay = true

        } else {
            self.menuBarDelegate?.menuBarScrollViewWillDisappear(self)
        }
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        if self.window != nil {
            self.menuBarDelegate?.menuBarScrollViewDidAppear(self)
            self.needsDisplay = true
        } else {
            self.menuBarDelegate?.menuBarScrollViewDidDisappear(self)
        }
    }
    
//    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
//        print("tracking: firstMouse: \(event)")
//
//        return true
//    }

    
    
}
