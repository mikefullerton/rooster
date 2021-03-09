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
    
    private let updateCallback: (_ newValue: Bool) -> Void
    private let refreshCallback: () -> Bool
    
    public init(withTitle title: String,
                refresh refreshCallback: @escaping () -> Bool,
                update updateCallback: @escaping (_ newValue: Bool) -> Void) {
        
        self.refreshCallback = refreshCallback
        self.updateCallback = updateCallback
        
        super.init(frame: CGRect.zero)
        
        self.checkbox.title = title
        
        self.addSubview(self.checkbox)
        
        NotificationCenter.default.addObserver(self, selector: #selector(preferencesDidChange(_:)), name: PreferencesController.DidChangeEvent, object: nil)
    
        self.refresh()
    }
    
    public override func updateConstraints() {
        self.addViewsToLayout()
        super.updateConstraints()
    }

    func addViewsToLayout() {
        self.layout.setViews([ self.checkbox ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func checkboxChanged(_ sender: SDKSwitch) {
        self.updateCallback(sender.isOn)
    }
    
    public lazy var checkbox : SDKSwitch = {
        let view = SDKSwitch(title: "", target: self, action: #selector(checkboxChanged(_:)))
        return view
    }()
    
    public lazy var layout: VerticalViewLayout = {
        return VerticalViewLayout(hostView: self,
                                  insets: SDKEdgeInsets.zero,
                                  spacing: SDKOffset.zero)
        
    }()
    
    public var isOne: Bool {
        get {
            return self.checkbox.isOn
        }
        set(value) {
            self.checkbox.isOn = value
        }
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: SDKView.noIntrinsicMetric, height: self.layout.intrinsicContentSize.height)
    }
    
    @objc func preferencesDidChange(_ sender: Notification) {
        self.refresh()
    }
    
    open func refresh() {
        self.checkbox.isOn = self.refreshCallback()
    }
}
