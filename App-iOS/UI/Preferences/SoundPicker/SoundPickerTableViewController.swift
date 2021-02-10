//
//  SoundPickerTableView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/29/20.
//

import Foundation
import UIKit


class SoundPickerTableViewController : ListViewController<SoundPickerTableViewModel> {
    
    let soundPreferenceKey: SoundPreferences.SoundPreferenceKey
    let soundFolder: SoundFolder
    
    init(withSoundIndex soundPreferenceKey: SoundPreferences.SoundPreferenceKey) {
        self.soundPreferenceKey = soundPreferenceKey
        self.soundFolder = SoundFolder.loadFromBundle()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func provideDataModel() -> SoundPickerTableViewModel? {
        return SoundPickerTableViewModel(with: self.soundFolder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsSelection = true
        self.tableView.allowsMultipleSelection = false
        self.tableView.selectionFollowsFocus = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setSelectedRow()
    }
    
    func setSelectedRow() {
        let sound = AppDelegate.instance.preferencesController.soundPreferences.soundPreferenceForKey(self.soundPreferenceKey)
        
        for (folderIndex, subfolder) in self.soundFolder.subFolders.enumerated() {
            for(soundIndex, soundURL) in subfolder.soundURLs.enumerated() {
                if soundURL == sound.url {
                    self.tableView.selectRow(at: IndexPath(item: soundIndex, section: folderIndex), animated: true, scrollPosition: .bottom)
                    break
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setSelectedRow()
    }
    
    var selectedCell: SoundPickerTableViewCell? {
        if let selectedIndexPath = self.tableView.indexPathForSelectedRow,
           let cell = self.tableView.cellForRow(at: selectedIndexPath) as? SoundPickerTableViewCell {
            return cell
        }

        return nil
    }
    
    var chosenSound : SingleSoundPreference? {
        if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
            for (folderIndex, subfolder) in self.soundFolder.subFolders.enumerated() {
                for(soundIndex, soundURL) in subfolder.soundURLs.enumerated() {
                    if folderIndex == selectedIndexPath.section &&
                        soundIndex == selectedIndexPath.item {
                        return SingleSoundPreference(url: soundURL, enabled: true, random: false)
                    }
                }
            }
        }
        
        return nil
    }

    func togglePlayingOnCurrentCell() {
        if let cell = self.selectedCell {
            cell.playButton.togglePlayingState()
        }
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        // Run backward or forward when the user presses a left or right arrow key.

        var didHandleEvent = false
        for press in presses {
            
            if let key = press.key,
                key.keyCode == .keyboardReturnOrEnter {
                self.togglePlayingOnCurrentCell()
                didHandleEvent = true
            }
        }

        if didHandleEvent == false {
            // Didn't handle this key press, so pass the event to the next responder.
            super.pressesBegan(presses, with: event)
        }
    }
}
