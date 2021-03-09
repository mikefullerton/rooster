//
//  SDKCompatibility.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/24/21.
//

import Foundation

import Cocoa

// views

public typealias SDKView = NSView

public typealias SDKTextField = NSTextField
public typealias SDKTextView = NSTextView

public typealias SDKImage = NSImage
public typealias SDKImageView = NSImageView

public typealias SDKSlider = NSSlider

public typealias SDKCollectionViewItem = NSCollectionViewItem
public typealias SDKCollectionView = NSCollectionView

// view controllers

public typealias SDKViewController = NSViewController

public typealias SDKSegmentedControl = NSSegmentedControl

public typealias SDKButton = Button
public typealias SDKSwitch = Switch

// this is just here to shut the linter up about the file_name
private enum SDKTypes_macOS {
}
