//
//  TimeRemainingViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import Cocoa

class TimeRemainingViewController : NSViewController, DataModelAware {
    
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
        view.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        
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
    
    func addBlurView() {
        let visualEffectView = NSVisualEffectView(frame: CGRect.zero)
        visualEffectView.material = .headerView
        
        if self.view.subviews.count > 0 {
            self.view.addSubview(visualEffectView, positioned: .below, relativeTo: self.view.subviews[0])
        } else {
            self.view.addSubview(visualEffectView)
        }

        visualEffectView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            visualEffectView.topAnchor.constraint(equalTo: self.view.topAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
    
    override func loadView() {
        self.view = NSView()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.clear.cgColor
        self.addBlurView()
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
        self.countdownTextField.stopTimer()
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

