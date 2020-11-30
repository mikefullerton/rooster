//
//  EventListTableViewCell.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/22/20.
//

import Foundation
import UIKit

class EventListTableViewCell : UITableViewCell {
    
    private var event: EventKitEvent?
    
    override func prepareForReuse() {
        self.event = nil
    }
    
    @objc func handleButtonClick(_ sender: UIButton) {
        self.event?.stopAlarm()
    }
    
    func shortDateString(_ date: Date) -> String {
        return DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
    }
    
    lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleButtonClick(_:)), for: .touchUpInside)
//        button.set(title:"Title", for:.) = "Stop"
        button.setTitle("Stop", for: .normal)
        button.role = .destructive

        self.contentView.addSubview(button)

        button.frame = CGRect(x: 0, y: 0, width: 60, height: 20)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 60),
            button.heightAnchor.constraint(equalToConstant: 20),
            button.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            button.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
        ])
        
        return button
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
       
        self.contentView.addSubview(label)
        label.textColor = UIColor.label

        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, constant: -80),
            label.heightAnchor.constraint(equalToConstant: 20),
            label.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            label.topAnchor.constraint(equalTo: self.contentView.topAnchor),
        ])
        return label
    }()
    
    lazy var eventTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.label

        self.contentView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
                
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, constant: -80),
            label.heightAnchor.constraint(equalToConstant: 20),
            label.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            label.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
        ])
        return label
    }()
    
    
    
    func setEvent(_ event: EventKitEvent) {
        self.event = event
    
        self.button.isEnabled = event.isFiring
        
        let startTime = self.shortDateString(event.startDate)
        let endTime = self.shortDateString(event.endDate)
        
        self.timeLabel.text = "\(startTime) - \(endTime)"
        self.eventTitleLabel.text = event.title
        
//        if let text = self.event?.title {
//            self.textLabel?.text = text
//        }
    }
}
