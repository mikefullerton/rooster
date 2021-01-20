//
//  CalendarItemTableViewCell.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/5/20.
//

import Foundation
import Cocoa

class CalendarItemTableViewCell : NSCollectionViewItem {
    
    let contentInsets = NSEdgeInsets(top: 14, left: 10, bottom: 14, right: 10)
    
    public static let horizontalInset: CGFloat = 20
    public static let verticalInset: CGFloat = 10
    public static let labelHeight:CGFloat = 20
    public static let verticalPadding:CGFloat = 4

    var dividerView: DividerView
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        self.dividerView = DividerView()
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init() {
        self.init(nibName:nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = NSView()
        
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
    
    override func prepareForReuse() {
        self.countDownLabel.stopTimer()
        self.setLocationURL(nil)
    }

    lazy var calendarColorBar: NSView = {
        let view = NSView()
        self.view.addSubview(view)

        let width:CGFloat = 6.0
        let heightInset:CGFloat = 10.0
        let leftInset:CGFloat = 10.0
        
        view.wantsLayer = true
        view.layer?.cornerRadius = width / 2.0
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: width),
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.contentInsets.left),
            view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: heightInset),
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -heightInset),
        ])
        
        return view
    }()
    
    func addDividerView() {
        let dividerView = self.dividerView
        self.view.addSubview(dividerView)
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dividerView.heightAnchor.constraint(equalToConstant: 1),
            dividerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            dividerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
        
        self.dividerView = dividerView
    }
    
    func updateCalendarBar(withCalendar calendar: Calendar) {
        if let calendarColor = calendar.color {
            self.calendarColorBar.isHidden = false
            self.calendarColorBar.layer?.backgroundColor = calendarColor.cgColor
        } else {
            self.calendarColorBar.isHidden = true
        }
    }
    
    lazy var alarmIcon: NSImageView = {
        let image = NSImage(systemSymbolName: "alarm", accessibilityDescription: "alarm")
//        (systemName: "alarm")
        
        let view = NSImageView(image:image!)
        
        view.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        
//        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
//        pulseAnimation.duration = 0.4
//        pulseAnimation.fromValue = 0.5
//        pulseAnimation.toValue = 1.0
//        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//        pulseAnimation.autoreverses = true
//        pulseAnimation.repeatCount = .greatestFiniteMagnitude
//        view.layer.add(pulseAnimation, forKey: nil)
//        
//        let pulse = CASpringAnimation(keyPath: "transform.scale")
//        pulse.duration = 0.4
//        pulse.fromValue = 1.0
//        pulse.toValue = 1.12
//        pulse.autoreverses = true
//        pulse.repeatCount = .infinity
//        pulse.initialVelocity = 0.5
//        pulse.damping = 0.8
//        view.layer.add(pulse, forKey: nil)
        
        view.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        return view
    }()
    
    func addAlarmIcon() {
        
        let view = self.alarmIcon
        
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: view.frame.size.height),
            view.widthAnchor.constraint(equalToConstant: view.frame.size.width),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -self.contentInsets.right),
            view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.contentInsets.top),
        ])
    }
    
    @objc func handleMuteButtonClick(_ sender: NSButton) {
    }
    
    var muteButtonTitle : String {
        return ""
    }
    
    lazy var stopButton: NSButton = {
        let view = NSButton(frame: CGRect.zero)
        view.target = self
        view.action = #selector(handleMuteButtonClick(_:))

        view.title = self.muteButtonTitle
        
//        view.setTitle(self.muteButtonTitle, for: .normal)
//        view.role = .destructive
        view.frame = CGRect(x: 0, y: 0, width: 60, height: 20)
        return view
    }()
    
    func addStopButton() {
        let view = self.stopButton
        
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
//                view.heightAnchor.constraint(equalToConstant: view.frame.size.height),
//                view.widthAnchor.constraint(equalToConstant: view.frame.size.width),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -self.contentInsets.right),
            view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
    }
    
    lazy var countDownLabel: CountdownTextField = {
        let label = CountdownTextField()
        label.prefixString = "Alarm will fire in "
        label.font = NSFont.systemFont(ofSize: NSFont.labelFontSize)
        label.alignment = .right
        return label
    }()
    
    func addCountDownLabel() {
        let view = self.countDownLabel
        
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -self.contentInsets.right),
            view.lastBaselineAnchor.constraint(equalTo: self.eventTitleLabel.lastBaselineAnchor)
