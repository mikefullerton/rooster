//
//  Controllers+macOS.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/27/21.
//

import Foundation
import RoosterCore

extension Controllers {
    public static let sparkleController = SparkleController()

    public static func setupControllers() {
        Controllers.setupRoosterCore()
        Controllers.menuBarController.showInMenuBar()

        Controllers.sparkleController.configure(withAppBundle: Bundle.init(for: type(of:AppDelegate.instance)))
    }
}
