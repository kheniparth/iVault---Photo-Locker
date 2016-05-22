//
//  PhotoSliderViewController.swift
//  iVault
//
//  Created by Parth Kheni on 29/04/16.
//  Copyright © 2016 Parth Kheni. All rights reserved.
//

import UIKit

class PhotoSliderViewController: UIViewController, UIPageViewControllerDataSource {
    
    // MARK: - Variables
    private var pageViewController: UIPageViewController?
    
    // Initialize it right away here
        
    var imageFileNames = [String]()
    
    var index: Int!

    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createPageViewController()
        setupPageControl()
    }
    
    
    
    private func createPageViewController() {
        
        let pageController = self.storyboard!.instantiateViewControllerWithIdentifier("PhotoSliderController") as! UIPageViewController
        pageController.dataSource = self
        
        if imageFileNames.count > 0 {
            var firstController = getItemController(0)!
            
            if(index != nil){
             firstController = getItemController(index)!
            }
            let startingViewControllers: NSArray = [firstController]
            pageController.setViewControllers(startingViewControllers as? [UIViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
            
            
        }
       

        
        pageViewController = pageController
        addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
    }
    
    
    
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.grayColor()
        appearance.currentPageIndicatorTintColor = UIColor.whiteColor()
        appearance.backgroundColor = UIColor.darkGrayColor()
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! PhotoSliderItemController
        
        if itemController.itemIndex > 0 {
            return getItemController(itemController.itemIndex-1)
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! PhotoSliderItemController
        
        if itemController.itemIndex+1 < imageFileNames.count {
            return getItemController(itemController.itemIndex+1)
        }
        
        return nil
    }
    
    private func getItemController(itemIndex: Int) -> PhotoSliderItemController? {
        
        if itemIndex < imageFileNames.count {
            let pageItemController = self.storyboard!.instantiateViewControllerWithIdentifier("ItemController") as! PhotoSliderItemController
            pageItemController.itemIndex = itemIndex
            pageItemController.imageName = imageFileNames[itemIndex]
            return pageItemController
        }
        
        return nil
    }
    
    // MARK: - Page Indicator

    // Uncomment below delegate methods if you want to show page control dots in slider.
//    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
//        return imageFileNames.count
//    }
//    
//    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
//        return index
//    }


}
