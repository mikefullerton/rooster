//
//  SoundPickerTableView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/29/20.
//

import Foundation
import UIKit

protocol SoundPickerTableViewControllerDelegate : AnyObject {
    func soundPickerTableViewController(_ soundPicker: SoundPickerTableViewController, didSelectSound soundURL: URL)
}

class SoundPickerTableViewController : TableViewController<SoundPickerTableViewModel>, SoundPickerTableViewCellDelegate {
    
    weak var soundPickerDelegate: SoundPickerTableViewControllerDelegate?
    
    let soundIndex: SoundPreference.SoundIndex
    
    init(withSoundIndex soundIndex: SoundPreference.SoundIndex) {
        self.soundIndex = soundIndex
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(preferencesDidChange(_:)), name: PreferencesController.DidChangeEvent, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func reloadViewModel() -> SoundPickerTableViewModel? {
        return SoundPickerTableViewModel(withURLs: SoundPreference.availableSoundURLs, soundIndex: self.soundIndex)
    }

    @objc func preferencesDidChange(_ sender: Notification) {
        self.tableView.reloadData()
    }
    
    func soundPickerTableViewCell(_ soundPicker: SoundPickerTableViewCell, didSelectSound soundURL: URL) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(330)) {
            if let delegate = self.soundPickerDelegate {
                delegate.soundPickerTableViewController(self, didSelectSound: soundURL)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let soundCell = cell as? SoundPickerTableViewCell {
            soundCell.soundPickerDelegate = self
        }
    }

}
