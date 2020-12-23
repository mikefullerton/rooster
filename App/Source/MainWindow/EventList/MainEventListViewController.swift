//
//  RightSideViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit

class MainEventListViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _ = self.timeRemainingViewController
        let _ = self.eventListViewController
    }
    
    lazy var timeRemainingViewController: TimeRemainingViewController = {

        let timeRemainingViewController = TimeRemainingViewController()
        let timeRemainingView = timeRemainingViewController.view!

        self.addChild(timeRemainingViewController)

        self.view.addSubview(timeRemainingView)

        timeRemainingView.translatesAutoresizingMaskIntoConstraints = false

        #if targetEnvironment(macCatalyst)
        let topBuffer:CGFloat = 10
        #else
        let topBuffer:CGFloat = 80
        #endif
        
        NSLayoutConstraint.activate([
            timeRemainingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            timeRemainingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            timeRemainingView.heightAnchor.constraint(equalToConstant: timeRemainingViewController.viewHeight),
            timeRemainingView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: topBuffer)
        ])
        
        return timeRemainingViewController
    }()
    
    lazy var eventListViewController: EventListViewController = {
        
        let eventListViewController = EventListViewController()
        
        let eventView = eventListViewController.view!

        self.addChild(eventListViewController)

        self.view.addSubview(eventView)

        eventView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            eventView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            eventView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            eventView.topAnchor.constraint(equalTo: self.timeRemainingViewController.view.bottomAnchor),
            eventView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
        
        return eventListViewController
    }()
    
}
