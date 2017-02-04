//
//  CustomCellView.swift
//  Copier
//
//  Created by Rohan Sharma on 1/20/17.
//  Copyright © 2017 Zin. All rights reserved.
//

// Custom NSTableCellView
import Cocoa

class CustomCellView: NSTableCellView {    
    @IBOutlet weak var mainView: NSView!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var checkBoxButton: NSButton!
    @IBOutlet weak var clipView: NSClipView!
    
}
