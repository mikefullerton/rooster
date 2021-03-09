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

open class CalendarItemListViewController<T: ListViewModel>: ListViewController<T> {
    private var scheduleUpdateHandler = ScheduleUpdateHandler()

    public var minimumContentSize = CGSize(width: 500, height: NoMeetingsListViewCell.preferredSize(forContent: nil).height)

    var preferredWindowSize: CGSize {
        self.viewModelContentSize
    }

    override open func viewWillAppear() {
        super.viewWillAppear()

        self.preferredContentSize = self.preferredWindowSize

        self.scheduleUpdateHandler.handler = { [weak self] _, _ in
            guard let self = self else { return }
            self.reloadData()
            self.preferredContentSize = self.preferredWindowSize
        }
    }

    override open func viewWillDisappear() {
        super.viewWillDisappear()
        self.scheduleUpdateHandler.handler = nil
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        var frame = CGRect.zero
        frame.size = self.minimumContentSize
        self.view.frame = frame

        self.view.sdkLayer.backgroundColor = NSColor.clear.cgColor
        self.collectionView.backgroundColors = [ .clear ]
        self.scrollView.drawsBackground = false
        self.scrollView.contentView.drawsBackground = false
    }

    override open var preferredContentSize: CGSize {
        get {
            super.preferredContentSize
        }
        set(size) {
            var size = size
            size.width = max(size.width, self.minimumContentSize.width)
            size.height = max(size.height, self.minimumContentSize.height)
            super.preferredContentSize = size
            self.logger.log("Set preferred content size: \(String(describing: size))")
        }
    }
}
