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

class CalendarItemListViewController<ViewModel> : ListViewController<ViewModel>, DataModelAware where ViewModel: ListViewModelProtocol {
    
    private var reloader: DataModelReloader? = nil

    public var minimumContentSize = CGSize(width: 500, height: NoMeetingsListViewCell.preferredHeight)
    
    private let horizontalPadding:CGFloat = 100
    
    var preferredWindowSize: CGSize {
        var size = self.viewModelContentSize
        self.logger.log("Preferred content size: \(NSStringFromSize(size))")
//        size.width += self.horizontalPadding
        return size;
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.reloader = DataModelReloader(for: self)
        self.preferredContentSize = self.preferredWindowSize
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        self.reloader = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var frame = CGRect.zero
        frame.size = self.minimumContentSize
        self.view.frame = frame;

        self.view.sdkLayer.backgroundColor = NSColor.clear.cgColor
        self.collectionView.backgroundColors = [ .clear ]
        self.scrollView.drawsBackground = false
        self.scrollView.contentView.drawsBackground = false
    }

    func dataModelDidReload(_ dataModel: RCCalendarDataModel) {
        self.reloadData()
        self.preferredContentSize = self.preferredWindowSize
    }
    
    open override var preferredContentSize: NSSize {
        get {
            return super.preferredContentSize
        }
        set(size) {
            var size = size
            size.width = max(size.width, self.minimumContentSize.width)
            size.height = max(size.height, self.minimumContentSize.height)
            super.preferredContentSize = size
            self.logger.log("Set preferred content size: \(NSStringFromSize(size))")
        }
    }
}

