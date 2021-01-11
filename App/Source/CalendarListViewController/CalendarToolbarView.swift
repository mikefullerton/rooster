//
//  CalendarToolbarView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/5/21.
//

import Foundation
import UIKit

protocol CalendarToolbarViewDelegate : AnyObject {
    func calendarToolbarView(_ toolbarView: CalendarToolbarView, didChangeSelectedIndex index: Int)
}

class CalendarToolbarView : TopBar {
    
    weak var delegate: CalendarToolbarViewDelegate?

    override var preferredHeight:CGFloat {
        return 50.0
    }
    
    init() {
        super.init(frame: CGRect.zero)
        self.addToolbar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func segmentedControllerDidChange(_ sender: UISegmentedControl) {
        if let delegate = self.delegate {
            delegate.calendarToolbarView(self, didChangeSelectedIndex: sender.selectedSegmentIndex)
        }
    }
    
    lazy var toolbar: UISegmentedControl = {
        var view = UISegmentedControl(items: [ "Calendars", "Delegate Calendars" ])
        view.selectedSegmentIndex = 0
        view.addTarget(self, action: #selector(segmentedControllerDidChange(_:)), for: .valueChanged)
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
