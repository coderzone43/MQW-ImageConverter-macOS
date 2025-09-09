//
//  CompressVC.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 21/08/2025.
//

import Cocoa

class CompressVC: NSViewController {

    //MARK: Outlets
    @IBOutlet weak var collectionCompress: NSCollectionView!
    @IBOutlet weak var sliderCompress: NSSlider!
    @IBOutlet weak var lblCompressionValue: NSTextField!
    
    var arrFiles:[URL] = []
    weak var delegate: DelegateHomeCollectionSelectable?
    var images: [CompressibleImage] = []
    
    //MARK: View Life Cycle Start here...
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupView()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        DispatchQueue.main.async {
            if let window = self.view.window {
                // Hide traffic lights by removing title bar buttons
                window.standardWindowButton(.closeButton)?.isHidden = true
                window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                window.standardWindowButton(.zoomButton)?.isHidden = true
            }
        }
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        if let window = self.view.window {
            // Show the title bar buttons again
            window.standardWindowButton(.closeButton)?.isHidden = false
            window.standardWindowButton(.miniaturizeButton)?.isHidden = false
            window.standardWindowButton(.zoomButton)?.isHidden = false
        }
    }
    
    //MARK: Setup View
    func setupView() {
        collectionCompress.hideVerticalScroller()
        sliderCompress.isContinuous = true
        
        loadImages()
    }
    
    //MARK: Utility Methods
    
    func loadImages() {
        images.removeAll()
        for url in arrFiles {
            if let image = NSImage(contentsOf: url),
               let data = try? Data(contentsOf: url) {
                let item = CompressibleImage(url: url, image: image, originalData: data, compressedData: nil)
                images.append(item)
            }
        }
        //updateCompressedImages()
        collectionCompress.reloadData()
    }
    
    /*func updateCompressedImages() {
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            Utility.showHud(controller: self?.view.window?.contentViewController?.view ?? NSView())
        }
        let reductionPercent = sliderCompress.doubleValue // 0–100
        
        for i in 0..<images.count {
            let originalData = images[i].originalData
            let targetSize = Int(Double(originalData.count) * (1.0 - (reductionPercent / 100.0)))
            
            // 0% reduction → original
            if reductionPercent == 0 {
                images[i].compressedData = originalData
                continue
            }
            
            guard let tiff = images[i].image.tiffRepresentation,
                  let bitmap = NSBitmapImageRep(data: tiff) else {
                images[i].compressedData = originalData
                continue
            }
            
            var low: CGFloat = 0.0
            var high: CGFloat = 1.0
            var bestData: Data? = nil
            
            // Binary search for quality factor
            for _ in 0..<10 { // 10 iterations → accurate enough
                let mid = (low + high) / 2.0
                if let compressed = bitmap.representation(using: .jpeg,
                                                          properties: [.compressionFactor: mid]) {
                    if compressed.count > targetSize {
                        // file still too big → reduce quality
                        high = mid
                    } else {
                        // file is small enough → keep and try higher quality
                        bestData = compressed
                        low = mid
                    }
                }
            }
            
            images[i].compressedData = bestData ?? originalData
        }
        
        collectionCompress.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            Utility.hideHud()
        }
    }*/
    
    //MARK: Button Action
    @IBAction func btnBackAction(_ sender: Any) {
        delegate?.seleclableCollectionView()
        removeChildFromNavigation()
    }
    @IBAction func btnCompressImgAction(_ sender: Any) {
        if images.count > 0 {
            
            let count = Utility.getDefaultObject(forKey: strFreeHitsCount)
            print("Free count is \(count)")
            if !isPremiumUser() && Int(count)! > freeHitsIntValue{
                let vc = ProPaymentVC()
                self.presentAsSheet(vc)
                return
            }
            
            let cancelToken = CancellationToken()
            
            let loaderVC = ConversionProgressVC() //showConversionLoader()
            loaderVC.strTitle = "Compressing Images..."
            self.presentAsSheet(loaderVC)
            
            loaderVC.cancellationToken = cancelToken
            
            loaderVC.onCancel = {
                CompressionManager.shared.cancel()
            }
            
            compressAllImages(progressHandler: { progress in
                print("Progress: \(progress)%")
                loaderVC.progressBar.minValue = 0
                loaderVC.progressBar.maxValue = 100
                loaderVC.progressBar.doubleValue = Double(progress)
                loaderVC.lblPercentage.stringValue = "\(progress)%"
                //loaderVC.updateProgress(Double(progress))
                // self.customProgressBar.update(progress)
            }, completion: {
                loaderVC.dismiss(nil)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    let vc = CompressResultVC(nibName: "CompressResultVC", bundle: nil)
                    vc.arrImgs = self.images
                    self.addChildViewControllerWithAnimation(vc, to: self.view)
                }
            })
        }
    }
    @IBAction func btnAddAction(_ sender: Any) {
        let dialog = NSOpenPanel();
        dialog.title                   = "Choose a file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.allowsMultipleSelection = true;
        dialog.canChooseDirectories    = false;
        
        dialog.allowedContentTypes = [.jpeg,.svg,.png, .gif]
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.urls
            if result.count > 0 {
                for file in result {
                    arrFiles.append(file)
                }
                loadImages()
            }
        } else {
            return
        }
    }
    @IBAction func sliderCompressAction(_ sender: Any) {
        //updateCompressedImages()
        
        lblCompressionValue.stringValue = "\(Int(sliderCompress.doubleValue))%"
    }
    
    //MARK: API Methods
    
    //MARK: DELEGATE METHODS
    
    //MARK: TableView
    
    //MARK: CollectionView
    
    //MARK: Segment Control
    
    //MARK: Alert View
    
    //MARK: TextField
    
}
extension CompressVC: NSCollectionViewDelegate,NSCollectionViewDataSource,NSCollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("ConvertZipCVC"), for: indexPath) as! ConvertZipCVC
        
        cell.imgConvert.image = images[indexPath.item].image
        
        cell.actionRemove = {
            guard let window = self.view.window else{ return}
            Utility.showAlertSheet(message: "Remove File?", information: "Are you sure want to remove this file", firstButtonTitle: "OK", secondButtonTitle: "Cancel" , window: window) { delete in
                if delete{
                    print("OK Tapped")
                    self.images.remove(at: indexPath.item)
                    self.arrFiles.remove(at: indexPath.item)
                    self.collectionCompress.reloadData()
                }
            }
        }
        
        return cell
    }
}
extension CompressVC{
    func compressImage(_ item: CompressibleImage, sliderValue: Double) -> CompressibleImage {
        var newItem = item
        
        // Map slider (0–100) → compressionFactor (1.0–0.0)
        let compressionFactor = max(0.0, min(1.0, 1.0 - (sliderValue / 100.0)))
        
        guard let tiff = item.image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let compressed = bitmap.representation(using: .jpeg,
                                                     properties: [.compressionFactor: compressionFactor]) else {
            newItem.compressedData = item.originalData
            return newItem
        }
        
        newItem.compressedData = compressed
        return newItem
    }
    
    func compressAllImages(progressHandler: @escaping (Int) -> Void,
                           completion: @escaping () -> Void) {
        let sliderValue = sliderCompress.doubleValue
        let total = images.count
        
        CompressionManager.shared.reset()
        
        DispatchQueue.global(qos: .userInitiated).async {
            for (index, _) in self.images.enumerated() {
                
                // Check cancellation before processing
                if CompressionManager.shared.cancelled { break }
                
                self.images[index] = self.compressImage(self.images[index], sliderValue: sliderValue)
                
                // Check cancellation after processing one image
                if CompressionManager.shared.cancelled { break }
                
                let progress = Int(Double(index + 1) / Double(total) * 100.0)
                
                DispatchQueue.main.async {
                    progressHandler(progress) // update your progress bar
                }
            }
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }

}
