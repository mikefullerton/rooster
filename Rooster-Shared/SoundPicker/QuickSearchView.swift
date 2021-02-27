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
}

class QuickSearchView : TopBar, NSSearchFieldDelegate {

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
        
    func controlTextDidChange(_ obj: Notification) {
        self.delegate?.quickSearchViewDidBeginSearching(self, content: self.searchField.stringValue)
    }
    
    let insets = SDKEdgeInsets.twenty
    
    func addSearchView() {
        
        let view = self.searchField
        
        self.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.insets.left),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -self.insets.right),
            view.heightAnchor.constraint(equalToConstant: view.intrinsicContentSize.height),
            view.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

}
