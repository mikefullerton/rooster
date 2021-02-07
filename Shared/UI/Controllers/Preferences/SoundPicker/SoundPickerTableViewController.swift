//
//  SoundPickerTableView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/29/20.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif


class SoundPickerTableViewController : TableViewController<SoundPickerTableViewModel> {
    
    let soundIndex: SoundPreferences.SoundIndex
    private(set) var soundFolder: SoundFolder
    
    init(withSoundIndex soundIndex: SoundPreferences.SoundIndex) {
        self.soundIndex = soundIndex
        self.soundFolder = SoundFolder.instance
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func reloadViewModel() -> SoundPickerTableViewModel? {
        return SoundPickerTableViewModel(with: self.soundFolder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.allowsEmptySelection = false
        self.collectionView.allowsMultipleSelection = true
        self.collectionView.isSelectable = true
    }
    
    func updateSoundFolder(_ soundFolder: SoundFolder) {
        self.soundFolder = soundFolder
        self.reloadData()
    }
    
    func setSelectedRow() {
        let soundSet = AppDelegate.instance.preferencesController.soundPreferences[self.soundIndex].soundSet
        
        for (folderIndex, subfolder) in self.soundFolder.subFolders.enumerated() {
            for(soundIndex, soundFile) in subfolder.sounds.enumerated() {
                if soundSet.contains(soundFile.id) {
                    self.collectionView.selectItems(at: Set<IndexPath>([ IndexPath(item: soundIndex, section: folderIndex) ]),
                                                    scrollPosition: .centeredVertically)
                    break
                }
            }
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.setSelectedRow()
    }
    
    var selectedIndexPath: IndexPath? {
        let selectedIndexPaths = self.collectionView.selectionIndexPaths
        
        if selectedIndexPaths.count == 1 {
            return selectedIndexPaths.first
        }
        
        return nil
        
    }
    
    var selectedCell: SoundPickerTableViewCell? {
        if let indexPath = self.selectedIndexPath,
           let cell = self.collectionView.item(at: indexPath) as? SoundPickerTableViewCell {
            return cell
        }

        return nil
    }
    
    var chosenSound : SingleSoundPreference? {
        
        var chosenSoundIdentifers:[String] = []
        
        if let selectedIndexPath = self.selectedIndexPath {
            for (folderIndex, subfolder) in self.soundFolder.subFolders.enumerated() {
                for(soundIndex, soundFile) in subfolder.sounds.enumerated() {
                    if folderIndex == selectedIndexPath.section &&
                        soundIndex == selectedIndexPath.item {
                        
                        chosenSoundIdentifers.append(soundFile.id)
                    }
                }
            }
        }

        if chosenSoundIdentifers.count == 0 {
            return nil
        }
        
        let id = "\(self.soundIndex)"
        
        let soundIdentifiers = chosenSoundIdentifers.map { SoundFileDescriptor(with: $0, randomizerPriority: .normal) }
        
        let soundSet = SoundSet(withIdentifier: id, name: "user-soundset-\(id)", soundIdentifiers: soundIdentifiers)
        
        return SingleSoundPreference(withIdentifier: id, soundSet: soundSet, enabled: true)
    }

    func togglePlayingOnCurrentCell() {
        if let cell = self.selectedCell {
            cell.playButton.togglePlayingState()
        }
    }
    
    override func keyDown(with event: NSEvent) {
        var didHandleEvent = false

        if event.keyCode == 36 {
            self.togglePlayingOnCurrentCell()
            didHandleEvent = true
        }
        
        if !didHandleEvent {
            super.keyDown(with: event)
        }
    }
    
//    override - (void)keyDown:(NSEvent *)event
  
    /// TODO: Maybe
    
//    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
//        // Run backward or forward when the user presses a left or right arrow key.
//
//        var didHandleEvent = false
//        for press in presses {
//
//            if let key = press.key,
//                key.keyCode == .keyboardReturnOrEnter {
//                self.togglePlayingOnCurrentCell()
//                didHandleEvent = true
//            }
//        }
//
//        if didHandleEvent == false {
//            // Didn't handle this key press, so pass the event to the next responder.
//            super.pressesBegan(presses, with: event)
//        }
//    }
}
