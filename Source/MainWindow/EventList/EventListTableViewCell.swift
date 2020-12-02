//
//  EventListTableViewCell.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/22/20.
//

import Foundation
import UIKit

class EventListTableViewCell : UITableViewCell, TableViewRowCell {
    private var event: EventKitEvent?
    private var stackedView: VerticalStackView?
    private var dividerView: DividerView
    
    private static let horizontalInset: CGFloat = 20
    private static let labelHeight:CGFloat = 20
    private static let verticalPadding:CGFloat = 4

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.event = nil
        self.stackedView = nil
        self.dividerView = DividerView()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let views = [
            self.timeLabel,
            self.eventTitleLabel,
            self.calendarTitleLabel
          ]
        
        let stackView = VerticalStackView(frame: CGRect(x: 0, y: 0, width: 0, height: 0),
                                          views: views,
                                          padding:EventListTableViewCell.verticalPadding)
        self.contentView.addSubview(stackView)
        
        let size = stackView.sizeThatFits(CGSize(width:100, height:CGFloat.greatestFiniteMagnitude))
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.heightAnchor.constraint(equalToConstant: size.height),
            stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: EventListTableViewCell.horizontalInset),
            stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -EventListTableViewCell.horizontalInset),
            stackView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),

        ])
        
        self.stackedView = stackView
        
        self.addSubview(self.dividerView)
        self.dividerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.dividerView.heightAnchor.constraint(equalToConstant: 1),
            self.dividerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.dividerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.dividerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static var cellHeight: CGFloat {
        return (EventListTableViewCell.labelHeight + EventListTableViewCell.verticalPadding) * 3 + 40
    }
    
    override func prepareForReuse() {
        self.event = nil
        self.countDownLabel.stopTimer()
    }
    
    @objc func handleButtonClick(_ sender: UIButton) {
        self.event?.stopAlarm()
    }
    
    func shortDateString(_ date: Date) -> String {
        return DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
    }
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 100, height: EventListTableViewCell.labelHeight)
        self.contentView.addSubview(label)
        label.textColor = UIColor.secondaryLabel
        return label
    }()
    
    lazy var eventTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.label
        label.frame = CGRect(x: 0, y: 0, width: 100, height: EventListTableViewCell.labelHeight)
        return label
    }()
    
    lazy var calendarTitleLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 100, height: EventListTableViewCell.labelHeight)
        label.textColor = UIColor.secondaryLabel
        return label
    }()
    
    lazy var countDownLabel: TimeRemainingView = {
        let label = TimeRemainingView()
        label.textColor = UIColor.secondaryLabel
        label.textAlignment = .right
        
        self.contentView.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: 250),
            label.heightAnchor.constraint(equalToConstant: 20),
            label.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            label.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
        ])

        return label
    }()
    
    
    lazy var stopButton: UIButton = {
        let view = UIButton(type: .system)
        view.addTarget(self, action: #selector(handleButtonClick(_:)), for: .touchUpInside)
        view.setTitle("Mute", for: .normal)
        view.role = .destructive

        self.contentView.addSubview(view)

        view.frame = CGRect(x: 0, y: 0, width: 60, height: 20)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 60),
            view.heightAnchor.constraint(equalToConstant: 20),
            view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            view.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
        ])
        
        return view
    }()
    
    lazy var calendarColorBar: UIView = {
        let view = UIView()
        self.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 6),
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
        ])
        
        return view
    }()
    
    lazy var alarmIcon: UIImageView = {
        let image = UIImage(systemName: "alarm")
        
        let view = UIImageView(image:image)
        self.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 20),
            view.heightAnchor.constraint(equalToConstant: 20),
            view.bottomAnchor.constraint(equalTo: self.stopButton.topAnchor, constant: -8),
            view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
        ])
        
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.duration = 0.4
        pulseAnimation.fromValue = 0.5
        pulseAnimation.toValue = 1.0
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        view.layer.add(pulseAnimation, forKey: nil)
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.4
        pulse.fromValue = 1.0
        pulse.toValue = 1.12
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.initialVelocity = 0.5
        pulse.damping = 0.8
        view.layer.add(pulse, forKey: nil)
        
        return view
    }()
    
    
    func setEvent(_ event: EventKitEvent) {

        self.event = event
        
        if let calendarColor = event.calendar.color {
            self.calendarColorBar.isHidden = false
            self.calendarColorBar.backgroundColor = calendarColor
        } else {
            self.calendarColorBar.isHidden = true
        }
        
        let startTime = self.shortDateString(event.startDate)
        let endTime = self.shortDateString(event.endDate)
        
        self.timeLabel.text = "\(startTime) - \(endTime)"
        self.eventTitleLabel.text = event.title
        
        let now = Date()
        if now.isBeforeDate(event.startDate) {
            self.stopButton.isHidden = true
            self.countDownLabel.isHidden = false
            self.countDownLabel.startTimer(fireDate: event.startDate)
            self.countDownLabel.prefixString = "Alarm will fire in "
        }
        
        let calendar = event.calendar
      
        self.calendarTitleLabel.text = "Calendar: \(calendar.title) (\(calendar.sourceTitle)) "
        
        if event.isHappeningNow {
            self.stopButton.isHidden = false
            self.stopButton.isEnabled = event.alarmState == .firing
            self.countDownLabel.isHidden = true
            self.countDownLabel.stopTimer()
            self.alarmIcon.isHidden = false
            self.alarmIcon.tintColor = event.calendar.color!

            
//            self.backgroundColorTint.isHidden = false
//            self.backgroundColorTint.backgroundColor = UIColor.red
//            self.backgroundColorTint.alpha = 0.1
//            self.backgroundColorTint.isOpaque = false
//
//            self.layer.borderWidth = 1.0
//            if let calendarColor = event.calendar.color {
//                self.layer.borderColor = calendarColor.cgColor
//            } else {
//                self.layer.borderColor = UIColor.systemOrange.cgColor
//            }
//
//            self.layer.cornerRadius = 0.0
//            self.view.layer.border
        } else {

            self.alarmIcon.isHidden = true
//            self.backgroundColorTint.isHidden = true

            //            self.layer.borderWidth = 0.0
//            self.layer.borderColor = UIColor.clear.cgColor
//            self.layer.cornerRadius = 0.0
        }
    }
}
