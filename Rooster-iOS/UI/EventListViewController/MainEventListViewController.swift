//
//  RightSideViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit

class MainEventListViewController : UIViewController {
    
    lazy var timeRemainingViewController = TimeRemainingViewController()
    lazy var eventListViewController = EventListViewController()
    
    override func loadView() {
        self.view = ContentAwareView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addTimeRemainingView()
        self.addEventListView()
        
        self.view.bringSubviewToFront(self.timeRemainingViewController.view)
    }
    
    var topOfWindowVerticalPadding: CGFloat {
        #if targetEnvironment(macCatalyst)
        return 52
        #else
        return 80
        #endif
    }
    
    func addTimeRemainingView() {

        let timeRemainingViewController = self.timeRemainingViewController
        let timeRemainingView = timeRemainingViewController.view!
        
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
    
    func addEventListView() {
        
        let eventListViewController = self.eventListViewController
        
        let eventView = eventListViewController.view as! UITableView

        self.addChild(eventListViewController)

        self.view.addSubview(eventView)

        eventView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            eventView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            eventView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            eventView.topAnchor.constraint(equalTo: self.view.topAnchor),
            eventView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
        
        eventView.contentInset = UIEdgeInsets(top: TimeRemainingViewController.preferredHeight,
                                              left: 0,
                                              bottom: 0,
                                              right: 0)

        eventView.contentOffset = CGPoint(x: 0, y: -TimeRemainingViewController.preferredHeight)

    }
    
    override var preferredContentSize: CGSize {
        get {
            let timeRemainingSize = self.timeRemainingViewController.preferredContentSize
            let eventListSize = self.eventListViewController.preferredContentSize
            
            let size = CGSize(width: self.view.frame.size.width,
                              height: eventListSize.height + timeRemainingSize.height )
            
            return size
        }
        set(size) {
            
        }
    }
}
