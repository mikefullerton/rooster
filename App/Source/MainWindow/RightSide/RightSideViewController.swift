//
//  RightSideViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit

class RightSideViewController : UIViewController {
    
    let eventListViewController: EventListViewController = EventListViewController()
    let timeRemainingViewController: TimeRemainingViewController = TimeRemainingViewController()

    override func viewDidLoad() {
        
        self.addTimeRemaining()
        
        self.addEventList()
    }
    
    func addTimeRemaining() {

        guard let timeRemainingView = self.timeRemainingViewController.view else {
            return
        }

        self.addChild(self.timeRemainingViewController)

        self.view.addSubview(timeRemainingView)

        timeRemainingView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            timeRemainingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            timeRemainingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            timeRemainingView.heightAnchor.constraint(equalToConstant: self.timeRemainingViewController.viewHeight),
            timeRemainingView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10)
        ])
    }
    
    func addEventList() {
        guard let eventView = self.eventListViewController.view else {
            return
        }

        self.addChild(self.eventListViewController)

        self.view.addSubview(eventView)

        eventView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            eventView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            eventView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            eventView.topAnchor.constraint(equalTo: self.timeRemainingViewController.view.bottomAnchor),
            eventView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
    }
    
}
