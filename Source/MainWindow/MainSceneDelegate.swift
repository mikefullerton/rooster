//
//  SceneDelegate.swift
//  UIKitForMacPlayground
//
//  Created by Noah Gilmore on 6/27/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import UIKit

//#if targetEnvironment(macCatalyst)
//extension NSToolbarItem.Identifier {
////    static let editRecipe = NSToolbarItem.Identifier("com.example.apple-samplecode.Recipes.editRecipe")
////    static let toggleRecipeIsFavorite = NSToolbarItem.Identifier("com.example.apple-samplecode.Recipes.toggleRecipeIsFavorite")
//}
//
//#endif
//

class MainSceneDelegate: WindowSceneDelegate, NSToolbarDelegate {

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
     
        windowScene.sizeRestrictions?.minimumSize = CGSize(width: 400, height: 200.0)
        windowScene.sizeRestrictions?.maximumSize = CGSize(
          width: CGFloat.greatestFiniteMagnitude,
          height: CGFloat.greatestFiniteMagnitude
        )
        
        let window = UIWindow(windowScene: windowScene)
        let viewController = MainViewController()
        window.rootViewController = viewController
        
        self.set(window: window, restoreKey: "mainWindowBounds")
        
        #if targetEnvironment(macCatalyst)
        
        let toolbar = NSToolbar(identifier: "main")
        toolbar.delegate = self
        toolbar.displayMode = .iconOnly
        
        if let titlebar = windowScene.titlebar {
            titlebar.toolbar = toolbar
            titlebar.toolbarStyle = .automatic
        }
        #endif
    }
    
    
//    @objc
//    func editRecipe(_ sender: Any?) {
//        NotificationCenter.default.post(name: .editRecipe, object: self)
//    }
//
//    @objc
//    func toggleRecipeIsFavorite(_ sender: Any?) {
//        NotificationCenter.default.post(name: .toggleRecipeIsFavorite, object: self)
//    }
//

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        let identifiers: [NSToolbarItem.Identifier] = [
            .toggleSidebar,
            .flexibleSpace,
//            .editRecipe,
//            .toggleRecipeIsFavorite
        ]
        return identifiers
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarDefaultItemIdentifiers(toolbar)
    }
    
    func toolbar(_ toolbar: NSToolbar,
                 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        
        var toolbarItem: NSToolbarItem?
        
        switch itemIdentifier {
        case .toggleSidebar:
            toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
        
//        case .editRecipe:
//            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
//            item.image = UIImage(systemName: "square.and.pencil")
//            item.label = "Edit Recipe"
//            item.action = #selector(editRecipe(_:))
//            item.target = self
//            toolbarItem = item
//
//        case .toggleRecipeIsFavorite:
//            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
//            item.image = UIImage(systemName: "heart")
//            item.label = "Toggle Favorite"
//            item.action = #selector(toggleRecipeIsFavorite(_:))
//            item.target = self
//            toolbarItem = item
            
        default:
            toolbarItem = nil
        }
        
        return toolbarItem
    }
}

