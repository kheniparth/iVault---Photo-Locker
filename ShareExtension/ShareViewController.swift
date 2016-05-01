//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Parth Kheni on 01/05/16.
//  Copyright © 2016 Parth Kheni. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {

    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        //        self.extensionContext!.completeRequestReturningItems([], completionHandler: nil)
        
        if let content = extensionContext!.inputItems[0] as? NSExtensionItem {
            let contentType = kUTTypeImage as String
            
            // Verify the provider is valid
            if let contents = content.attachments as? [NSItemProvider] {
                // look for images
                for attachment in contents {
                    let imagePath = fileInDocumentsDirectory(NSUUID().UUIDString)
                    
                    if attachment.hasItemConformingToTypeIdentifier(contentType) {
                        attachment.loadItemForTypeIdentifier(contentType, options: nil) { data, error in
                            let url = data as! NSURL
                            if let imageData = NSData(contentsOfURL: url) {
                                print("Image saved at -> \(imagePath)")

                                let image : UIImage = UIImage(data: imageData)!
                                
                                // Save the image
                                if let jpegData = UIImageJPEGRepresentation(image, 80) {
                                    jpegData.writeToFile(imagePath, atomically: true)
                                }
                                
                            }
                        }
                    }
                }
            }
        }
//        Image saved at -> /private/var/mobile/Containers/Shared/AppGroup/C72DC9D9-2375-4CFA-AD43-7C28B2ED8D1E/B8067385-ED1A-4DF3-B831-C231D474F413
//	/private/var/mobile/Containers/Shared/AppGroup/C72DC9D9-2375-4CFA-AD43-7C28B2ED8D1E

        // Unblock the UI.
        self.extensionContext!.completeRequestReturningItems([], completionHandler: nil)
        
        
    }



    override func configurationItems() -> [AnyObject]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

 
    // Get path for a file in the directory
    
    func fileInDocumentsDirectory(filename: String) -> String {
        
        let containerURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.iVault.ShareExtension")
        let filePath = NSURL(string: filename, relativeToURL: containerURL)
        return (filePath?.path)!
        
        
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
