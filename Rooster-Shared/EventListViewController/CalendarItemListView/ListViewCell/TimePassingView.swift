//
//  TimePassView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/25/21.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class TimePassingView: SDKView {
    
    private(set) var startDate: Date?
    private(set) var endDate: Date?
    
    private let timer = SimpleTimer(withName: "TimePassingViewTimer")
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.addIndicatorView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
        self.needsLayout = true
        self.startTimer()
    }
    
    lazy var indicatorView = TimePassingIndicatorView()
    
    func addIndicatorView() {
        self.addSubview(self.indicatorView)
        
        self.needsLayout = true
    }
    
    override func layout() {
        super.layout()
        
        self.updateIndicator()
    }
    
    private func updateIndicator() {
        
        let now = Date()
        
        if let startDate = self.startDate,
           let endDate = self.endDate,
            now.isEqualToOrAfterDate(startDate) &&
            now.isEqualToOrBeforeDate(endDate) {
            
            let totalMinutes = endDate.timeIntervalSince(startDate) / 60
            let remainingMinutes = endDate.timeIntervalSince(now) / 60
            
            let height = TimeInterval(self.bounds.size.height)
            
            let pointsPerMinute = height / totalMinutes
            
            let remainingHeight = CGFloat(remainingMinutes * pointsPerMinute)
            
            let indicatorFrame = CGRect(x: 0,
                                        y: remainingHeight - (self.indicatorView.height / 2),
                                        width: self.bounds.size.width,
                                        height: self.indicatorView.height)
            
            self.indicatorView.frame = indicatorFrame
            self.indicatorView.isHidden = false
        } else {
            self.indicatorView.isHidden = true
        }
    }
    
    private func startTimer() {
        self.needsLayout = true
        
        let date = Date().addingTimeInterval(60).dateWithoutSeconds
        
        self.timer.start(withDate: date,
                         interval: 60,
                         fireCount: SimpleTimer.RepeatEndlessly) { [weak self] SimpleTimer in
            self?.needsLayout = true
        }
    }
    
    func stopTimer() {
        self.startDate = nil
        self.endDate = nil
        self.needsLayout = true
        self.timer.stop()
    }
    
    override func viewWillMove(toWindow window: NSWindow?) {
        super.viewWillMove(toWindow: window)

        if window == nil {
            self.stopTimer()
        }
    }
}

class TimePassingIndicatorView: SDKView {
    
    let height: CGFloat = 8
    
    let indicatorAlpha: CGFloat = 0.3
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        
        self.sdkBackgroundColor = SDKColor.clear
        
        self.addBallView()
        self.addLineView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var lineView: SDKView = {
        let view = SDKView()
        view.sdkBackgroundColor = SDKColor.systemRed
        view.alphaValue = self.indicatorAlpha
        return view
    } ()
    
    func addLineView() {
        let view = self.lineView

        self.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.heightAnchor.constraint(equalToConstant: 1.0),
            view.centerYAnchor.constraint(equalTo: self.ballView.centerYAnchor)
        ])
    }
    
    lazy var ballView: SDKView = {
        let view = SDKView()
        view.sdkBackgroundColor = SDKColor.systemRed
        view.sdkLayer.cornerRadius = self.height / 2
//        view.sdkLayer.borderWidth = 1.0
//        view.sdkLayer.borderColor = SDKColor.black.cgColor
        view.sdkLayer.masksToBounds = true
//        view.alphaValue = self.indicatorAlpha
        return view
    }()
    
    func addBallView() {
        let view = self.ballView
        
        self.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            view.heightAnchor.constraint(equalToConstant: self.height),
            view.widthAnchor.constraint(equalToConstant: self.height),
            view.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}
