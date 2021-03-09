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

protocol SoundPickerListViewControllerDelegate : AnyObject {
    func soundPickerListViewControllerDidChangeSelection(_ controller: SoundPickerListViewController)
}

class SoundPickerListViewController : ListViewController<SoundPickerListViewModel> {
    
    weak var soundPickerDelegate: SoundPickerListViewControllerDelegate?
    
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
    
    func tryToSelectSoundFiles(_ soundFiles: [SoundFile]) {
        var indexPathsToSelect: [IndexPath] = []
        
        for soundFile in soundFiles {
            if let indexPath = self.viewModel?.indexPath(forSoundFile: soundFile) {
                indexPathsToSelect.append(indexPath)
            }
        }

        if indexPathsToSelect.count == 0 && self.rowCount > 0 {
            indexPathsToSelect.append(IndexPath(item: 0, section: 0))
        }
        
        self.deselectSelectedRows()
        self.setSelectedRows(indexPathsToSelect)
    }
    
    func updateSoundFolder(_ soundFolder: SoundFolder) {
        
        let selectedSounds = self.selectedSoundFiles
        
        self.collectionView.deselectItems(at: self.collectionView.selectionIndexPaths)
        self.soundFolder = soundFolder
        self.reloadData()
        self.tryToSelectSoundFiles(selectedSounds)
    }
    
    func selectRandomSoundFile() {
        
        let soundFile = self.soundFolder.randomSoundFile
        
        var indexPathsToSelect: [IndexPath] = []
        
        if let indexPath = self.viewModel?.indexPath(forSoundFile: soundFile) {
            indexPathsToSelect.append(indexPath)
        }

        if indexPathsToSelect.count > 0 {
            self.setSelectedRows(indexPathsToSelect)
        }
    }
    
    func setSelectedRows() {
        let singleSoundPref = Controllers.preferencesController.soundPreferences.soundPreference(forKey: self.soundPreferenceKey)
        let soundSet = singleSoundPref.soundSet
        let soundFiles = soundSet.soundFiles
        
        self.tryToSelectSoundFiles(soundFiles)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.setSelectedRows()
    }
    
    var selectedSoundFiles : [SoundFile] {
        var chosenSounds:[SoundFile] = []
        for indexPath in self.collectionView.selectionIndexPaths {
            if let soundFile = self.viewModel?.soundFile(forIndexPath: indexPath) {
                chosenSounds.append(soundFile)
            }
        }

        return chosenSounds
    }

    override func keyDown(with event: NSEvent) {
        var didHandleEvent = false

        if event.keyCode == 36 {
//            self.togglePlayingOnCurrentCell()
            didHandleEvent = true
        }
        
        if !didHandleEvent {
            super.keyDown(with: event)
        }
    }
    
    override func collectionView(_ collectionView: NSCollectionView,
                                 didSelectItemsAt indexPaths: Set<IndexPath>) {
        self.soundPickerDelegate?.soundPickerListViewControllerDidChangeSelection(self)
    }
    
    override func collectionView(_ collectionView: NSCollectionView,
                                 didDeselectItemsAt indexPaths: Set<IndexPath>) {
        self.soundPickerDelegate?.soundPickerListViewControllerDidChangeSelection(self)
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
