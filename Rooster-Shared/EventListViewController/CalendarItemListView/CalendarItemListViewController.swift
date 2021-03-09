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

open class CalendarItemListViewController: ListViewController {
    private var scheduleUpdateHandler = ScheduleUpdateHandler()

    override public var minimumPreferredContentSize: CGSize? {
        CGSize(width: 500, height: NoMeetingsListViewCell.preferredSize(forContent: nil).height)
    }

    override open func viewWillAppear() {
        super.viewWillAppear()

        self.scheduleUpdateHandler.handler = { [weak self] _, _ in
            guard let self = self else { return }
            self.reloadData()
        }
    }

    override open func viewWillDisappear() {
        super.viewWillDisappear()
        self.scheduleUpdateHandler.handler = nil
    }

//    override open func viewDidLoad() {
//        super.viewDidLoad()
//
//        var frame = CGRect.zero
//        frame.size = self.minimumContentSize
//        self.view.frame = frame
//    }

}
