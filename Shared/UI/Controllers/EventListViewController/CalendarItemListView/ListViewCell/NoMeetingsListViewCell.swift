//
//  NoMeetingsListViewCell.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/9/21.
//

import Foundation
import Cocoa

class NoMeetingsListViewCell : ListViewRowController<NoMeetingsModelObject> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.sdkLayer.cornerRadius = 6.0
        self.view.sdkLayer.borderWidth = 0.5
        self.view.sdkLayer.borderColor = SDKColor.separatorColor.cgColor
        self.view.sdkLayer.masksToBounds = true

        self.addHighlightBackgroundView()
        
        self.addNoMoreMeetingsView()
    }
    
    private lazy var noMoreMeetingsView: SDKView = {
        let view = SDKTextField()
        
        view.textColor = Theme(for: self.view).secondaryLabelColor
        view.font = SDKFont.systemFont(ofSize: SDKFont.systemFontSize)
        view.isEditable = false
        view.isBordered = false
        view.drawsBackground = false
        view.stringValue = "No more meetings today! 🎉"
        view.alignment = .center
        
        return view
    }()
    
    func addNoMoreMeetingsView() {
        let view = self.noMoreMeetingsView
        
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
    }

    override class var preferredHeight: CGFloat {
        return 40
    }

    override func viewWillAppear(withContent content: NoMeetingsModelObject) {
//        let _ = self.view
    }
}
