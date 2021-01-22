//
//  CalendarToolbarView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/5/21.
//

import Foundation
import Cocoa

protocol CalendarToolbarViewDelegate : AnyObject {
    func calendarToolbarView(_ toolbarView: CalendarToolbarView, didChangeSelectedIndex index: Int)
}

class CalendarToolbarView : TopBar {
    
    weak var delegate: CalendarToolbarViewDelegate?

    override var preferredHeight:CGFloat {
        return 60.0
    }
    
    init() {
        super.init(frame: CGRect.zero)
        self.addToolbar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func segmentedControllerDidChange(_ sender: NSSegmentedControl) {
        if let delegate = self.delegate {
            delegate.calendarToolbarView(self, didChangeSelectedIndex: sender.selectedSegment)
        }
    }
    
    lazy var toolbar: NSSegmentedControl = {
        var view = NSSegmentedControl()
        view.segmentCount = 2
        view.setLabel("Calendars", forSegment: 0)
        view.setLabel("Delegate Calendars", forSegment: 1)
        view.selectedSegment = 0
        view.target = self
        view.action = #selector(segmentedControllerDidChange(_:))
        return view
    }()

    private func addToolbar() {

        let toolbar = self.toolbar

        self.addSubview(toolbar)

        toolbar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            toolbar.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            toolbar.centerXAnchor.constraint(equalTo: self.centerXAnchor)
            
//            toolbar.leadingAnchor.constraint(equalTo: self.leadingAnchor),
//            toolbar.trailingAnchor.constraint(equalTo: self.trailingAnchor),
//            toolbar.topAnchor.constraint(equalTo: self.topAnchor),
//            toolbar.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

//        self.invalidateIntrinsicContentSize()
    }
    
    
    
}
