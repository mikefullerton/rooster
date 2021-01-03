//
//  SoundPickerTableView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/29/20.
//

import Foundation
import UIKit

typealias SoundPickerTableViewModel = TableViewModel<URL, SoundPickerTableViewCell>

class SoundPickerTableViewController : TableViewController<SoundPickerTableViewModel> {
    
    let soundIndex: SoundPreference.SoundIndex
    let urls: [URL]
    
    init(withSoundIndex soundIndex: SoundPreference.SoundIndex) {
        self.soundIndex = soundIndex
        self.urls = SoundPreference.availableSoundURLs
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func reloadViewModel() -> SoundPickerTableViewModel? {
        return SoundPickerTableViewModel(withData: self.urls)
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
//        for (index, url) in self.urls.enumerated() {
//            if url.fileName == sound.name {
//                self.tableView.selectRow(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .bottom)
//                break
//            }
//        }
    }
    
    func setSelectedRow() {
        let sound = PreferencesController.instance.preferences.sounds[self.soundIndex]
        
        for (index, url) in self.urls.enumerated() {
            if url.fileName == sound.name {
                self.tableView.selectRow(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .bottom)
                break
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setSelectedRow()

//        if let selected = self.tableView.indexPathForSelectedRow {
//            self.tableView.scrollToRow(at: selected, at: .bottom, animated: false)
//
//        }
//
//        if let cell = self.selectedCell {
////            cell.becomeFirstResponder()
//
//            cell.isHighlighted = true
//        }
    }
    
    var selectedCell: SoundPickerTableViewCell? {
        if let selectedIndexPath = self.tableView.indexPathForSelectedRow,
           let cell = self.tableView.cellForRow(at: selectedIndexPath) as? SoundPickerTableViewCell {
            return cell
        }

        return nil
    }
    
    func setChosenSound() {
        if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
            
            let url = self.urls[selectedIndexPath.item]
            
            let newSound = SoundPreference.Sound(url: url, enabled: true, random: false)
            
            PreferencesController.instance.preferences.sounds[self.soundIndex] = newSound
        }
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
    
//    override var keyCommands: [UIKeyCommand]? {
//
//        var commands = super.keyCommands
//
//        if commands == nil {
//            commands = []
//        }
//
//        commands!.append(
//            [UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags: .shift, action: #selector(dismiss), discoverabilityTitle: "Close modal view")]
//        )
//
//
//
//        return
//    }
}
