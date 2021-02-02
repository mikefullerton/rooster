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
    let soundFolder: SoundFolder
    
    init(withSoundIndex soundIndex: SoundPreferences.SoundIndex) {
        self.soundIndex = soundIndex
        self.soundFolder = SoundFolder.loadFromBundle()
        
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
        self.collectionView.allowsMultipleSelection = false
        self.collectionView.isSelectable = true
    }
    
    func setSelectedRow() {
        let sound = AppDelegate.instance.preferencesController.soundPreferences[self.soundIndex]
        
        for (folderIndex, subfolder) in self.soundFolder.subFolders.enumerated() {
            for(soundIndex, soundURL) in subfolder.soundURLs.enumerated() {
                if soundURL == sound.url {
                    
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
    
    var chosenSound : SoundPreferences.Sound? {
        if let selectedIndexPath = self.selectedIndexPath {
            for (folderIndex, subfolder) in self.soundFolder.subFolders.enumerated() {
                for(soundIndex, soundURL) in subfolder.soundURLs.enumerated() {
                    if folderIndex == selectedIndexPath.section &&
                        soundIndex == selectedIndexPath.item {
                        return SoundPreferences.Sound(url: soundURL, enabled: true, random: false)
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
