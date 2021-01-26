//
//  TimeRemainingViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif


class TimeRemainingViewController : SDKViewController, DataModelAware {
    
    private weak var timer: Timer?

    private lazy var dividerView = DividerView()

    private var reloader: DataModelReloader? = nil
    
    static let preferredHeight: CGFloat = 60
    
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
    
    lazy var countdownTextField: CountdownTextField = {
        let view = CountdownTextField()
        view.prefixString = "Your next alarm will fire in "
        view.showSecondsWithMinutes = true
        view.outOfRangeString = "No more meetings today! 🎉"
        view.font = SDKFont.systemFont(ofSize: SDKFont.systemFontSize)
        
        return view
    }()
    
    func addCountdownTextField() {
        
        let view = self.countdownTextField
        
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20),
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])

    }
    
    override func loadView() {
        self.view = BlurView()
        self.addCountdownTextField()
        self.addDividerView()
    }

    func startTimer() {
        self.countdownTextField.startTimer(fireDate: AppDelegate.instance.dataModelController.dataModel.nextAlarmDate) { () -> Date? in
            return AppDelegate.instance.dataModelController.dataModel.nextAlarmDate
        }
    }

    override func viewWillAppear() {
        super.viewWillAppear()
    
        self.startTimer()
        self.reloader = DataModelReloader(for: self)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        self.countdownTextField.stopCountdown()
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

