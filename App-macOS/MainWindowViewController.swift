//
//  MainWindowViewController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/18/21.
//

import Foundation
import Cocoa

class MainViewViewController : NSViewController {
    
    lazy var timeRemainingViewController = TimeRemainingViewController()

    lazy var eventListViewController = EventListViewController()

    func addTimeRemainingView() {

        let timeRemainingViewController = self.timeRemainingViewController
        let timeRemainingView = timeRemainingViewController.view
        
        timeRemainingViewController.addBlurView()
        timeRemainingViewController.addLabel(labelVerticalOffset: -20)

        self.addChild(timeRemainingViewController)

        self.view.addSubview(timeRemainingView)

        timeRemainingView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            timeRemainingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            timeRemainingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            timeRemainingView.heightAnchor.constraint(equalToConstant: TimeRemainingViewController.preferredHeight),
            timeRemainingView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0)
        ])
    }
    
    override func loadView() {
        self.view = NSView(frame: CGRect(x: 0, y: 0, width: 500, height: 600))
        
        self.addEventListView()
        self.addTimeRemainingView()
    }
    
    func addEventListView() {
        
        let eventListViewController = self.eventListViewController

        self.addChild(eventListViewController)

        self.view.addSubview(eventListViewController.view)

        eventListViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            eventListViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            eventListViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            eventListViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            eventListViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
        
//        eventListViewController.view.contentInset = NSEdgeInsets(top: TimeRemainingViewController.preferredHeight,
//                                              left: 0,
//                                              bottom: 0,
//                                              right: 0)
//
//        eventListViewController.view.contentOffset = CGPoint(x: 0, y: -TimeRemainingViewController.preferredHeight)

    }
    

    //            self.showEventListViewController()
    //            self.reloader = DataModelReloader(for: self)

}
