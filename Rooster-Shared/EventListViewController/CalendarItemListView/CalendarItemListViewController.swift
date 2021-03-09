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

class CalendarItemListViewController<ViewModel:ListViewModelProtocol> : ListViewController<ViewModel>, CalendarListRowControllerDelegate, ColorPickerDelegate, DataModelAware {
    
    private var reloader: DataModelReloader?

    public var minimumContentSize = CGSize(width: 500, height: NoMeetingsListViewCell.preferredSize(forContent: nil).height)
    
    private let horizontalPadding:CGFloat = 100
    
    private var colorPicker: ColorPicker? {
        didSet {
            if oldValue != colorPicker {
                oldValue?.delegate = nil
            }
        }
    }
    
    var preferredWindowSize: CGSize {
        return self.viewModelContentSize
//        self.logger.log("Preferred content size: \(NSStringFromSize(size))")
////        size.width += self.horizontalPadding
//        return size;
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.reloader = DataModelReloader(for: self)
        self.preferredContentSize = self.preferredWindowSize
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        self.reloader = nil
        
        self.colorPicker?.hide()
        self.colorPicker = nil

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var frame = CGRect.zero
        frame.size = self.minimumContentSize
        self.view.frame = frame

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
    
    func calendarRowShouldPickColor(_ calendarRow: CalendarListRowController) {
    
        if let calendar = calendarRow.calendar {
            let colorPicker = ColorPicker(withDelegate: self, userInfo: Updater(representedObject: calendar))
            colorPicker.show()
            self.colorPicker = colorPicker
            
            print("Starting color: \(String(describing:colorPicker.userInfo))")
        }
        
    }
            
    func updaterFromColorPicker(_ colorPicker: ColorPicker) -> Updater<RCCalendar>? {
        return (colorPicker.userInfo as? Updater<RCCalendar>)
    }

    func calendarFromColorPicker(_ colorPicker: ColorPicker) -> RCCalendar? {
        return self.updaterFromColorPicker(colorPicker)?.representedObject
    }
    
    func colorPickerGetColor(_ colorPicker: ColorPicker) -> SDKColor? {
        
        if let calendar = self.calendarFromColorPicker(colorPicker) {
            let color = calendar.color
            
            return color
        }
        
        return nil
    }
            
    func colorPicker(_ colorPicker: ColorPicker, didUpdateColor color: SDKColor) {
        
        if let updater = self.updaterFromColorPicker(colorPicker) {
                updater.update(afterMilliseconds: 200) { [weak self] in
                    
                if var calendar = self?.calendarFromColorPicker(colorPicker) {
                    calendar.cgColor = color.cgColor
                    Controllers.calendar.save(calendar: calendar)
                }
            }
        }
    
    }
    
    open override func collectionView(_ collectionView: NSCollectionView,
                                      willDisplay item: NSCollectionViewItem,
                                      forRepresentedObjectAt indexPath: IndexPath) {
        
        super.collectionView(collectionView, willDisplay: item, forRepresentedObjectAt: indexPath)
     
        if let calendarRow = item as? CalendarListRowController {
            calendarRow.delegate = self
        }
    }

}

