//
//  ViewController.swift
//  Copier
//
//  Created by Rohan Sharma on 1/20/17.
//  Copyright © 2017 Zin. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    // Table view where cells are added
    @IBOutlet weak var mainTableView: NSTableView!
    @IBOutlet weak var deleteSelected: NSButton!
    @IBOutlet weak var deleteAll: NSButton!
    // Just used for background coloring
    @IBOutlet weak var mainScrollView: NSScrollView!
    @IBOutlet weak var viewCountLabel: NSTextField!
    
    // Pasteboard to access system pasteboard
    let pasteBoard = NSPasteboard.general()
    // Holds pasteBoard original count
    var originalCount: Int = 0
    
    // Image settings
    let maxImageWidth = CGFloat(300)
    let maxImageHeight = CGFloat(190)
    
    // For checking if app is main window of user
    var isMain = Bool(false)
    
    // For checking if copy button was clicked
    var didCopy = Bool(false)
    
    // Source of tableView data
    var views = [NSView]()
    
    // View in which text and images are displayed dimensions
    let viewWidth = CGFloat(300)
    let viewHeight = CGFloat(190)
    
    // For getting rows that are selected with checkboxes
    var arrayOfSelectedRows = [Int]()
    
    // 200 Deep orange
    var bgNSColor = NSColor(red: 1, green: 0.6706, blue: 0.5686, alpha: 1.0)
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Not allowing users to select rows because it would look really bad aesthetically
        mainTableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.none
        mainTableView.backgroundColor = bgNSColor
        
        mainScrollView.backgroundColor = bgNSColor
        
        // Getting original count in Mac clipboard
        originalCount = pasteBoard.changeCount
        
        deleteSelected.title = "Delete Selected (\(arrayOfSelectedRows.count))"
        viewCountLabel.stringValue = "Items: \(views.count)"
        
        // Making clipboardChanged() run forever
        _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(ViewController.clipboardChanged), userInfo: nil, repeats: true)
    }
    
    // Seeing if something was copied into Mac clipboard
    func clipboardChanged() {
        let currentCount = pasteBoard.changeCount
        // Checking if app is user's main window
        if(self.view.window?.isMainWindow)!{
            isMain = true
        } else {
            isMain = false
        }
        
        // Checking if user copied item from the app
        if(didCopy){
            originalCount = currentCount
            didCopy = false
        }
        
        var newPasteBoardString = String("")
        
        // If clipboard changed
        if(originalCount != currentCount && !isMain){

            // Getting
            let urlType: [Any] = [NSURL.self]
            if(pasteBoard.canReadObject(forClasses: urlType as! [AnyClass], options: nil)){
                let pboardURL: [Any] = pasteBoard.readObjects(forClasses: urlType as! [AnyClass], options: nil)!
                
                // If it is a path to a file on computer
                if(!pboardURL.isEmpty && pboardURL.count == 1) {
                    let fileURL = pboardURL[0] as! NSURL
                    
                    if(fileURL.isFileURL){
                        let str = NSMutableAttributedString(string: "\(fileURL)")
                        let range = NSRange(location: 0, length: str.length)
                        
                        str.addAttribute(NSLinkAttributeName, value: fileURL, range: range)
                        let string = fileURL.absoluteString
                        addTextView(text: string!)
                        
                    } else {
                        // Most likely an image copied from internet
                        newPasteBoardString = pasteBoard.string(forType: NSPasteboardTypeString)
                        if(newPasteBoardString != nil) {
                            // If image
                            let tempImage = NSImage(pasteboard: pasteBoard)
                            if(tempImage != nil){
                                addImageView(theImage: tempImage!)
                                
                            } else {
                                // If text
                                addTextView(text: newPasteBoardString!)
                            }
                        }
                    }
                }
                // Checking for image/text from URL
            } else {
                // FOR ATTRIBUTED STRINGS
                //                let attrStrType: [Any] = [NSAttributedString.self]
                //                let pboardAttrStr: [Any] = pasteBoard.readObjects(forClasses: attrStrType as! [AnyClass], options: nil)!
                //
                //                let attrString = pboardAttrStr[0] as! NSAttributedString
                //                temp(url: attrString)
                newPasteBoardString = pasteBoard.string(forType: NSPasteboardTypeString)
                if(newPasteBoardString != nil) {
                    // If image
                    let tempImage = NSImage(pasteboard: pasteBoard)
                    if(tempImage != nil){
                        addImageView(theImage: tempImage!)
                    
                    } else {
                        // If text
                        addTextView(text: newPasteBoardString!)
                    }
                }
            }
            
            // Updating original count to current count
            originalCount = currentCount
            
            deleteSelected.title = "Delete Selected (\(arrayOfSelectedRows.count))"
            viewCountLabel.stringValue = "Items: \(views.count)"
            
            if(views.count > 0){
                deleteAll.isEnabled = true
            }
            
            mainTableView.reloadData()
            mainTableView.scrollToEndOfDocument(nil)
        }
    }
    
    // Making an imageView with the user's copied image
    func addImageView(theImage: NSImage) {
        var tempImageView = NSImageView()
        
        let newImage = resizeImage(image: theImage)
        let theImageWidth = CGFloat(newImage.size.width)
        let theImageHeight = CGFloat(newImage.size.height)
        
        tempImageView = NSImageView(frame: NSMakeRect(0, 0, theImageWidth, theImageHeight))
        
        tempImageView.image = newImage
        views.append(tempImageView)
    }
    
    // Shrinking image to 300 x 190 if it is greater than 300 x 190
    func resizeImage(image: NSImage) -> NSImage {
        let currImageWidth = image.size.width
        let currImageHeight = image.size.height
        // Keeping original size if image is not too large
        var destSize = NSMakeSize(CGFloat(currImageWidth), CGFloat(currImageHeight))
        
        // If both width and height of image is larger than 300 x 190 respectively
        if(currImageWidth > maxImageWidth && currImageHeight > maxImageHeight){
            destSize = NSMakeSize(CGFloat(maxImageWidth), CGFloat(maxImageHeight))
            
            // If only the width is larger
        } else if(currImageWidth > maxImageWidth){
            destSize = NSMakeSize(CGFloat(maxImageWidth), CGFloat(currImageHeight))
            
            // If only the height is larger
        } else if(currImageHeight > maxImageHeight){
            destSize = NSMakeSize(CGFloat(currImageWidth), CGFloat(maxImageHeight))
        }
        
        // Making the new image
        let newImage = NSImage(size: destSize)
        newImage.lockFocus()
        image.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height), from: NSMakeRect(0, 0, currImageWidth, currImageHeight), operation: NSCompositingOperation.sourceOver, fraction: CGFloat(1))
        newImage.unlockFocus()
        newImage.size = destSize
        
        return NSImage(data: newImage.tiffRepresentation!)!
    }
    
    // Adding textView of normal string to mainView
    func addTextView(text: String){
        mainTableView.beginUpdates()
        
        let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: viewWidth, height: 14))
        textView.isVerticallyResizable = true
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = bgNSColor
        textView.append(text)
        
        views.append(textView)
        
        mainTableView.endUpdates()
    }
    
    // Adding selected row number to arrayOfSelectedRows
    @IBAction func rowSelected(_ sender: NSButton) {
        let row = mainTableView.row(for: sender)
        
        if(sender.state == NSOnState){
            arrayOfSelectedRows.append(row)
            
        } else {
            let position = arrayOfSelectedRows.index(of: row)
            arrayOfSelectedRows.remove(at: position!)
        }
        
        if(arrayOfSelectedRows.count > 0){
            deleteSelected.isEnabled = true
        } else {
            deleteSelected.isEnabled = false
        }
        
        deleteSelected.title = "Delete Selected (\(arrayOfSelectedRows.count))"
    }
    
    // Deleting selected rows
    @IBAction func deleteSelected(_ sender: NSButton) {
        // Sorting array in ascending order
        arrayOfSelectedRows.sort()
        // Looping the array backwards because the highest position gets deleted first
        // Doesn't matter what order you delete the rows in, as long as you delete all the selcted rows
        for index in stride(from: arrayOfSelectedRows.count - 1, through: 0, by: -1) {
            let pos = arrayOfSelectedRows[index]
            
            // Setting the checkButton.state to offState because it saved its state somewhere in memory, needed to reset it so new cells can be added with the button in the off state
            let customCell = mainTableView.view(atColumn: 0, row: pos, makeIfNecessary: true) as! CustomCellView
            customCell.checkBoxButton.state = NSOffState
            customCell.mainView.subviews.removeAll()
            
            // Removing the view from the views array so table can be updated
            views.remove(at: pos)
        }
        
        let indexSet = IndexSet(arrayOfSelectedRows)
        mainTableView.removeRows(at: indexSet, withAnimation: .effectFade)
        
        deleteSelected.isEnabled = false
        
        if(views.count > 0){
            deleteAll.isEnabled = true
        } else {
            deleteAll.isEnabled = false
        }
        
        arrayOfSelectedRows.removeAll()
        
        deleteSelected.title = "Delete Selected (\(arrayOfSelectedRows.count))"
        viewCountLabel.stringValue = "Items: \(views.count)"
        
        mainTableView.reloadData()
    }
    
    // Deleting all views
    @IBAction func deleteAll(_ sender: NSButton) {
        for i in 0...views.count - 1 {
            let customCell = mainTableView.view(atColumn: 0, row: i, makeIfNecessary: true) as! CustomCellView
            customCell.checkBoxButton.state = NSOffState
            customCell.mainView.subviews.removeAll()
        }
        
        views.removeAll()
        arrayOfSelectedRows.removeAll()
        
        deleteSelected.isEnabled = false
        deleteAll.isEnabled = false
        
        mainTableView.reloadData()
        
        deleteSelected.title = "Delete Selected (\(arrayOfSelectedRows.count))"
        viewCountLabel.stringValue = "Items: \(views.count)"
    }
    
    // Allowing user to copy data from app to pasteboard with one click
    @IBAction func itemCopied(_ sender: NSButton) {
        copiedItemAlert()
        
        let row = mainTableView.row(for: sender)
        let customCell = mainTableView.view(atColumn: 0, row: row, makeIfNecessary: false) as! CustomCellView
        let subView = customCell.mainView.subviews
        
        pasteBoard.clearContents()
        
        // Checking if it's a textView
        if (subView.description.contains("NSTextView")) {
            // Getting textView because its the only element in the subviews of mainView
            let tempTextView = subView[0] as! NSTextView
            let stringFromTextView = tempTextView.string
            
            let url = NSURL(string: stringFromTextView!)
            
            // Allows copying files to NSPasteboard
            if(url != nil && url!.isFileURL) {
                let fileList: [Any] = [url!.path!]
                //              Making type of pasteboard filenames to add files to it
                pasteBoard.declareTypes([NSFilenamesPboardType], owner: nil)
                pasteBoard.setPropertyList(fileList, forType: NSFilenamesPboardType)
                
            } else {
                // Making type of pasteBoard string so I can write a string to it
                pasteBoard.declareTypes([NSPasteboardTypeString], owner: nil)
                pasteBoard.setString(stringFromTextView!, forType: NSPasteboardTypeString)
            }
            
            // Checking if it's an NSImageView
        } else if(subView.description.contains("NSImageView")){
            let tempImageView = subView[0] as! NSImageView
            let imageFromImageView = tempImageView.image
            // Can't write images to pasteBoard so need to convert it to data
            let imageData: Data? = imageFromImageView?.tiffRepresentation
            
            // Making type of pasteBoard PNG so I can write a PNG to it
            pasteBoard.declareTypes([NSPasteboardTypePNG], owner: nil)
            pasteBoard.setData(imageData, forType: NSPasteboardTypePNG)
        }
        
        didCopy = true
    }
    
    func copiedItemAlert() {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = "Copied item!"
        myPopup.alertStyle = .informational
        myPopup.accessoryView?.frame.size.width = 50
        myPopup.accessoryView?.frame.size.height = 50
        myPopup.runModal()
    }
    
    // Table function that creates the view
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let result: CustomCellView = tableView.make(withIdentifier: tableColumn!.identifier, owner: self) as! CustomCellView
        
        let view = views[row]
        let subViewHeight = view.frame.size.height
        let subViewWidth = view.frame.size.width
        
        var centerX = CGFloat()
        var centerY = CGFloat()
        
        result.mainView.window?.backgroundColor = bgNSColor
        result.scrollView.backgroundColor = bgNSColor
        result.clipView.backgroundColor = bgNSColor
        
        // Updating view dimensions to fit dynamic textViews
        if(view.description.contains("NSTextView")) {
            if(subViewHeight < viewHeight){
                centerY = (viewHeight - subViewHeight) / 2
                
                // Doing this check so textView does not get recentered multiple times
                if(view.frame.minY != centerY) {
                    view.setFrameOrigin(NSPoint(x: 0, y: centerY))
                    result.scrollView.setFrameOrigin(NSPoint(x: 0, y: centerY))
                    result.mainView.setFrameOrigin(NSPoint(x: 0, y: centerY))
                }
            }
            
            // Updating view dimensions to fit dynamic textViews if they are larger than the viewHeight
            if(subViewHeight > viewHeight) {
                result.mainView.frame.size.height = subViewHeight
                result.scrollView.frame.size.height = subViewHeight
            }
            
        } else if(view.description.contains("NSImageView")) {
            centerX = (viewWidth - subViewWidth) / 2
            centerY = (viewHeight - subViewHeight) / 2
            if(subViewHeight < viewHeight && subViewWidth < viewWidth) {
                view.setFrameOrigin(NSPoint(x: centerX, y: centerY))
                result.scrollView.setFrameOrigin(NSPoint(x: centerX, y: centerY))
                result.mainView.setFrameOrigin(NSPoint(x: centerX, y: centerY))
                
            } else if(subViewWidth < viewWidth) {
                view.setFrameOrigin(NSPoint(x: centerX, y: 0))
                result.scrollView.setFrameOrigin(NSPoint(x: centerX, y: 0))
                result.mainView.setFrameOrigin(NSPoint(x: centerX, y: 0))
                
            } else if(subViewHeight < viewHeight) {
                view.setFrameOrigin(NSPoint(x: 0, y: centerY))
                result.scrollView.setFrameOrigin(NSPoint(x: 0, y: centerY))
                result.mainView.setFrameOrigin(NSPoint(x: 0, y: centerY))
            }
        }
        
        result.mainView.addSubview(views[row])
        
        return result
    }
    
    // Sets number of initial rows in tableView
    func numberOfRows(in tableView: NSTableView) -> Int {
        return views.count
    }    
}

