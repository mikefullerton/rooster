//
//  CalendarItemTableViewCell.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/5/20.
//

import Foundation
import UIKit

class CalendarItemTableViewCell : UITableViewCell {
    
    let contentInsets = UIEdgeInsets(top: 14, left: 10, bottom: 14, right: 10)
    
    public static let horizontalInset: CGFloat = 20
    public static let verticalInset: CGFloat = 10
    public static let labelHeight:CGFloat = 20
    public static let verticalPadding:CGFloat = 4

    var dividerView: DividerView
    
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        self.dividerView = DividerView()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // left
        self.addTimeLabel()
        self.addEventTitleLabel()
        self.addCalendarTitleLabel()

        // right
        self.addAlarmIcon()
        self.addStopButton()
        self.addCountDownLabel()
        self.addLocationView()

        self.addDividerView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        self.countDownLabel.stopTimer()
        self.setLocationURL(nil)
    }

    lazy var calendarColorBar: UIView = {
        let view = UIView()
        self.contentView.addSubview(view)

        let width:CGFloat = 6.0
        let heightInset:CGFloat = 10.0
        let leftInset:CGFloat = 10.0
        
        view.layer.cornerRadius = width / 2.0
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: width),
            view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: self.contentInsets.left),
            view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: heightInset),
            view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -heightInset),
        ])
        
        return view
    }()
    
    func addDividerView() {
        let dividerView = self.dividerView
        self.addSubview(dividerView)
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dividerView.heightAnchor.constraint(equalToConstant: 1),
            dividerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            dividerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
        self.dividerView = dividerView
    }
    
    func updateCalendarBar(withCalendar calendar: Calendar) {
        if let calendarColor = calendar.color {
            self.calendarColorBar.isHidden = false
            self.calendarColorBar.backgroundColor = calendarColor
        } else {
            self.calendarColorBar.isHidden = true
        }
    }
    
    lazy var alarmIcon: UIImageView = {
        let image = UIImage(systemName: "alarm")
        
        let view = UIImageView(image:image)
        
        view.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        
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
        
        view.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        return view
    }()
    
    func addAlarmIcon() {
        
        let view = self.alarmIcon
        
        self.contentView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: view.frame.size.height),
            view.widthAnchor.constraint(equalToConstant: view.frame.size.width),
            view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -self.contentInsets.right),
            view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: self.contentInsets.top),
        ])
    }
    
    @objc func handleMuteButtonClick(_ sender: UIButton) {
    }
    
    var muteButtonTitle : String {
        return ""
    }
    
    lazy var stopButton: UIButton = {
        let view = UIButton(type: .system)
        view.addTarget(self, action: #selector(handleMuteButtonClick(_:)), for: .touchUpInside)
        view.setTitle(self.muteButtonTitle, for: .normal)
        view.role = .destructive
        view.frame = CGRect(x: 0, y: 0, width: 60, height: 20)
        return view
    }()
    
    func addStopButton() {
        let view = self.stopButton
        
        self.contentView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
//                view.heightAnchor.constraint(equalToConstant: view.frame.size.height),
//                view.widthAnchor.constraint(equalToConstant: view.frame.size.width),
            view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -self.contentInsets.right),
            view.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
        ])
    }
    
    lazy var countDownLabel: TimeRemainingView = {
        let label = TimeRemainingView()
        label.addLabel(labelVerticalOffset: 0)
        label.prefixString = "Alarm will fire in "
        label.label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        label.label.textAlignment = .right
        return label
    }()
    
    func addCountDownLabel() {
        let view = self.countDownLabel
        
        self.contentView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -self.contentInsets.right),
            view.lastBaselineAnchor.constraint(equalTo: self.eventTitleLabel.lastBaselineAnchor)
//            view.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ])
    }

    @objc func handleLocationButtonClick(_ sender: UIButton) {
    }
    
    lazy var locationButton: UIButton = {
        let view = UIButton(type: .custom)
        view.addTarget(self, action: #selector(handleLocationButtonClick(_:)), for: .touchUpInside)
        if let titleLabel = view.titleLabel {
            titleLabel.text = ""
            titleLabel.textAlignment = .right
            titleLabel.textColor = UIColor.systemBlue
            titleLabel.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
            
        }
//            view.frame = CGRect(x: 0, y: 0, width: 60, height: 20)
        view.contentHorizontalAlignment = .right
        view.setTitleColor(UIColor.systemBlue, for: UIControl.State.normal)
        view.setTitleColor(UIColor.systemGray, for: UIControl.State.highlighted)
        return view
    }()
    
    func addLocationView() {
        
        let view = self.locationButton
        
        self.contentView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
//                view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -self.contentInsets.right),
//                view.heightAnchor.constraint(equalToConstant: view.frame.size.height),
            view.firstBaselineAnchor.constraint(equalTo: self.calendarTitleLabel.firstBaselineAnchor)
//            view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -self.contentInsets.bottom),
        ])
    }

    func setLocationURL(_ inUrl: URL?) {
        
        if let url = inUrl,
           let host = url.host {
            
            let normalUrlText = NSAttributedString(string: "\(host)",
                                             attributes: [
                                                NSAttributedString.Key.font : UIFont.systemFont(ofSize: UIFont.labelFontSize),
                                                NSAttributedString.Key.foregroundColor : Theme(for: self).secondaryLabelColor,
                                                NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue])

            let selectedUrlText = NSAttributedString(string: "\(host)",
                                             attributes: [
                                                NSAttributedString.Key.font : UIFont.systemFont(ofSize: UIFont.labelFontSize),
                                                NSAttributedString.Key.foregroundColor : UIColor.placeholderText,
                                                NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue])

            self.locationButton.setAttributedTitle(normalUrlText, for: UIControl.State.normal)
            self.locationButton.setAttributedTitle(selectedUrlText, for: UIControl.State.highlighted)
        } else {
            self.locationButton.titleLabel!.attributedText = NSAttributedString(string: "")
        }
    }
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = Theme(for: self).secondaryLabelColor
        label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        return label
    }()
    
    func addTimeLabel() {
        let view = self.timeLabel
        
        self.contentView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.calendarColorBar.trailingAnchor, constant: self.contentInsets.left),
            view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: self.contentInsets.top),
        ])
    }
    
    lazy var eventTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Theme(for: self).labelColor
        label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        return label
    }()
    
    func addEventTitleLabel() {
        let view = self.eventTitleLabel
        
        self.contentView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.calendarColorBar.trailingAnchor, constant: self.contentInsets.left),
            view.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 0),
        ])
    }
    
    lazy var calendarTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        label.textColor = Theme(for: self).secondaryLabelColor
        return label
    }()
    
    func addCalendarTitleLabel() {
        let view = self.calendarTitleLabel
        
        self.contentView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.calendarColorBar.trailingAnchor, constant: self.contentInsets.left),
            view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -self.contentInsets.bottom),
        ])
    }
}
