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
    
    let soundPreferenceKey: SoundPreferences.PreferenceKey
    private(set) var soundFolder: SoundFolder
    
    init(withSoundIndex soundPreferenceKey: SoundPreferences.PreferenceKey) {
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
        self.collectionView.allowsMultipleSelection = false // TODO: enabled multiple sounds
        self.collectionView.isSelectable = true
    }
    
    func updateSoundFolder(_ soundFolder: SoundFolder) {
        self.soundFolder = soundFolder
        self.reloadData()
    }
    
    func setSelectedRow() {
        let singleSoundPref = Controllers.preferencesController.soundPreferences.soundPreference(forKey: self.soundPreferenceKey)
        let soundSet = singleSoundPref.soundSet
        let soundFiles = soundSet.soundFiles
        
        self.collectionView.deselectAll(self)
        
        /// TODO: Enable multiple sounds
        if soundFiles.count != 1 {
            return
        }
        
        var indexPathsToSelect = Set<IndexPath>()
        for sound in soundFiles {
            if let indexPath = self.viewModel?.indexPath(forSoundFile: sound) {
                indexPathsToSelect.insert(indexPath)
            }
        }

        if indexPathsToSelect.count > 0 {
            self.collectionView.selectItems(at: indexPathsToSelect,
                                            scrollPosition: .centeredVertically)
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
    
    var chosenSound : [SoundFile]? {
        var chosenSounds:[SoundFile] = []
        
        // TODO: add multiple sound selection
        if let selectedIndexPath = self.selectedIndexPath {
            if let soundFile = self.viewModel?.soundFile(forIndexPath: selectedIndexPath) {
                chosenSounds.append(soundFile)
            }
        }

        if chosenSounds.count == 0 {
            return nil
        }
       
        return chosenSounds
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
