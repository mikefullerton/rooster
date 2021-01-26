//
//  CountDownCell.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/25/21.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class CountdownHeaderView : BlurView, TableViewAdornmentView, DataModelAware {
    private var reloader: DataModelReloader? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addTitleView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static var preferredHeight: CGFloat {
        return 40
    }
    
    lazy var titleView: CountdownTextField = {
        let titleView = CountdownTextField()
        titleView.isEditable = false
        titleView.textColor = Theme(for: self).secondaryLabelColor
        titleView.alignment = .center
        titleView.font = SDKFont.boldSystemFont(ofSize: SDKFont.smallSystemFontSize)
        titleView.drawsBackground = false
        titleView.isBordered = false
        titleView.prefixString = "Your next alarm will fire in "
        titleView.showSecondsWithMinutes = true
        
        return titleView
    }()

    func addTitleView() {
        let titleView = self.titleView
       
        self.addSubview(titleView)
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
    func viewWillAppear(withContent content: TableViewSectionAdornmentProtocol) {
        self.reloader = DataModelReloader(for: self)
        self.startTimer()
    }
    
    func startTimer() {
        self.titleView.startTimer(fireDate: AppDelegate.instance.dataModelController.dataModel.nextAlarmDate) { () -> Date? in
            return AppDelegate.instance.dataModelController.dataModel.nextAlarmDate
        }
    }
    
    func dataModelDidReload(_ dataModel: DataModel) {
        self.startTimer()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.titleView.stopCountdown()
        self.reloader = nil
    }
    

    
}

