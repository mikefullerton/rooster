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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func reloadViewModel() -> SoundPickerTableViewModel? {
        return SoundPickerTableViewModel(withURLs: SoundPreference.availableSoundURLs, soundIndex: self.soundIndex)
    }
    
    func soundPickerTableViewCell(_ soundPicker: SoundPickerTableViewCell, didSelectSound soundURL: URL) {
        
        self.tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
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
    
//    - (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
    
}
