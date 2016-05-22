//
//  PhotoAlbumViewController.swift
//  iVault
//
//  Created by Parth Kheni on 16/04/16.
//  Copyright © 2016 Parth Kheni. All rights reserved.
//


import UIKit
import Photos
import DKImagePickerController


var picking : Bool = false

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imageFileNames = [String]()
    
    var imageUrlsToDelete = [NSURL]()
    var tempPHAssets : [PHAsset] = []
    
    var selectedPhotos = [String]()

    let reuseIdentifier = "photoCell"
    
    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT



    @IBOutlet var noPhotosLabel: UILabel!
    
    //Actions & Outlets
    
    @IBOutlet var collectionView : UICollectionView!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBAction func shareButtonClicked(sender: AnyObject) {
        
        let indexpaths = collectionView?.indexPathsForSelectedItems()
        var imageArray = [UIImage]()

        for indexpath  in indexpaths! {
            
            let imagePath = fileInDocumentsDirectory(imageFileNames[indexpath.item])
            imageArray.append(self.loadImageFromPath(imagePath)!)

            
        }
        
            if !imageArray.isEmpty{
                let vc = UIActivityViewController(activityItems: imageArray, applicationActivities: [])
                presentViewController(vc, animated: true, completion: nil)
            }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        navigationItem.rightBarButtonItem = editButtonItem()
        
        loadImages()
    }
    
    func loadImages() {
        
        imageFileNames.removeAll()
        
        let fm = NSFileManager.defaultManager()
        let path = documentsDirectory()
        let items = try! fm.contentsOfDirectoryAtPath(path as String)
        
        
        for item in items {
            let imagePath = fileInDocumentsDirectory(item)
            if let image = try UIImage(contentsOfFile: imagePath){
                imageFileNames.append(item)
            }
        }

        if imageFileNames.count >= 0{
            
            
            let photoCnt = imageFileNames.count
            
//            print("total \(photoCnt) images found")
            if(photoCnt == 0){
                noPhotosLabel.hidden = false
            }else{
                noPhotosLabel.hidden = true
            }
        }
        
        collectionView.reloadData()


    }
    
    func copySharedImagesToDocumentDirectory(){
        
        let containerURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.iVault.ShareExtension")
        let filePath = containerURL!.path! as NSString
        let items = try! NSFileManager.defaultManager().contentsOfDirectoryAtPath(filePath as String)
        
        for item in items {
            
            do{
                let imagePath = filePath.stringByAppendingPathComponent(item)
                if let image = try UIImage(contentsOfFile: imagePath){
                    
                    if let jpegData = UIImageJPEGRepresentation(image, 80) {
                        jpegData.writeToFile(self.fileInDocumentsDirectory(item), atomically: true)
//                        print("new image at = \(filePath)/\(item)")

                            let error:NSErrorPointer = NSErrorPointer()
                            do{
                                try NSFileManager.defaultManager().removeItemAtPath(imagePath)
//                                print("item delete at path \(imagePath)")
                            }catch{
                                print(error)
                            }
                            
                        
                    }
                    
                }
            }
            
        }
        

    }

    
    override func viewWillAppear(animated: Bool) {
        
        
        // Get size of the collectionView cell for thumbnail image
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout{
            let cellSize = layout.itemSize
            collectionView.sizeThatFits(CGSizeMake(cellSize.width,cellSize.height))

        }

        editing = false
        
        collectionView.backgroundColor = UIColor.blackColor()

        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.toolbar.barStyle = UIBarStyle.Black
        self.navigationController?.setToolbarHidden(true, animated: true)
        
        //fetch the photos from collection
        copySharedImagesToDocumentDirectory()
        loadImages()
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {


        if( segue.identifier == "PhotoSliderWithCell" ){
            
            if let imageSlider:PhotoSliderViewController = segue.destinationViewController as? PhotoSliderViewController{
                if let cell = sender as? UICollectionViewCell{
                    if let indexPath: NSIndexPath = self.collectionView.indexPathForCell(cell){
                        self.loadImages()
                        imageSlider.index = indexPath.item
                        imageSlider.imageFileNames = self.imageFileNames
                
                    }
                }
            }
        }
        


    }
    
    
    // MARK:- Editing
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing{

            collectionView?.allowsMultipleSelection = editing
            self.navigationController?.setToolbarHidden(false, animated: true)
            
        }else{
            self.navigationController?.setToolbarHidden(true, animated: true)
            selectedPhotos.removeAll()
            deselectAllCellsInCollectionView()
        }
    }
    
    
    func deselectAllCellsInCollectionView(){
        let indexpaths = collectionView?.indexPathsForSelectedItems()
        
        
        for indexpath  in indexpaths! {
            if let cell = collectionView.cellForItemAtIndexPath(indexpath){
                cell.layer.borderWidth = 0.0
                cell.layer.borderColor = nil
            }
        }
        
    }
    
    @IBOutlet weak var trashButton: UIBarButtonItem!
    @IBAction func trashButtonClicked(sender: AnyObject) {
        

        
        let indexpaths = collectionView?.indexPathsForSelectedItems()
        selectedPhotos.removeAll()
        
        for indexpath  in indexpaths! {
            let imagePath = fileInDocumentsDirectory(imageFileNames[indexpath.item])
            selectedPhotos.append(imagePath)
        }
        
        ShowAlertToDeleteItems()


    }
    
    
    // MARK:- Delete Items
    func deleteItems(items: [String]) {
        
      
        for item in items {
            // remove item
            if !item.isEmpty {
                let error:NSErrorPointer = NSErrorPointer()
                do{
                    try NSFileManager.defaultManager().removeItemAtPath(item)
                }catch{
                    print(error)
                }
                    
            }
        }
    }
    
    func ShowAlertToDeleteItems(){
        
        if !selectedPhotos.isEmpty {
            let alert = UIAlertController(title: "Delete Image", message: "Are you sure want to delete image(s)?", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: {(alertAction)in
                //Do Delete Photo
                
                self.deleteItems(self.selectedPhotos)
                self.loadImages()
                self.selectedPhotos.removeAll()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: {(alertAction)in
                //Do not delete photo
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            presentViewController(alert, animated: true, completion: nil)
            
        }
        
        deselectAllCellsInCollectionView()

        
    }
    
    @IBOutlet weak var unlockButton: UIBarButtonItem!
    
    @IBAction func unlockButtonClicked(sender: AnyObject) {
        
        
        let indexpaths = collectionView?.indexPathsForSelectedItems()
        selectedPhotos.removeAll()
        
        for indexpath  in indexpaths! {
            let imagePath = fileInDocumentsDirectory(imageFileNames[indexpath.item])
            let image : UIImage = loadImageFromPath(imagePath)!
            selectedPhotos.append(imagePath)
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
       
        ShowAlertToDeleteItems()
        
    }
    
    // MARK:- Should Perform Segue
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return !editing
    }

    
        
    //UICollectionViewDataSource Methods (Remove the "!" on variables in the function prototype)
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        var count: Int = 0
        if(imageFileNames.count > 0){
            count = imageFileNames.count
        }
        return count;
    }
        
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
            
        let cell: PhotoThumbnail = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoThumbnail
        cell.imgView.image = nil
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        
        //For lazy loading image from Document Directory        
        dispatch_async(dispatch_get_global_queue(priority, 0), {
            let imagePath = self.fileInDocumentsDirectory(self.imageFileNames[indexPath.item])
            dispatch_async(dispatch_get_main_queue(), {
                cell.setThumbnailImage(self.loadImageFromPath(imagePath)!)
            })
        })
        
        if selectedPhotos.indexOf(imageFileNames[indexPath.item]) == nil {
            // Unselected
            cell.layer.borderWidth = 0.0
            cell.layer.borderColor = nil

        } else {
            // selected
            cell.layer.borderWidth = 5.0
            cell.layer.borderColor = UIColor.orangeColor().CGColor
        }
        
        return cell
            
    }
    
        

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if editing{
            let cell : UICollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath)!
            if let indexSelecionado = selectedPhotos.indexOf(imageFileNames[indexPath.item]) {
                selectedPhotos.removeAtIndex(indexSelecionado)
                cell.layer.borderWidth = 0.0
                cell.layer.borderColor = nil

            } else {
                selectedPhotos.append(imageFileNames[indexPath.item])
                cell.layer.borderWidth = 5.0
                cell.layer.borderColor = UIColor.orangeColor().CGColor

            }
        }
    }
    


    
   
    //UICollectionViewDelegateFlowLayout methods
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 1
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 1
    }
    
    


    @IBAction func StartImagePicker(sender: AnyObject) {
        
        if picking == false{
            picking = true
        }
        
        if picking == true{
        let pickerController = DKImagePickerController()
        tempPHAssets.removeAll()

        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            
            for asset in assets{
                self.tempPHAssets.append(asset.originalAsset!)
            }
            self.SaveImagesSelectedByUser(assets)
           

            dispatch_async(dispatch_get_global_queue(self.priority, 0), {
                PHPhotoLibrary.sharedPhotoLibrary().performChanges( {
                    PHAssetChangeRequest.deleteAssets(self.tempPHAssets)
                    },
                    completionHandler: {(success:Bool, error:NSError?)in
                        dispatch_async(dispatch_get_main_queue(), {
                    
                            if picking == true{
                                picking = false
                            }
                    //view is already reloads here
                        if(assets.count > 0){

                            if(success){
                                print("Finished deleting asset success")
                            }else{
                                print("Error deleting image(s)")

                            }
                        }
                    })
                        
                })                
            })
            
            
        }
        
        
        presentViewController(pickerController, animated: true) {}
        }
        
       

    }
    
    
    func SaveImagesSelectedByUser(assets: [DKAsset]) {

        for asset in assets {
            let imagePath = fileInDocumentsDirectory(NSUUID().UUIDString)
            
            asset.fetchOriginalImageWithCompleteBlock({ (image, info) -> Void in
            
                
                //print("Image path is : \(imagePath)")
                if let jpegData = UIImageJPEGRepresentation(image!, 80) {
                    jpegData.writeToFile(imagePath, atomically: true)
                    self.loadImages()
                    
                }
              

            })
        }
        
        

    }
    
    
    // Get the documents Directory
    
    func documentsDirectory() -> NSString {
        let documentsFolderPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] 
        return documentsFolderPath
    }
    // Get path for a file in the directory
    
    func fileInDocumentsDirectory(filename: String) -> String {
        return documentsDirectory().stringByAppendingPathComponent(filename)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loadImageFromPath(path: String) -> UIImage? {
        
        let image = UIImage(contentsOfFile: path)
        
        if image == nil {
            
//            print("missing image at: \(path)")
        }else{
//        print("Loading image from path: \(path)") // this is just for you to see the path in case you want to go to the directory, using Finder.
        }
        return image
        
    }
}

