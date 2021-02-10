//
//  CalendarItemListViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/2/20.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class CalendarItemListViewController<ViewModel> : ListViewController<ViewModel>, DataModelAware where ViewModel: ListViewModelProtocol {
    
    private var reloader: DataModelReloader? = nil

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.minimumContentSize = CGSize(width: 400, height: NoMeetingsListViewCell.preferredHeight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewWillAppear() {
        super.viewWillAppear()
        self.reloader = DataModelReloader(for: self)
        self.preferredContentSize = self.viewModelContentSize
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        self.reloader = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.view.sdkBackgroundColor = Theme(for: self.view).windowBackgroundColor
    
        self.view.sdkLayer.backgroundColor = NSColor.clear.cgColor
        self.collectionView.backgroundColors = [ .clear ]
        self.scrollView.drawsBackground = false
        self.scrollView.contentView.drawsBackground = false

        //        self.view.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }

    func dataModelDidReload(_ dataModel: DataModel) {
        self.reloadData()
        self.preferredContentSize = self.viewModelContentSize
    }
}

