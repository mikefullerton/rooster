//
//  MainWindowPanel.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 3/7/21.
//

import Cocoa
import RoosterCore

public class MainWindowPanel: NSViewController {

    public static let preferredWidth: CGFloat = 200.0
    
    class PanelView : NSView {
        override var intrinsicContentSize: CGSize {
            return CGSize(width: MainWindowPanel.preferredWidth, height: NSView.noIntrinsicMetric)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.preferredContentSize = self.view.intrinsicContentSize
    }
    
    public override func loadView() {
        self.view = PanelView()
    }
    
}
