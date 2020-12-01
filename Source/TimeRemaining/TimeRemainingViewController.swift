//
//  TimeRemainingViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit

class TimeRemainingViewController : UIViewController {
    
    private weak var timer: Timer?
    
    lazy var timeRemainingLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        label.textColor = UIColor.systemOrange
        label.font = UIFont.systemFont(ofSize: 20.0)
        
        self.view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: 100),
            label.heightAnchor.constraint(equalToConstant: 40),
            label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.systemBackground
    }
    
    var viewHeight: CGFloat {
        return 100
    }

    private func startTimer() {
        self.stopTimer()
        
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
            self.timerDidFire()
        }
        self.timer = timer
        
//        print("started timer: \(timer) for time interval \(fireInterval)")
    }
    
    private func stopTimer() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    func printableTimeComponent(interval: Double) -> String {
        let intValue: Int = Int(interval)
        return intValue < 10 ? "0\(intValue)" : "\(intValue)"
    }
    
    func updateCountDown() {
        if let nextFireTime = DataModel.instance.nextEventStartTime {
            let fireTime = nextFireTime.timeIntervalSinceReferenceDate
            let now = Date().timeIntervalSinceReferenceDate

            let interval = fireTime - now
            let minutes = floor(interval / (60.0))
            let hours = floor(minutes / (60.0))

            let seconds = interval - (hours * 60 * 60) - (minutes * 60)
            
            var text = ""
            
            if hours > 0 {
                text += "\(self.printableTimeComponent(interval: hours)): "
            }
            
            if minutes > 0 {
                text += "\(self.printableTimeComponent(interval: minutes)): "
            }
            
            text += self.printableTimeComponent(interval: seconds)

            self.timeRemainingLabel.text = text
        } else {
            self.stopTimer()
            self.timeRemainingLabel.text = "Tomorrow"
        }
    }
    
    func timerDidFire() {
        self.updateCountDown()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopTimer()
    }
}

