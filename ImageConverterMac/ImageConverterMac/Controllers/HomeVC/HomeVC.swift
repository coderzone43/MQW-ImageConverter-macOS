//
//  HomeVC.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 05/08/2025.
//

import Cocoa

protocol DelegateHomeCollectionSelectable: AnyObject {
    func seleclableCollectionView()
}

class HomeVC: NSViewController {
    
    //MARK: Outlets
    @IBOutlet weak var tfSearch: NSTextField!
    @IBOutlet weak var collectionHome: NSCollectionView!
    @IBOutlet weak var imgSearch: NSImageView!
    
    @IBOutlet weak var viewMain: NSBox!
    @IBOutlet weak var viewHistory: NSBox!
    
    @IBOutlet weak var tfSearchHistory: NSTextField!
    @IBOutlet weak var imgSearchHistory: NSImageView!
    
    @IBOutlet weak var viewEmtpyMsg: NSView!
    @IBOutlet weak var collectionHistory: NSCollectionView!
    
    @IBOutlet weak var btnAll: NSButton!
    @IBOutlet weak var btnJPG: NSButton!
    @IBOutlet weak var btnPNG: NSButton!
    @IBOutlet weak var btnWebp: NSButton!
    @IBOutlet weak var btnPDF: NSButton!
    @IBOutlet weak var btnTools: NSButton!
    @IBOutlet weak var btnOffer: NSButton!
    
    var arrHome = homeDecodeJSON() ?? []
    var arrSearch: [homeObj] = []
    var isSearching = false
    var isHistorySearching = false
    var sideMenuIndex = 0
    
    var history: [FileInfo] = HistoryManager.shared.getDownloadHistory()
    var allHistory: [FileInfo] = HistoryManager.shared.getDownloadHistory()
    var selectedConversionType: FileTypes? = nil
    
    var selectedIndexPath: IndexPath?
    
