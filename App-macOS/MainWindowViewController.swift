//
//  MainWindowViewController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/18/21.
//

import Foundation
import Cocoa

class MainViewViewController : NSViewController {
    
    lazy var timeRemainingViewController = TimeRemainingViewController(nibName: nil, bundle: nil)

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
        
        self.addTimeRemainingView()
    }
    

    //            self.showEventListViewController()
    //            self.reloader = DataModelReloader(for: self)

}
