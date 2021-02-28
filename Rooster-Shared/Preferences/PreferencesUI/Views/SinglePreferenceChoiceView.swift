//
//  SinglePreferenceView.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/2/21.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public class SinglePreferenceChoiceView : SDKView {
    
    let title: String
    
    public init(frame: CGRect,
         title: String) {
        
        self.title = title
        super.init(frame: frame)
        
        NotificationCenter.default.addObserver(self, selector: #selector(preferencesDidChange(_:)), name: PreferencesController.DidChangeEvent, object: nil)

        self.checkbox.title = title
        self.addSubview(self.checkbox)
        
        self.needsUpdateConstraints = true
        self.refresh()
    }
    
    public override func updateConstraints() {
        self.addViewsToLayout()
        super.updateConstraints()
    }

    func addViewsToLayout() {
        self.layout.setViews([ self.checkbox ])
    }
    
    @objc func preferencesDidChange(_ sender: Notification) {
        self.refresh()
    }

    public func refresh() {
        self.checkbox.intValue = self.value ? 1 : 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func checkboxChanged(_ sender: SDKButton) {
    }
    
    public lazy var checkbox : SDKButton = {
        let view = SDKButton(checkboxWithTitle: "", target: self, action: #selector(checkboxChanged(_:)))
        view.intValue = self.value ? 1 : 0
        return view
    }()
    
    public lazy var layout: VerticalViewLayout = {
        return VerticalViewLayout(hostView: self,
                                  insets: SDKEdgeInsets.zero,
                                  spacing: SDKOffset.zero)
        
    }()
    
    public var value: Bool {
        return false
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: SDKView.noIntrinsicMetric, height: self.layout.intrinsicContentSize.height)
    }
}
