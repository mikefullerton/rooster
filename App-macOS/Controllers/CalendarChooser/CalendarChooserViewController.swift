//
//  LeftSideViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/8/20.
//

import Foundation
import Cocoa

class CalendarChooserViewController : NSViewController, CalendarToolbarViewDelegate {
    let preferredWidth:CGFloat = 450

    private lazy var calendarsViewController = PersonalCalendarListViewController()
    private lazy var delegateCalendarsViewController = DelegateCalendarListViewController()
    private var activeViewController: NSViewController?
    lazy var topBar = CalendarToolbarView()

    override func loadView() {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor
        self.view = view

        self.addTopBar()
        self.topBar.delegate = self
        
        self.addChild(self.calendarsViewController)
        self.addChild(self.delegateCalendarsViewController)
        self.activateViewController(self.calendarsViewController)
    }

    private func activateViewController(_ viewController: CalendarItemTableViewController<CalenderListViewModel>) {
        
        if let activeViewController = self.activeViewController {
            activeViewController.view.removeFromSuperview()
        }
        
        viewController.scrollView.automaticallyAdjustsContentInsets = false
        viewController.scrollView.contentInsets = NSEdgeInsets(top: self.topBar.preferredHeight,
                                                               left: 0,
                                                               bottom: 0,
                                                               right: 0)

        self.setContentView(viewController.view)
        self.activeViewController = viewController
    }
        
    func calendarToolbarView(_ toolbarView: CalendarToolbarView, didChangeSelectedIndex index: Int) {
        if index == 0 {
            self.activateViewController(self.calendarsViewController)
        } else {
            self.activateViewController(self.delegateCalendarsViewController)
        }
    }
    
    private func addTopBar() {
        let view = self.topBar
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: view.preferredHeight),
            view.topAnchor.constraint(equalTo: self.view.topAnchor),
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }

    private func setContentView(_ view: NSView) {
        self.view.addSubview(view, positioned: .below, relativeTo: self.topBar)

        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.view.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
}




