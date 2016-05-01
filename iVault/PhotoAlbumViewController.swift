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
        
//        navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed: "plus.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
//            style:UIBarButtonItemStylePlain
//            target:self
//            action:@selector(info:)];


        loadImages()
    }
    
    func loadImages() {
        
        imageFileNames.removeAll()
        
        let fm = NSFileManager.defaultManager()
        let path = documentsDirectory()
        let items = try! fm.contentsOfDirectoryAtPath(path as String)
        
        for item in items {
            self.imageFileNames.append(item)
        }

        if self.imageFileNames.count >= 0{
            
            
            let photoCnt = self.imageFileNames.count
            
//            print("total \(photoCnt) images found")
            if(photoCnt == 0){
                self.noPhotosLabel.hidden = false
            }else{
                self.noPhotosLabel.hidden = true
            }
        }
        
        self.collectionView.reloadData()


    }

    
    override func viewWillAppear(animated: Bool) {
        
       
        
        // Get size of the collectionView cell for thumbnail image
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout{
            let cellSize = layout.itemSize
            self.collectionView.sizeThatFits(CGSizeMake(cellSize.width,cellSize.height))

        }

        self.editing = false
        
        self.collectionView.backgroundColor = UIColor.blackColor()

        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.toolbar.barStyle = UIBarStyle.Black
        self.navigationController?.setToolbarHidden(true, animated: true)
        self.navigationController?.hidesBarsOnTap = false   //!! Use optional chaining
        
        //fetch the photos from collection

        loadImages()
        self.collectionView.reloadData()
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
            deselectAllCellsInCollectionView()
        }
    }
    
    
    func deselectAllCellsInCollectionView(){
        var indexpaths = collectionView?.indexPathsForSelectedItems()
        
        
        for indexpath  in indexpaths! {
            //Mark:- Error
            let cell = collectionView.cellForItemAtIndexPath(indexpath)
            cell!.layer.borderWidth = 0.0
            cell!.layer.borderColor = nil
        }
        
    }
    
    @IBOutlet weak var trashButton: UIBarButtonItem!
    @IBAction func trashButtonClicked(sender: AnyObject) {
        

        
        let indexpaths = collectionView?.indexPathsForSelectedItems()
        self.selectedPhotos.removeAll()
        
        for indexpath  in indexpaths! {
            let cell = collectionView!.cellForItemAtIndexPath(indexpath )
            
            let imagePath = fileInDocumentsDirectory(imageFileNames[indexpath.item])
            selectedPhotos.append(imagePath)
            
            let alert = UIAlertController(title: "Delete Image", message: "Are you sure you want to delete this image(s)?", preferredStyle: .Alert)
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
            self.presentViewController(alert, animated: true, completion: nil)
            

        }

        self.deselectAllCellsInCollectionView()

        }
    
    
    // MARK:- Delete Items
    func deleteItems(items: [String]) {
        
      
        for item in items {
            // remove item
            if !item.isEmpty {
                var error:NSErrorPointer = NSErrorPointer()
                do{
                    try NSFileManager.defaultManager().removeItemAtPath(item)
                }catch{
                    print(error)
                }
                    
            }
        }
    }
    
    @IBOutlet weak var unlockButton: UIBarButtonItem!
    
    @IBAction func unlockButtonClicked(sender: AnyObject) {
        
        
        let indexpaths = collectionView?.indexPathsForSelectedItems()
        self.selectedPhotos.removeAll()
        
        for indexpath  in indexpaths! {
            let cell = collectionView!.cellForItemAtIndexPath(indexpath )
            
//            collectionView?.deselectItemAtIndexPath(indexpath, animated: true)
            let imagePath = fileInDocumentsDirectory(imageFileNames[indexpath.item])
            let image : UIImage = self.loadImageFromPath(imagePath)!
            selectedPhotos.append(imagePath)
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        if !indexpaths!.isEmpty {
                let alert = UIAlertController(title: "Delete Image", message: "Are you sure you want to delete this image(s) after movies to Photos App?", preferredStyle: .Alert)
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
            self.presentViewController(alert, animated: true, completion: nil)

        }

        self.deselectAllCellsInCollectionView()

        
    }
    
    // MARK:- Should Perform Segue
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return !editing
    }

    
        
        //UICollectionViewDataSource Methods (Remove the "!" on variables in the function prototype)
        func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
            var count: Int = 0
            if(self.imageFileNames.count > 0){
                count = self.imageFileNames.count
            }
            return count;
        }
        
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
            
            
            
            let cell: PhotoThumbnail = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoThumbnail
            
                let imagePath = fileInDocumentsDirectory(imageFileNames[indexPath.item])
                cell.setThumbnailImage(loadImageFromPath(imagePath)!)
            
            return cell
            
        }
    
        

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if editing{
            let cell = collectionView.cellForItemAtIndexPath(indexPath)
            cell!.layer.borderWidth = 5.0
            cell!.layer.borderColor = UIColor.orangeColor().CGColor
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if editing {
            if let foundIndex = selectedPhotos.indexOf(imageFileNames[indexPath.item]) {
                selectedPhotos.removeAtIndex(foundIndex)
            }
        }
                let cell = collectionView.cellForItemAtIndexPath(indexPath)
                cell!.layer.borderWidth = 0.0
                cell!.layer.borderColor = nil
            
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
        self.tempPHAssets.removeAll()

        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            
            for asset in assets{
                self.tempPHAssets.append(asset.originalAsset!)
            }
            self.SaveImagesSelectedByUser(assets)
           

            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0), {
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
        
        
        self.presentViewController(pickerController, animated: true) {}
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
                    self.collectionView.reloadData()
                    
                }

//                if info!.keys.contains(NSString(string: "PHImageFileURLKey"))
//                {
//                    let imageUrl = info![NSString(string: "PHImageFileURLKey")] as! NSURL
//                    self.imageUrlsToDelete.append(imageUrl)
//                    
//                }
                
              

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