// Adding an append function to textView functionality
extension NSTextView {
    // Normal string
    func append(_ string: String) {
        self.textStorage?.append(NSAttributedString(string: string))
        // Scrolls to end of document if it is out of view
        // Need to do this otherwise NSTextView won't resize properly
        self.scrollToEndOfDocument(nil)
    }
    
    // Attributed String
    // Made one for attributed string because NSTextView doesn't resize properly
    // for attributed strings
    // For proper resize, you need to call the self.scrollToEndOfDocument(nil)
    func appendAttr(_ string: NSAttributedString){
        self.textStorage?.append(string)
        // Scrolls to end of document if it is out of view
        self.scrollToEndOfDocument(nil)
    }
    
    func clearText(){
        self.textStorage?.mutableString.setString("")
        // Scrolls to end of document if it is out of view
        self.scrollToEndOfDocument(nil)
    }
}

// Adding extensions to NSImage to add checking for PNGs and JPEGs
extension NSImage {
    var imagePNGRepresentation: Data {
        return (NSBitmapImageRep(data: tiffRepresentation!)!.representation(using: .PNG, properties: [:])! as NSData) as Data
    }
    var imageJPGRepresentation: Data {
        return (NSBitmapImageRep(data: tiffRepresentation!)!.representation(using: .JPEG, properties: [:])! as NSData) as Data
    }
}


public extension NSURL {
    
    public var isImage: Bool {
        return UTI.map{ UTTypeConformsTo($0 as CFString, kUTTypeImage) } ?? false
    }
    
    public var UTI: String? {
        var value: AnyObject?
        let _ = try? getResourceValue(&value, forKey: URLResourceKey.typeIdentifierKey)
        return value as? String
    }
}