    //MARK: View Life Cycle Start here...
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupView()
    }
    
    override func viewWillAppear() {
        //collectionHome.isSelectable = true
    }
    
    //MARK: Setup View
    func setupView() {
        checkRatingAndPro()
        tfSearch.focusRingType = .none
        tfSearchHistory.focusRingType = .none
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidChange(_:)),
                                               name: NSControl.textDidChangeNotification,
                                               object: tfSearch)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidChangeHistory(_:)),
                                               name: NSControl.textDidChangeNotification,
                                               object: tfSearchHistory)
        
        viewMain.isHidden = false
        viewHistory.isHidden = true
        
        setupCollectionView()
        
        initialButtonsState()
    }
    
    //MARK: Utility Methods
    
    func initialButtonsState(){
        btnAll.contentTintColor = .appWhiteOnly
        btnAll.backgroundColor = .primary1
        
        btnJPG.contentTintColor = .black6
        btnJPG.backgroundColor = .white2
        
        btnPNG.contentTintColor = .black6
        btnPNG.backgroundColor = .white2
        
        btnWebp.contentTintColor = .black6
        btnWebp.backgroundColor = .white2
        
        btnPDF.contentTintColor = .black6
        btnPDF.backgroundColor = .white2
        
        btnTools.contentTintColor = .black6
        btnTools.backgroundColor = .white2
    }
    
    func initialHistoryState(){
        isHistorySearching = false
        tfSearchHistory.stringValue = ""
        imgSearchHistory.image = NSImage(resource: ImageResource.imgSearch)
        
        history = allHistory
        collectionHistory.reloadData()
        
        if history.count == 0 {
            viewEmtpyMsg.isHidden = false
            collectionHistory.isHidden = true
        }else{
            viewEmtpyMsg.isHidden = true
            collectionHistory.isHidden = false
        }
    }
    
    func checkRatingAndPro(){
        if isPremiumUser(){
            btnOffer.isHidden = true
        }else{
            btnOffer.isHidden = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if Utility.isNetworkAvailable() {
                if Utility.incrementLaunchCountAndCheck() {
                    if ud.bool(forKey: strRating) == true{
                        if !isPremiumUser(){
                            //Show Pro Screen
                            let vc = ProPaymentVC()
                            self.presentAsSheet(vc)
                        }
                    }else{
                        //Show Rating Screen
                        let vc = RatingVC()
                        self.presentAsSheet(vc)
                    }
                }else{
                    if !isPremiumUser(){
                        //Show Pro Screen
                        let vc = ProPaymentVC()
                        self.presentAsSheet(vc)
                    }
                }
            }else{
                DispatchQueue.main.async {[weak self] in
                    guard let self else {return}
                    guard let window = self.view.window else {return}
                    Utility.dialogWithMsg(message: alertMsgNoInternet, window: window)
                }
            }
        }
    }
    
    func setupCollectionView() {
        //Main Collection View
        collectionHome.register(
            NSNib(nibNamed: "HomeHeaderCVC", bundle: nil),
            forSupplementaryViewOfKind: NSCollectionView.elementKindSectionHeader,
            withIdentifier: NSUserInterfaceItemIdentifier("HomeHeaderCVC")
        )
        
        let layout = NSCollectionViewFlowLayout()
        layout.itemSize = NSSize(width: 135, height: 135)
        layout.sectionInset = NSEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
        layout.minimumLineSpacing = 15
        layout.headerReferenceSize = NSSize(width: 100, height: 50) // ❗ Must be non-zero
        collectionHome.collectionViewLayout = layout
        
        collectionHome.hideVerticalScroller()
        collectionHome.reloadData()
        
        //History Collection View
        collectionHistory.register(
            NSNib(nibNamed: "HistoryCVC", bundle: nil),
            forSupplementaryViewOfKind: NSCollectionView.elementKindSectionHeader,
            withIdentifier: NSUserInterfaceItemIdentifier("HistoryCVC")
        )
        
        let layoutHistory = NSCollectionViewFlowLayout()
        layoutHistory.itemSize = NSSize(width: 160, height: 220)
        layoutHistory.sectionInset = NSEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
        layoutHistory.minimumLineSpacing = 15
        //layoutHistory.headerReferenceSize = NSSize(width: 100, height: 50) // ❗ Must be non-zero
        collectionHistory.collectionViewLayout = layoutHistory
        
        collectionHistory.hideVerticalScroller()
        collectionHistory.reloadData()
    }
    
    //MARK: Button Action
    @IBAction func btnAllAction(_ sender: Any) {
        initialButtonsState()
        initialHistoryState()
        selectedConversionType = nil // No filter, show all types
        filterHistoryByType(nil)
    }
    @IBAction func btnJPGAction(_ sender: Any) {
        initialHistoryState()
        
        btnAll.contentTintColor = .black6
        btnAll.backgroundColor = .white2
        
        btnJPG.contentTintColor = .appWhiteOnly
        btnJPG.backgroundColor = .primary1
        
        btnPNG.contentTintColor = .black6
        btnPNG.backgroundColor = .white2
        
        btnWebp.contentTintColor = .black6
        btnWebp.backgroundColor = .white2
        
        btnPDF.contentTintColor = .black6
        btnPDF.backgroundColor = .white2
        
        btnTools.contentTintColor = .black6
        btnTools.backgroundColor = .white2
        
        selectedConversionType = .JPG // No filter, show all types
        filterHistoryByType(.JPG)
    }
    @IBAction func btnPNGAction(_ sender: Any) {
        initialHistoryState()
        
        btnAll.contentTintColor = .black6
        btnAll.backgroundColor = .white2
        
        btnJPG.contentTintColor = .black6
        btnJPG.backgroundColor = .white2
        
        btnPNG.contentTintColor = .appWhiteOnly
        btnPNG.backgroundColor = .primary1
        
        btnWebp.contentTintColor = .black6
        btnWebp.backgroundColor = .white2
        
        btnPDF.contentTintColor = .black6
        btnPDF.backgroundColor = .white2
        
        btnTools.contentTintColor = .black6
        btnTools.backgroundColor = .white2
        
        selectedConversionType = .PNG // No filter, show all types
        filterHistoryByType(.PNG)
    }
    @IBAction func btnWebpAction(_ sender: Any) {
        initialHistoryState()
        
        btnAll.contentTintColor = .black6
        btnAll.backgroundColor = .white2
        
        btnJPG.contentTintColor = .black6
        btnJPG.backgroundColor = .white2
        
        btnPNG.contentTintColor = .black6
        btnPNG.backgroundColor = .white2
        
        btnWebp.contentTintColor = .appWhiteOnly
        btnWebp.backgroundColor = .primary1
        
        btnPDF.contentTintColor = .black6
        btnPDF.backgroundColor = .white2
        
        btnTools.contentTintColor = .black6
        btnTools.backgroundColor = .white2
        
        selectedConversionType = .Webp // No filter, show all types
        filterHistoryByType(.Webp)
    }
    @IBAction func btnPDFAction(_ sender: Any) {
        initialHistoryState()
        
        btnAll.contentTintColor = .black6
        btnAll.backgroundColor = .white2
        
        btnJPG.contentTintColor = .black6
        btnJPG.backgroundColor = .white2
        
        btnPNG.contentTintColor = .black6
        btnPNG.backgroundColor = .white2
        
        btnWebp.contentTintColor = .black6
        btnWebp.backgroundColor = .white2
        
        btnPDF.contentTintColor = .appWhiteOnly
        btnPDF.backgroundColor = .primary1
        
        btnTools.contentTintColor = .black6
        btnTools.backgroundColor = .white2
        
        selectedConversionType = .PDF // No filter, show all types
        filterHistoryByType(.PDF)
    }
    @IBAction func btnToolsAction(_ sender: Any) {
        initialHistoryState()
        
        btnAll.contentTintColor = .black6
        btnAll.backgroundColor = .white2
        
        btnJPG.contentTintColor = .black6
        btnJPG.backgroundColor = .white2
        
        btnPNG.contentTintColor = .black6
        btnPNG.backgroundColor = .white2
        
        btnWebp.contentTintColor = .black6
        btnWebp.backgroundColor = .white2
        
        btnPDF.contentTintColor = .black6
        btnPDF.backgroundColor = .white2
        
        btnTools.contentTintColor = .appWhiteOnly
        btnTools.backgroundColor = .primary1
        
        selectedConversionType = .tools // No filter, show all types
        filterHistoryByType(.tools)
    }
    @IBAction func btnOfferAction(_ sender: Any) {
    }
    
    //MARK: API Methods
    
    //MARK: DELEGATE METHODS
    
    //MARK: TableView
    
    //MARK: CollectionView
    
    //MARK: Segment Control
    
    //MARK: Alert View
    
    //MARK: TextField
    
    @objc func textDidChange(_ notification: Notification) {
        if let tf = notification.object as? NSTextField {
            //print("Text updated: \(tf.stringValue)")
            let query = tf.stringValue.lowercased()
            if query.isEmpty {
                imgSearch.image = NSImage(resource: ImageResource.imgSearch)
                isSearching = false
                if sideMenuIndex == 0 {
                    arrHome = homeDecodeJSON() ?? []
                }else{
                    arrHome = homeDecodeJSON() ?? []
                    let obj = arrHome.last!
                    arrHome.removeAll()
                    arrHome.append(obj)
                }
            } else {
                imgSearch.image = NSImage(resource: ImageResource.imgSearchSelected)
                isSearching = true
                
                arrSearch = arrHome.compactMap { section in
                    let filteredItems = section.arr.filter { $0.title.lowercased().contains(query) }
                    if !filteredItems.isEmpty {
                        return homeObj(title: section.title, conversionType: section.conversionType, arr: filteredItems)
                    }
                    return nil
                }
            }
            collectionHome.reloadData()
        }
    }
    
    @objc func textDidChangeHistory(_ notification: Notification) {
        if let tf = notification.object as? NSTextField {
            //print("Text updated: \(tf.stringValue)")
            let query = tf.stringValue.lowercased()
            
            // Filter history based on the query and selected conversion type
            history = allHistory
            
            if query.isEmpty {
                imgSearchHistory.image = NSImage(resource: ImageResource.imgSearch)
                isHistorySearching = false
                filterHistoryByType(selectedConversionType)
            } else {
                imgSearchHistory.image = NSImage(resource: ImageResource.imgSearchSelected)
                isHistorySearching = true
                filterHistory(query: query)
            }
        }
    }
    
    func filterHistoryByType(_ type: FileTypes?) {
        if let selectedType = type {
            // Filter the history based on selected file type
            let filteredHistory = history.filter { fileInfo in
                return fileInfo.conversionType == selectedType
            }
            
            // Update the UI: Reload the collection view with the filtered history
            history = filteredHistory
            collectionHistory.reloadData()
        } else {
            // If 'All' is selected, show all files
            history = allHistory
            collectionHistory.reloadData()
        }
        
        if history.count == 0 {
            viewEmtpyMsg.isHidden = false
            collectionHistory.isHidden = true
        }else{
            viewEmtpyMsg.isHidden = true
            collectionHistory.isHidden = false
        }
    }
    
    func filterHistory(query: String) {
        // Filter history based on file name and conversion type
        let filteredHistory = history.filter { fileInfo in
            let matchesQuery = fileInfo.name.lowercased().contains(query)
            
            // Check if the conversion type matches if one is selected
            let matchesConversionType: Bool
            if let selectedConversion = selectedConversionType {
                matchesConversionType = fileInfo.conversionType == selectedConversion
            } else {
                // If no conversion type is selected, match all types
                matchesConversionType = true
            }
            
            return matchesQuery && matchesConversionType
        }
        
        // Reload collection view with filtered history
        self.history = filteredHistory
        collectionHistory.reloadData()
        
        if history.count == 0 {
            viewEmtpyMsg.isHidden = false
            collectionHistory.isHidden = true
        }else{
            viewEmtpyMsg.isHidden = true
            collectionHistory.isHidden = false
        }
    }
    
}
extension HomeVC: NSCollectionViewDelegate,NSCollectionViewDataSource,NSCollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        if collectionView == collectionHome{
            let dataSource = isSearching ? arrSearch : arrHome
            return dataSource.count
        }else{
            return 1
        }
    }
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionHome{
            let dataSource = isSearching ? arrSearch : arrHome
            return dataSource[section].arr.count
        }else{
            return history.count
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        if collectionView == collectionHome{
            let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("HomeCVC"), for: indexPath) as! HomeCVC
            let dataSource = isSearching ? arrSearch : arrHome
            cell.lblTitle.stringValue = dataSource[indexPath.section].arr[indexPath.item].title
            cell.imgItem.image = NSImage(named: dataSource[indexPath.section].arr[indexPath.item].img)
            return cell
        }else{
            let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("HistoryCVC"), for: indexPath) as! HistoryCVC
            
            cell.lblSize.stringValue = HistoryManager.shared.getFileSize(bytes: history[indexPath.item].size)
            cell.lblFileType.stringValue = history[indexPath.item].fileExtension.uppercased()
            
            if let url = URL(string: "file://\(history[indexPath.item].path)"){
                cell.lblFilename.stringValue = url.lastPathComponent
                if history[indexPath.item].fileExtension == "zip"{
                    cell.imgFile.image = NSImage(resource: ImageResource.imgHistoryZip)
                }else if history[indexPath.item].fileExtension == "txt"{
                    cell.imgFile.image = NSImage(resource: ImageResource.imgHistoryTxt)
                }else{
                    let result = ThumbnailGenerator.generateThumbnailWithName(for: url, size: NSSize(width: 160, height: 160))
                    cell.imgFile.image = result.image
                }
            }
            
            cell.actionOptionMenu = { [weak self] in
                self?.showOptionsMenu(for: indexPath)
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let index = indexPaths.first else{ return }
        //collectionHome.isSelectable = false
        if collectionView == collectionHome{
            collectionView.deselectItems(at: indexPaths)
            let dataSource = isSearching ? arrSearch : arrHome
            let vc = UploadFileVC()
            vc.convertedFileType = dataSource[index.section].conversionType
            vc.browsedFileType = dataSource[index.section].arr[index.item].type
            if dataSource[index.section].conversionType == .tools {
                vc.isTool = true
            }
            vc.fileURL = { urls in
                if dataSource[index.section].conversionType == .tools {
                    if dataSource[index.section].arr[index.item].type == .rotate {
                        let vc = ImageRotateVC(nibName: "ImageRotateVC", bundle: nil)
                        vc.selectedImageURL = urls.first
                        vc.delegate = self
                        self.addChildViewControllerWithAnimation(vc, to: splitMainViewController.view)
                    }
                    if dataSource[index.section].arr[index.item].type == .zip {
                        let vc = ConvertZipVC(nibName: "ConvertZipVC", bundle: nil)
                        vc.arrFiles = urls
                        vc.delegate = self
                        self.addChildViewControllerWithAnimation(vc, to: splitMainViewController.view)
                    }
                    if dataSource[index.section].arr[index.item].type == .extractText {
                        let vc = ExtractTextVC(nibName: "ExtractTextVC", bundle: nil)
                        vc.arrFiles = urls
                        vc.delegate = self
                        self.addChildViewControllerWithAnimation(vc, to: splitMainViewController.view)
                    }
                    if dataSource[index.section].arr[index.item].type == .compress {
                        let vc = CompressVC(nibName: "CompressVC", bundle: nil)
                        vc.arrFiles = urls
                        vc.delegate = self
                        self.addChildViewControllerWithAnimation(vc, to: splitMainViewController.view)
                    }
                    if dataSource[index.section].arr[index.item].type == .crop {
                        let vc = ImageCropVC(nibName: "ImageCropVC", bundle: nil)
                        vc.selectedImageURL = urls.first
                        vc.delegate = self
                        self.addChildViewControllerWithAnimation(vc, to: splitMainViewController.view)
                    }
                    if dataSource[index.section].arr[index.item].type == .resize {
                        let vc = ImageResizeVC(nibName: "ImageResizeVC", bundle: nil)
                        vc.selectedImageURL = urls.first
                        vc.delegate = self
                        self.addChildViewControllerWithAnimation(vc, to: splitMainViewController.view)
                    }
                    if dataSource[index.section].arr[index.item].type == .watermark {
                        let vc = WatermarkVC(nibName: "WatermarkVC", bundle: nil)
                        vc.selectedImageURL = urls.first
                        vc.delegate = self
                        self.addChildViewControllerWithAnimation(vc, to: splitMainViewController.view)
                    }
                }else{
                    let vc = UploadedImgsVC(nibName: "UploadedImgsVC", bundle: nil)
                    vc.strTitle = dataSource[index.section].arr[index.item].title
                    vc.convertedFileType = dataSource[index.section].conversionType
                    vc.browsedFileType = dataSource[index.section].arr[index.item].type
                    vc.arrFiles = urls
                    vc.delegate = self
                    self.addChildViewControllerWithAnimation(vc, to: splitMainViewController.view)
                }
            }
            self.presentAsSheet(vc)
        } else {
            collectionView.deselectItems(at: indexPaths)
            
            if history[index.item].fileExtension == "zip"{
                //Do Nothing
            }else{
                //Show preview
                if let url = URL(string: "file://\(history[index.item].path)"){
                    QuickLookPreview.shared.preview(file: url)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> NSView {
        if kind == NSCollectionView.elementKindSectionHeader {
            //print("Setting title for header in section \(indexPath.section)")
            let headerItem = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: NSUserInterfaceItemIdentifier("HomeHeaderCVC"), for: indexPath) as! HomeHeaderCVC
            let dataSource = isSearching ? arrSearch : arrHome
            headerItem.configure(with: dataSource[indexPath.section].title)
            if indexPath.section != 0 {
                headerItem.setLabelPosition(top: false)
            }
            return headerItem
        }
        return NSView()
    }
}
extension HomeVC:Shareable{
    func showOptionsMenu(for indexPath: IndexPath) {
        selectedIndexPath = indexPath
        let menu = NSMenu()
        
        // Download option
        let downloadItem = NSMenuItem(title: "Download", action: #selector(downloadFile(_:)), keyEquivalent: "")
        downloadItem.isEnabled = true
        downloadItem.target = self
        menu.addItem(downloadItem)
        
        // Rename option
        let renameItem = NSMenuItem(title: "Rename", action: #selector(renameFile(_:)), keyEquivalent: "")
        renameItem.isEnabled = true
        renameItem.target = self
        menu.addItem(renameItem)
        
        // Share option
        let shareItem = NSMenuItem(title: "Share", action: #selector(shareFile(_:)), keyEquivalent: "")
        shareItem.isEnabled = true  // Enable if sharing is possible
        shareItem.target = self
        menu.addItem(shareItem)
        
        // Delete option
        let deleteItem = NSMenuItem(title: "Delete", action: #selector(deleteFile(_:)), keyEquivalent: "")
        //deleteItem.textColor = .red  // Set color to red for delete
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: NSColor.red]
        let attributedTitle = NSAttributedString(string: deleteItem.title, attributes: attributes)
        deleteItem.attributedTitle = attributedTitle
        deleteItem.isEnabled = true
        deleteItem.target = self
        menu.addItem(deleteItem)
        
        // Show the menu
        menu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
        
        // Store indexPath in menu items to pass data to actions
        if let downloadItem = menu.item(at: 0) {
            downloadItem.representedObject = indexPath
        }
        if let renameItem = menu.item(at: 1) {
            renameItem.representedObject = indexPath
        }
        if let shareItem = menu.item(at: 2) {
            shareItem.representedObject = indexPath
        }
        if let deleteItem = menu.item(at: 3) {
            deleteItem.representedObject = indexPath
        }
    }
    
    // Download action
    @objc func downloadFile(_ sender: NSMenuItem) {
        if let indexPath = selectedIndexPath {
            let fileInfo = history[indexPath.item]
            // Add code to download the file
            print("Downloading \(fileInfo.name)")
            HistoryManager.shared.downloadFile(at: indexPath.item)
        }
    }
    
    // Rename action
    /*@objc func renameFile(_ sender: NSMenuItem) {
        if let indexPath = selectedIndexPath {
            let fileInfo = history[indexPath.item]
            let alert = NSAlert()
            alert.messageText = "Rename \(fileInfo.name)"
            alert.informativeText = "Enter a new name for the file."
            
            let textField = NSTextField(string: fileInfo.name)
            alert.accessoryView = textField
            alert.addButton(withTitle: "Rename")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                let newName = textField.stringValue
                let sanitized = Utility.sanitizeFileName(newName)
                if sanitized == "untitled_file" {
                    // Show warning or disable saving
                    Utility.dialogWithMsg(message: "Please enter a valid name", window: self.view.window ?? NSWindow())
                    return
                }
                // Rename the file in your system and update the history
                print("Renaming \(fileInfo.name) to \(newName)")
                // Call a function to rename the file
                HistoryManager.shared.renameFile(at: indexPath.item, newName: newName)
                history = HistoryManager.shared.getDownloadHistory()
                allHistory = HistoryManager.shared.getDownloadHistory()
                
                collectionHistory.reloadData()
            }
        }
    }*/
    
    @objc func renameFile(_ sender: NSMenuItem) {
        if let indexPath = selectedIndexPath {
            let fileInfo = history[indexPath.item]
            
            let alert = NSAlert()
            alert.messageText = "Rename \(fileInfo.name)"
            alert.informativeText = "Enter a new name for the file."
            
            let textField = NSTextField(string: fileInfo.name)

            // Set a preferred width (e.g. 300) and keep default height
            textField.frame = NSRect(x: 0, y: 0, width: 300, height: 24)

            // Optionally allow horizontal stretching if needed
            textField.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                textField.widthAnchor.constraint(equalToConstant: 300)
            ])

            alert.accessoryView = textField
            alert.addButton(withTitle: "Rename")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                let newName = Utility.sanitizeFileName(textField.stringValue)
                if newName == "untitled_file" {
                    Utility.dialogWithMsg(message: "Please enter a valid name", window: self.view.window ?? NSWindow())
                    return
                }
                
                HistoryManager.shared.renameFile(historyID: fileInfo.historyID, newName: newName) { result in
                    switch result {
                    case .success:
                        DispatchQueue.main.async {
                            self.history = HistoryManager.shared.getDownloadHistory()
                            self.allHistory = HistoryManager.shared.getDownloadHistory()
                            self.filterHistoryByType(self.selectedConversionType)
                            //self.collectionHistory.reloadData()
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            Utility.dialogWithMsg(message: "Rename failed", window: self.view.window ?? NSWindow())
                        }
                    }
                }
            }
        }
    }
    
    // Share action
    @objc func shareFile(_ sender: NSMenuItem) {
        if let indexPath = selectedIndexPath {
            let fileInfo = history[indexPath.item]
            let fileURL = URL(fileURLWithPath: fileInfo.path)
            // Use NSSharingService to share the file
            if let cell = getCell(for: indexPath) {
                //                share(sender: cell.btnOption, items: [fileURL?.absoluteString as Any])
                shareItem(urlVideo: fileURL, cellView: cell)
            }
        }
    }
    func shareItem(urlVideo: URL, cellView:HistoryCVC) {
        let sharingServicePicker = NSSharingServicePicker(items: [urlVideo])
        sharingServicePicker.show(relativeTo: cellView.view.bounds, of: cellView.view, preferredEdge: .minY)
    }
    func getCell(for indexPath: IndexPath) -> HistoryCVC? {
        // Make sure that the indexPath is valid
        //        if let view = collectionHistory.
        guard indexPath.item < history.count else {
            return nil
        }
        
        // Create the cell using makeItem(for:) method
        let item = collectionHistory.item(at: indexPath) as! HistoryCVC
        
        return item
    }
    
    // Delete action
    /*@objc func deleteFile(_ sender: NSMenuItem) {
        if let indexPath = selectedIndexPath {
            let fileInfo = history[indexPath.item]
            let alert = NSAlert()
            alert.messageText = "Are you sure you want to delete \(fileInfo.name)?"
            alert.addButton(withTitle: "Delete")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                // Perform deletion logic here
                print("Deleting \(fileInfo.name)")
                // Remove the file from your app and history
                HistoryManager.shared.deleteFile(at: indexPath.item)
                
                history = HistoryManager.shared.getDownloadHistory()
                allHistory = HistoryManager.shared.getDownloadHistory()
                
                collectionHistory.reloadData()
            }
        }
    }*/
    
    @objc func deleteFile(_ sender: NSMenuItem) {
        if let indexPath = selectedIndexPath {
            let fileInfo = history[indexPath.item]
            
            let alert = NSAlert()
            alert.messageText = "Are you sure you want to delete \(fileInfo.name)?"
            alert.addButton(withTitle: "Delete")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                HistoryManager.shared.deleteFile(historyID: fileInfo.historyID) { result in
                    switch result {
                    case .success:
                        DispatchQueue.main.async {
                            self.history = HistoryManager.shared.getDownloadHistory()
                            self.allHistory = HistoryManager.shared.getDownloadHistory()
                            self.filterHistoryByType(self.selectedConversionType)
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            Utility.dialogWithMsg(message: "Delete failed", window: self.view.window ?? NSWindow())
                        }
                    }
                }
            }
        }
    }
}
extension HomeVC:SideBarControllerSelectionDelegate{
    func sideBarController(_ index: Int) {
        sideMenuIndex = index
        if index == 0 {
            arrHome = homeDecodeJSON() ?? []
            collectionHome.reloadData()
            
            isSearching = false
            tfSearch.stringValue = ""
            imgSearch.image = NSImage(resource: ImageResource.imgSearch)
            
            viewMain.isHidden = false
            viewHistory.isHidden = true
        }
        
        if index == 1 {
            arrHome = homeDecodeJSON() ?? []
            let obj = arrHome.last!
            arrHome.removeAll()
            arrHome.append(obj)
            collectionHome.reloadData()
            
            isSearching = false
            tfSearch.stringValue = ""
            imgSearch.image = NSImage(resource: ImageResource.imgSearch)
            
            viewMain.isHidden = false
            viewHistory.isHidden = true
        }
        
        if index == 2 {
            initialButtonsState()
            
            viewMain.isHidden = true
            viewHistory.isHidden = false
            
            isHistorySearching = false
            tfSearchHistory.stringValue = ""
            imgSearchHistory.image = NSImage(resource: ImageResource.imgSearch)
            
            allHistory = HistoryManager.shared.getDownloadHistory()
            history = HistoryManager.shared.getDownloadHistory()
            collectionHistory.reloadData()
            
            if history.count == 0 {
                viewEmtpyMsg.isHidden = false
                collectionHistory.isHidden = true
            }else{
                viewEmtpyMsg.isHidden = true
                collectionHistory.isHidden = false
            }
        }
    }
    
    
}
extension HomeVC : DelegateHomeCollectionSelectable{
    func seleclableCollectionView() {
        //collectionHome.isSelectable = true
    }
}
