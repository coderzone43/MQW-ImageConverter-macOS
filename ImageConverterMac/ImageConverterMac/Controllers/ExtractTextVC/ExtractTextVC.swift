//
//  ExtractTextVC.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 20/08/2025.
//

import Cocoa

class ExtractTextVC: NSViewController {

    //MARK: Outlets
    @IBOutlet weak var collectionExtract: NSCollectionView!
    
    var arrFiles:[URL] = []
    weak var delegate: DelegateHomeCollectionSelectable?
    
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
        collectionExtract.hideVerticalScroller()
    }
    
    //MARK: Utility Methods
    
    //MARK: Button Action
    
    @IBAction func btnBackAction(_ sender: Any) {
        delegate?.seleclableCollectionView()
        removeChildFromNavigation()
    }
    @IBAction func btnAddAction(_ sender: Any) {
        let dialog = NSOpenPanel();
        dialog.title                   = "Choose a file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.allowsMultipleSelection = true;
        dialog.canChooseDirectories    = false;
        
        dialog.allowedContentTypes = [.jpeg,.svg,.png]
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.urls
            if result.count > 0 {
                for file in result {
                    arrFiles.append(file)
                }
                collectionExtract.reloadData()
            }
        } else {
            return
        }
    }
    @IBAction func btnExtractAction(_ sender: Any) {
        
        if arrFiles.count > 0{
            let cancelToken = CancellationToken()
            
            let loaderVC = ConversionProgressVC() //showConversionLoader()
            loaderVC.strTitle = "Extracting Text..."
            self.presentAsSheet(loaderVC)
            
            loaderVC.cancellationToken = cancelToken
            
            let ocrManager = OCRManager()
            
            ocrManager.extractText(from: arrFiles, progressHandler: { progress in
                print("Progress: \(Int(progress * 100))%")
                //print("Basic Progress: \(Int(progress))%")
                loaderVC.progressBar.minValue = 0
                loaderVC.progressBar.maxValue = 100
                loaderVC.updateProgress(progress)
            }) { texts in
                print("OCR Finished")
                print(texts) // Array of extracted texts
                loaderVC.dismiss(nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    let vc = ExtractResultVC(nibName: "ExtractResultVC", bundle: nil)
                    vc.arrFiles = self.arrFiles
                    vc.arrText = texts
                    self.addChildViewControllerWithAnimation(vc, to: self.view)
                }
                
            }
        }
    }
    
    //MARK: API Methods
    
    //MARK: DELEGATE METHODS
    
    //MARK: TableView
    
    //MARK: CollectionView
    
    //MARK: Segment Control
    
    //MARK: Alert View
    
    //MARK: TextField
    
}
extension ExtractTextVC: NSCollectionViewDelegate,NSCollectionViewDataSource,NSCollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrFiles.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("ConvertZipCVC"), for: indexPath) as! ConvertZipCVC
        
        cell.imgConvert.image = NSImage(contentsOf: arrFiles[indexPath.item])
        
        cell.actionRemove = {
            guard let window = self.view.window else{ return}
            Utility.showAlertSheet(message: "Remove File?", information: "Are you sure want to remove this file", firstButtonTitle: "OK", secondButtonTitle: "Cancel" , window: window) { delete in
                if delete{
                    print("OK Tapped")
                    self.arrFiles.remove(at: indexPath.item)
                    self.collectionExtract.reloadData()
                }
            }
        }
        
        return cell
    }
}
