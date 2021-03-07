//
//  CalendarItemListViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/2/20.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public class CalendarItemListViewController<ViewModel:ListViewModelProtocol> : ListViewController<ViewModel>, DataModelAware {
    
    private var reloader: DataModelReloader? = nil

    public override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.minimumContentSize = CGSize(width: 400, height: NoMeetingsListViewCell.preferredSize.height)
        self.preferredContentSize = self.minimumContentSize
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func viewWillAppear() {
        super.viewWillAppear()
        self.reloader = DataModelReloader(for: self)
        self.preferredContentSize = self.viewModelContentSize
    }
    
    public override func viewWillDisappear() {
        super.viewWillDisappear()
        self.reloader = nil
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.sdkLayer.backgroundColor = NSColor.clear.cgColor
        self.collectionView.backgroundColors = [ .clear ]
        self.scrollView.drawsBackground = false
        self.scrollView.contentView.drawsBackground = false
    }

    public func dataModelDidReload(_ dataModel: RCCalendarDataModel) {
        self.reloadData()
        self.preferredContentSize = self.viewModelContentSize
    }
}

