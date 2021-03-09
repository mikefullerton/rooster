//
//  QuickSearchView.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/3/21.
//

import Foundation
import RoosterCore
import AppKit

protocol QuickSearchViewDelegate : AnyObject {
    func quickSearchViewDidEndSearching(_ quickSearchView: QuickSearchView, content: String)
    func quickSearchViewDidBeginSearching(_ quickSearchView: QuickSearchView, content: String)
    func quickSearchViewDownArrowPressed(_ quickSearchView: QuickSearchView)
    func quickSearchViewUpArrowPressed(_ quickSearchView: QuickSearchView)
}

class QuickSearchView : TopBar, NSSearchFieldDelegate, NSTextFieldDelegate {

    weak var delegate: QuickSearchViewDelegate?
    
    lazy var searchField: NSSearchField = {
        let view = NSSearchField()
        view.delegate = self
        view.sendsWholeSearchString = true
        
//        view.sendsSearchStringImmediately = true
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addShuffleButton()
        self.addPlaySoundButton()
        self.addSearchView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
//        self.delegate?.quickSearchViewDidEndSearching(self, content: self.searchField.stringValue)
    }
    
    func searchFieldDidStartSearching(_ sender: NSSearchField) {
//        self.delegate?.quickSearchViewDidBeginSearching(self, content: self.searchField.stringValue)
    }
    
    var timestamp: TimeInterval = 0
        
    func controlTextDidChange(_ obj: Notification) {
        let timestamp = Date.timeIntervalSinceReferenceDate;
        self.timestamp = timestamp
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(300)) {
            if (self.timestamp == timestamp) {
                self.delegate?.quickSearchViewDidBeginSearching(self, content: self.searchField.stringValue)
            }
        }
    }
    
    let insets = SDKEdgeInsets.twenty
    
    lazy var playSoundButton: PlaySoundButton = {
        let button = PlaySoundButton()
        return button
    }()
    
    func addPlaySoundButton() {
        let button = self.playSoundButton
        
        self.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            button.leadingAnchor.constraint(equalTo: self.shuffleButton.trailingAnchor, constant: 0),
        ])
    }
    
    lazy var shuffleButton: ImageButton = {
        let config = NSImage.SymbolConfiguration(scale: .large)
        let button = ImageButton(withSystemImageName: "shuffle", symbolConfiguration: config)
        return button
    }()

    func addShuffleButton() {
        let button = self.shuffleButton
        self.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            button.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
        ])
    }
    

    func addSearchView() {
        
        let view = self.searchField
        
        self.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.playSoundButton.trailingAnchor, constant: self.insets.left),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -self.insets.right),
            view.heightAnchor.constraint(equalToConstant: view.intrinsicContentSize.height),
            view.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(moveUp(_:)) {
            self.delegate?.quickSearchViewUpArrowPressed(self)
            return true
        } else if commandSelector == #selector(moveDown(_:)) {
            self.delegate?.quickSearchViewDownArrowPressed(self)
            return true
        }
        return false
    }

}