//            view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }

    @objc func handleLocationButtonClick(_ sender: NSButton) {
    }
    
    lazy var locationButton: NSButton = {
        let view = LinkButton()
        
        view.isTransparent = true
        view.setButtonType(.momentaryPushIn)
        view.isBordered = false
        view.target = self
        view.action = #selector(handleLocationButtonClick(_:))
        
        if let buttonCell = view.cell as? NSButtonCell {
            buttonCell.highlightsBy = .pushInCellMask
            buttonCell.backgroundColor = NSColor.clear
        }
//        view.bezelStyle = .shadowlessSquare
        
//        if let titleLabel = view.titleLabel {
//            titleLabel.text = ""
//            titleLabel.alignment = .right
//            titleLabel.textColor = NSColor.systemBlue
//            titleLabel.font = NSFont.systemFont(ofSize: NSFont.labelFontSize)
//
//        }
        
//        view.contentHorizontalAlignment = .right
//        view.setTitleColor(NSColor.systemBlue, for: NSControl.State.normal)
//        view.setTitleColor(NSColor.systemGray, for: NSControl.State.highlighted)
        return view
    }()
    
    func addLocationView() {
        
        let view = self.locationButton
        
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -self.contentInsets.right),
            view.firstBaselineAnchor.constraint(equalTo: self.calendarTitleLabel.firstBaselineAnchor)
        ])
    }

    func setLocationURL(_ inUrl: URL?) {
        
        if let url = inUrl,
           let host = url.host {
            
            let normalUrlText = NSAttributedString(string: "\(host)",
                                             attributes: [
                                                NSAttributedString.Key.font : NSFont.systemFont(ofSize: NSFont.labelFontSize),
                                                NSAttributedString.Key.foregroundColor : Theme(for: self.view).secondaryLabelColor,
                                                NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue])

            let selectedUrlText = NSAttributedString(string: "\(host)",
                                             attributes: [
                                                NSAttributedString.Key.font : NSFont.systemFont(ofSize: NSFont.labelFontSize),
                                                NSAttributedString.Key.foregroundColor : NSColor.systemBlue, // placeholderTextColor,
                                                NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue])

            self.locationButton.attributedTitle = normalUrlText
            self.locationButton.attributedAlternateTitle = selectedUrlText

//            self.locationButton.setAttributedTitle(normalUrlText, for: NSControl.State.normal)
//            self.locationButton.setAttributedTitle(selectedUrlText, for: NSControl.State.highlighted)
        } else {
            self.locationButton.title = ""
            
//            self.locationButton.setAttributedTitle(normalUrlText, for: NSControl.State.normal)
//            self.locationButton.titleLabel!.attributedText = NSAttributedString(string: "")
        }
    }
    
    lazy var timeLabel: NSTextField = {
        let label = NSTextField()
        label.textColor = Theme(for: self.view).secondaryLabelColor
        label.font = NSFont.systemFont(ofSize: NSFont.labelFontSize)
        label.isEditable = false
        label.isBordered = false
        label.drawsBackground = false

        return label
    }()
    
    func addTimeLabel() {
        let view = self.timeLabel
        
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.calendarColorBar.trailingAnchor, constant: self.contentInsets.left),
            view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.contentInsets.top),
        ])
        
//        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    lazy var eventTitleLabel: NSTextField = {
        let label = NSTextField()
        label.textColor = Theme(for: self.view).labelColor
        label.font = NSFont.systemFont(ofSize: NSFont.labelFontSize)
        label.isEditable = false
        label.isBordered = false
        label.drawsBackground = false

        return label
    }()
    
    func addEventTitleLabel() {
        let view = self.eventTitleLabel
        
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.calendarColorBar.trailingAnchor, constant: self.contentInsets.left),
            view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0),
        ])
    }
    
    lazy var calendarTitleLabel: NSTextField = {
        let label = NSTextField()
        label.font = NSFont.systemFont(ofSize: NSFont.labelFontSize)
        label.textColor = Theme(for: self.view).secondaryLabelColor
        label.isEditable = false
        label.isBordered = false
        label.drawsBackground = false

        return label
    }()
    
    func addCalendarTitleLabel() {
        let view = self.calendarTitleLabel
        
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.calendarColorBar.trailingAnchor, constant: self.contentInsets.left),
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -self.contentInsets.bottom),
        ])
    }
}
