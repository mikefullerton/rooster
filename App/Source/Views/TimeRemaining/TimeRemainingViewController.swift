//
//  TimeRemainingViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit

class TimeRemainingViewController : UIViewController, DataModelAware {
    
    private weak var timer: Timer?

    private lazy var dividerView = DividerView()

    private var reloader: DataModelReloader? = nil
    
    static let preferredHeight: CGFloat = 100
    
    func addDividerView() {
        let dividerView = self.dividerView
        self.view.addSubview(dividerView)
        
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dividerView.heightAnchor.constraint(equalToConstant: 1),
            dividerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            dividerView.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -1),
        ])
    }
    
    
    override func loadView() {
        self.view = TimeRemainingView()
    }

    var timeRemainingLabel: TimeRemainingView {
        return self.view as! TimeRemainingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Theme(for: self.view).timeRemainingBackgroundColor
        
        self.addDividerView()
    
        self.timeRemainingLabel.prefixString = "Your next alarm will fire in "
        self.timeRemainingLabel.showSecondsWithMinutes = true
        self.timeRemainingLabel.outOfRangeString = "No more meetings today! 🎉"
    }
    
    func startTimer() {
        self.timeRemainingLabel.startTimer(fireDate: DataModelController.instance.dataModel.nextAlarmDate) { () -> Date? in
            return DataModelController.instance.dataModel.nextAlarmDate
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
    
    func dataModelDidReload(_ dataModel: DataModel) {
        self.startTimer()
    }
    
    override var preferredContentSize: CGSize {
        get {
            return CGSize(width: self.view.frame.size.width, height: TimeRemainingViewController.preferredHeight)
        }
        set(size) {
            
        }
    }
}

