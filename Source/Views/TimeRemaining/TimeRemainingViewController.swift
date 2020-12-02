//
//  TimeRemainingViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit

class TimeRemainingViewController : UIViewController, Reloadable {
    
    private weak var timer: Timer?

    private var reloader: DataModelReloader? = nil
    
    lazy var timeRemainingLabel: TimeRemainingView = {
        let label = TimeRemainingView()
        label.textColor = UIColor.secondaryLabel
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.textAlignment = .center
        
        self.view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
        ])
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.systemBackground
        
        self.timeRemainingLabel.prefixString = "Your next alarm will fire in "
        self.timeRemainingLabel.showSecondsWithMinutes = true
        self.timeRemainingLabel.outOfRangeString = "No more meetings today! 🎉"
    }
    
    var viewHeight: CGFloat {
        return 80
    }
    
    func startTimer() {
        self.timeRemainingLabel.startTimer(fireDate: EventKitDataModelController.instance.dataModel.nextEventStartTime) { () -> Date? in
            return EventKitDataModelController.instance.dataModel.nextEventStartTime
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        self.startTimer()
        self.reloader = DataModelReloader(for: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.timeRemainingLabel.stopTimer()
        self.reloader = nil
    }
    
    func reloadData() {
        self.startTimer()
    }
}

