//
//  PhotoSliderItemController.swift
//  iVault
//
//  Created by Parth Kheni on 29/04/16.
//  Copyright © 2016 Parth Kheni. All rights reserved.
//

import UIKit
import ImageScrollView

class PhotoSliderItemController: UIViewController {
    
    // MARK: - Variables
    var itemIndex: Int = 0
    var imageName: String = ""
    
    @IBOutlet weak var imageScrollView: ImageScrollView!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let image : UIImage = self.loadImageFromPath(fileInDocumentsDirectory(imageName))!        
        imageScrollView.displayImage(image)
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
