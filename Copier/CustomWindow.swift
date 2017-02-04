//
//  CustomWindow.swift
//  Copier
//
//  Created by Rohan Sharma on 1/23/17.
//  Copyright © 2017 Zin. All rights reserved.
//

// Custom window class
import Cocoa

class CustomWindow: NSWindow, NSApplicationDelegate, NSWindowDelegate {
    // 800 Grey
    var bgNSColor = NSColor(red: 0.2588, green: 0.2588, blue: 0.2588, alpha: 1.0)
    
    override init(contentRect: NSRect, styleMask style: NSWindowStyleMask, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: ([NSWindowStyleMask.titled, NSWindowStyleMask.resizable,NSWindowStyleMask.miniaturizable, NSWindowStyleMask.closable, NSWindowStyleMask.fullSizeContentView]), backing: bufferingType, defer: false)
        
        self.contentView!.wantsLayer = true;/*this can and is set in the view*/
        self.isMovableByWindowBackground = true
        self.backgroundColor = bgNSColor.withAlphaComponent(0.9)
        self.isOpaque = false
        self.makeKeyAndOrderFront(nil)//moves the window to the front
        self.makeMain()//makes it the apps main menu?
        self.titlebarAppearsTransparent = true
        self.center()
        
        self.delegate = self
        
        self.title = ""/*Sets the title of the window*/
        
        let visualEffectView = NSVisualEffectView(frame: NSMakeRect(0, 0, contentRect.width, contentRect.height))
        visualEffectView.material = NSVisualEffectMaterial.appearanceBased//Dark,MediumLight,PopOver,UltraDark,AppearanceBased,Titlebar,Menu
        visualEffectView.blendingMode = NSVisualEffectBlendingMode.behindWindow
        visualEffectView.state = NSVisualEffectState.active
        
        self.contentView?.addSubview(visualEffectView)
    }
}
