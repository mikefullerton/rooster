//
//  CalendarListViewController.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/13/21.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

open class CalendarListViewController: ListViewController,
                                       CalendarListRowControllerDelegate,
                                       ColorPickerDelegate {
    private var scheduleUpdateHandler = ScheduleUpdateHandler()

    override public var minimumPreferredContentSize: CGSize? {
        CGSize(width: 500, height: 100)
    }

    private var colorPicker: ColorPicker? {
        didSet {
            if oldValue != colorPicker {
                oldValue?.delegate = nil
            }
        }
    }

    var preferredWindowSize: CGSize {
        self.viewModelContentSize
        //        self.logger.log("Preferred content size: \(String(describing:size))")
        // //        size.width += self.horizontalPadding
        //        return size;
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

        self.colorPicker?.hide()
        self.colorPicker = nil
    }

//    override open func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.minimumPreferredContentSize =
//
//        var frame = CGRect.zero
//        frame.size = self.minimumContentSize
//        self.view.frame = frame
//    }

//    override open var preferredContentSize: CGSize {
//        get {
//            super.preferredContentSize
//        }
//        set(size) {
//            var size = size
//            size.width = max(size.width, self.minimumContentSize.width)
//            size.height = max(size.height, self.minimumContentSize.height)
//            super.preferredContentSize = size
//            self.logger.log("Set preferred content size: \(String(describing: size))")
//        }
//    }

    open func calendarRowShouldPickColor(_ calendarRow: CalendarListRowController) {
        if let scheduleItem = calendarRow.scheduleItem {
            let colorPicker = ColorPicker(withDelegate: self, userInfo: Updater(representedObject: scheduleItem))
            colorPicker.show()
            self.colorPicker = colorPicker

            print("Starting color: \(String(describing: colorPicker.userInfo))")
        }
    }

    public func updaterFromColorPicker(_ colorPicker: ColorPicker) -> Updater<ScheduleCalendar>? {
        (colorPicker.userInfo as? Updater<ScheduleCalendar>)
    }

    public func calendarFromColorPicker(_ colorPicker: ColorPicker) -> ScheduleCalendar? {
        self.updaterFromColorPicker(colorPicker)?.representedObject
    }

    public func colorPickerGetColor(_ colorPicker: ColorPicker) -> SDKColor? {
        if let calendar = self.calendarFromColorPicker(colorPicker) {
            let color = calendar.color

            return color
        }

        return nil
    }

    public func colorPicker(_ colorPicker: ColorPicker, didUpdateColor color: SDKColor) {
        if let updater = self.updaterFromColorPicker(colorPicker) {
            updater.update(afterMilliseconds: 200) { [weak self] in
                if var calendar = self?.calendarFromColorPicker(colorPicker) {
                    calendar.cgColor = color.cgColor
                    CoreControllers.shared.scheduleController.update(calendar: calendar)
                }
            }
        }
    }

    override open func collectionView(_ collectionView: NSCollectionView,
                                      willDisplay item: NSCollectionViewItem,
                                      forRepresentedObjectAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: item, forRepresentedObjectAt: indexPath)

        if let calendarRow = item as? CalendarListRowController {
            calendarRow.delegate = self
        }
    }

    open func toggleAll() {
    }
}
