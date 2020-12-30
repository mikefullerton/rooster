//
//  SoundChooserViewController.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/30/20.
//

import Foundation
import UIKit


protocol SoundChooserViewControllerDelegate : AnyObject {
    func soundChooserViewControllerWillDismiss(_ controller: SoundChooserViewController)
    func soundChooserViewControllerWasDismissed(_ controller: SoundChooserViewController)
}

protocol SoundChooserViewController : UIViewController {
    var delegate: SoundChooserViewControllerDelegate? { get set }
    func presentInViewController(_ viewController: UIViewController, fromView view: UIView)
}
