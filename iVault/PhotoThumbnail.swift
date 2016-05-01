//
//  PhotoThumbnail.swift
//  iVault
//
//  Created by Parth Kheni on 16/04/16.
//  Copyright © 2016 Parth Kheni. All rights reserved.
//

import UIKit

class PhotoThumbnail: UICollectionViewCell {
    
    @IBOutlet var imgView : UIImageView!
    
    
    func setThumbnailImage(thumbnailImage: UIImage){
        self.imgView.image = thumbnailImage
    }
    
}
