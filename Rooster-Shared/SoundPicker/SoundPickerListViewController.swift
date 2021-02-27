//
//  SoundPickerListView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/29/20.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif


class SoundPickerListViewController : ListViewController<SoundPickerListViewModel> {
    
    let soundPreferenceKey: SoundPreferences.SoundPreferenceKey
    private(set) var soundFolder: SoundFolder
    
    init(withSoundIndex soundPreferenceKey: SoundPreferences.SoundPreferenceKey) {
        self.soundPreferenceKey = soundPreferenceKey
        self.soundFolder = SoundFolder.instance
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func provideDataModel() -> SoundPickerListViewModel? {
        return SoundPickerListViewModel(with: self.soundFolder)
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
        let soundSet = Controllers.preferencesController.soundPreferences.soundPreference(forKey: self.soundPreferenceKey).soundSet
        
        for (folderIndex, subfolder) in self.soundFolder.subFolders.enumerated() {
            for(soundIndex, soundFile) in subfolder.soundFiles.enumerated() {
                if soundSet.soundFolder.contains(soundID: soundFile.id) {
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
    
    var selectedCell: SoundPickerListViewCell? {
        if let indexPath = self.selectedIndexPath,
           let cell = self.collectionView.item(at: indexPath) as? SoundPickerListViewCell {
            return cell
        }

        return nil
    }
    
    var chosenSound : SingleSoundPreference? {
        
        var chosenSounds:[SoundFile] = []
        var randomizers:[String: PlayListRandomizer] = [:]
        
        if let selectedIndexPath = self.selectedIndexPath {
            for (folderIndex, subfolder) in self.soundFolder.subFolders.enumerated() {
                for(index, soundFile) in subfolder.soundFiles.enumerated() {
                    if folderIndex == selectedIndexPath.section &&
                    index == selectedIndexPath.item {
                        
                        chosenSounds.append(soundFile)
                        
                        randomizers[soundFile.id] = PlayListRandomizer.never
                    }
                }
            }
        }

        if chosenSounds.count == 0 {
            return nil
        }
       
        return SingleSoundPreference.singleSoundPref(withSoundFiles: chosenSounds, randomizers: randomizers)
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
