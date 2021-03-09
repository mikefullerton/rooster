//
//  CountDownCell.swift
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

class CountDownHeaderView : BlurView, ListViewAdornmentView, DataModelAware, CountDownTextFieldDelegate {
    
    private var reloader: DataModelReloader?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addTitleView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func preferredSize(forContent content: Any?) -> CGSize {
        return CGSize(width: -1, height: 40)
    }
    
    lazy var titleView: CountDownTextField = {
        let titleView = CountDownTextField()
        titleView.isEditable = false
        titleView.textColor = Theme(for: self).secondaryLabelColor
        titleView.alignment = .center
        titleView.font = SDKFont.boldSystemFont(ofSize: SDKFont.smallSystemFontSize)
        titleView.drawsBackground = false
        titleView.isBordered = false
        titleView.prefixString = "Your next alarm will fire in "
        titleView.showSecondsWithMinutes = 2.0
        
        return titleView
    }()

    func addTitleView() {
        let titleView = self.titleView
       
        self.addSubview(titleView)
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    func viewWillAppear(withContent content: ListViewSectionAdornmentProtocol) {
        self.reloader = DataModelReloader(for: self)
        self.startTimer()
    }
    
    func startTimer() {
        if let fireDate = Controllers.dataModel.nextAlarmDate {
            self.titleView.startCountDown(withFireDate: fireDate)
        }
    }
    
    func countDownDidFinish(_ countDownTextField: CountDownTextField) {
        self.startTimer()
    }
    
    func dataModelDidReload(_ dataModel: RCCalendarDataModel) {
        self.startTimer()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.titleView.stopCountDown()
        self.reloader = nil
    }
    

    
}

