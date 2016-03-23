//
//  DownloadedPhotoCollectionViewController.swift
//  Photomania
//
//  Created by Harvey Zhang on 12/16/15.
//  Copyright © 2015 HappyGuy. All rights reserved.
//

import UIKit
import Alamofire

// Will show the downloaded photos in collection view
class DownloadedPhotoCollectionViewController: UICollectionViewController
{
    private var photoURLs = NSMutableOrderedSet()   // store local photo URL paths
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView()
    {
        navigationItem.title = "Downloads"
        
        setupFlowLayout()
        
        // Register cell classes
        self.collectionView!.registerClass(DownloadedPhotoCollectionViewCell.classForCoder(),
                                           forCellWithReuseIdentifier: Constant.DownloadedPhotoItem)
    }
    
    private func setupFlowLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8.0
        layout.minimumLineSpacing = 8.0
        
        let itemsPerRow: CGFloat = 1 //isLandscape() ? 3 : 2
        let itemWidth = (view.bounds.size.width - 8*(itemsPerRow - 1)) / itemsPerRow
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        collectionView?.collectionViewLayout = layout
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        loadPhotos()
    }
    
//    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
//        
//        coordinator.animateAlongsideTransition({ _ in
//            self.setupFlowLayout()
//        }) { _ in
//            self.collectionView?.collectionViewLayout.invalidateLayout()
//        }
//    }
    
    private func isLandscape() -> Bool {
        // Returns true if the interface orientation is landscape, otherwise returns false.
        return UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation)
    }
    
    func loadPhotos()
    {
        self.photoURLs.removeAllObjects()   // first clean up
        
        // Step-1: find the directory
        let dirURLs = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let dirURL = dirURLs[0]
        
        // Step-2: iterate files in this directory
        let urls = try? NSFileManager.defaultManager().contentsOfDirectoryAtURL(dirURL, includingPropertiesForKeys: nil,
                                                                                options: .SkipsHiddenFiles)
        
        if let imageURLs = urls {
            self.photoURLs.addObjectsFromArray(imageURLs)
        }
        
        collectionView?.reloadData()    // Don't forget
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.destinationViewController.isKindOfClass(PhotoViewController) && segue.identifier == Constant.DownloadedShowPhotoSegue {
            (segue.destinationViewController as! PhotoViewController).imageURL = sender as? NSURL
        }
    }
    
    // Delete a photo using the unwind segue
    @IBAction func backToDownloadsCollectionVC(unwindSegue: UIStoryboardSegue)
    {
        let deletedImageURL = (unwindSegue.sourceViewController as! PhotoViewController).imageURL
        if let imgURL = deletedImageURL
        {
            //print("will delete this photo: \(imgURL.path!)")
            if NSFileManager.defaultManager().fileExistsAtPath(imgURL.path!)
            {
                do {
                    try NSFileManager.defaultManager().removeItemAtURL(imgURL)
                    self.photoURLs.removeObject(imgURL)
                    self.collectionView?.reloadData()
                    navigationController?.popViewControllerAnimated(true)
                } catch (let error) {
                    print("remove item error: \(error)")
                }
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoURLs.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constant.DownloadedPhotoItem, forIndexPath: indexPath) as! DownloadedPhotoCollectionViewCell
    
        // Configure the cell
        let imageURL = self.photoURLs.objectAtIndex(indexPath.row) as! NSURL
        cell.imageView.image = UIImage(data: NSData(contentsOfURL: imageURL)! )
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(Constant.DownloadedShowPhotoSegue, sender: (self.photoURLs.objectAtIndex(indexPath.row) as! NSURL))
    }

}
