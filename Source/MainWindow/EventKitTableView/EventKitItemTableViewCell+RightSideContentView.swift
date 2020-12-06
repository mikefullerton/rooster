//
//  EventKitItemRightSideCellContentView.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/5/20.
//

import Foundation
import UIKit

extension EventKitItemTableViewCell {

    class AbstractRightSideContentView : UIView {
        
        init() {
            super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))

            self.addAlarmIcon()
            self.addStopButton()
            self.addCountDownLabel()
            self.addLocationView()
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
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
            
            self.addSubview(view)
            
            view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                view.heightAnchor.constraint(equalToConstant: view.frame.size.height),
                view.widthAnchor.constraint(equalToConstant: view.frame.size.width),
                view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                view.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
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
            
            self.addSubview(view)
            
            view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                view.heightAnchor.constraint(equalToConstant: view.frame.size.height),
                view.widthAnchor.constraint(equalToConstant: view.frame.size.width),
                view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                view.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
            ])
        }
        
        lazy var countDownLabel: TimeRemainingView = {
            let label = TimeRemainingView(frame:CGRect(x: 0, y: 0, width: 250, height: 26))
            label.textColor = UIColor.secondaryLabel
            label.textAlignment = .right
            label.prefixString = "Alarm will fire in "

            return label
        }()
        
        func addCountDownLabel() {
            let view = self.countDownLabel
            
            self.addSubview(view)
            
            view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                view.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
                view.heightAnchor.constraint(equalToConstant: view.frame.size.height),
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
            }
            view.frame = CGRect(x: 0, y: 0, width: 60, height: 20)
            view.contentHorizontalAlignment = .right
            view.setTitleColor(UIColor.systemBlue, for: UIControl.State.normal)
            view.setTitleColor(UIColor.systemGray, for: UIControl.State.highlighted)
            return view
        }()
        
        func addLocationView() {
            
            let view = self.locationButton
            
            self.addSubview(view)
            
            view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                view.heightAnchor.constraint(equalToConstant: view.frame.size.height),
                view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            ])
        }

        func setLocationURL(_ inUrl: URL?) {
            
            if let url = inUrl,
               let host = url.host {
                
                let normalUrlText = NSAttributedString(string: "\(host)",
                                                 attributes: [
                                                    NSAttributedString.Key.font : UIFont.systemFont(ofSize: UIFont.labelFontSize),
                                                    NSAttributedString.Key.foregroundColor : UIColor.secondaryLabel,
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
        
        func prepareForReuse() {
            self.countDownLabel.stopTimer()
            self.setLocationURL(nil)
        }

    }
}
