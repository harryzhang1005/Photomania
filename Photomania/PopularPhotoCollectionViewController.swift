//
//  PopularPhotoCollectionViewController.swift
//  Photomania
//
//  Created by Harvey Zhang on 12/16/15.
//  Copyright © 2015 HappyGuy. All rights reserved.
//

import UIKit
import Alamofire

// Will show the type of popular photos from 500px.com 
class PopularPhotoCollectionViewController: UICollectionViewController
{
    private var photos = NSMutableOrderedSet()  // to ensure photo is unique, each element is PhotoInfo
    
    private var currentPage = 1             // current page downloaded from 500px.com
    private var isLoadingPhotos = false     // is downloading photos or not
    
    // pull-to-refresh get the latest photos, reload the collection view
    private var refreshControl = UIRefreshControl() // inherit from UIControl -> UIView
    
    /* Better performance
    When you scroll quickly through the photo browser, you’ll notice that you can send cells off the screen whose image requests are still active. In fact, the image request still runs to completion, but the downloaded photo and associated data is just discarded.
    Additionally, when you return to earlier cells you have to make a network request again for the photo — even though you just downloaded it a moment ago. You can definitely improve on this bandwidth-wasting design!
    You’ll do this by caching retrieved images so they don’t have to be retrieved numerous times; as well, you’ll cancel any in-progress network requests if the associated cell is dequeued before the request completes.
    */
    private let imageCache = NSCache()  // for better performance to cache the downloaded photos

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        setupView()
        loadPhotos()
    }
    
    func setupView()
    {
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        // custom flow layout
        let layout = UICollectionViewFlowLayout()
        
        // Keep 3 items per row
        let itemWidth = (view.bounds.size.width - 16) / 3
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumInteritemSpacing = 8.0
        layout.minimumLineSpacing = 8.0
        
        layout.footerReferenceSize = CGSize(width: collectionView!.bounds.width, height: 100.0)
        self.collectionView?.collectionViewLayout = layout
        
        navigationItem.title = "Featured"
        
        collectionView?.registerClass(PopularPhotoCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: Constant.PopularPhotoItem)
        collectionView?.registerClass(PopularPhotoCollectionViewLoadingCell.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: Constant.PhotoBrowserFooterView)
        
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.addTarget(self, action: "handleRefresh", forControlEvents: .ValueChanged)
        collectionView?.addSubview(refreshControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        self.imageCache.removeAllObjects()
    }
    
    func loadPhotos()
    {
        if isLoadingPhotos { return }
        
        isLoadingPhotos = true
        
        Alamofire.request(Five100px.Router.PopularPhotos(currentPage)).responseJSON { response in
            if let JSON = response.result.value
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    let photoInfos = ( (JSON as! NSDictionary).valueForKey("photos") as! [NSDictionary]).filter {
                        ($0["nsfw"] as! Int) == 0 }.map {
                        PhotoInfo(id: $0["id"] as! Int, url: $0["image_url"] as! String)
                    }
                    
                    let orgPhotoCount = self.photos.count
                    self.photos.addObjectsFromArray(photoInfos)
                    
                    let indexPaths = (orgPhotoCount ..< self.photos.count).map { NSIndexPath(forItem: $0, inSection: 0) }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        //self.collectionView?.reloadData()
                        self.collectionView?.insertItemsAtIndexPaths(indexPaths)    // better performance than above line
                    }
                    
                    self.currentPage++
                }
            }//JSON
            self.isLoadingPhotos = false
        }//request
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.destinationViewController.isKindOfClass(PhotoViewController) && segue.identifier == Constant.PopularShowPhotoSegue
        {
            let photoInfo = sender as! PhotoInfo
            (segue.destinationViewController as! PhotoViewController).photoID = photoInfo.id
            (segue.destinationViewController as! PhotoViewController).hidesBottomBarWhenPushed = true
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.photos.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constant.PopularPhotoItem, forIndexPath: indexPath) as! PopularPhotoCollectionViewCell
    
        // Configure the cell
        let imageURL = (self.photos.objectAtIndex(indexPath.row) as! PhotoInfo).url

        cell.request?.cancel()
        
        if let image = self.imageCache.objectForKey(imageURL) as? UIImage {
            cell.imageView.image = image
        } else {
            cell.imageView.image = nil
        }
        
        cell.request = Alamofire.request(.GET, imageURL).validate(contentType: ["image/*"]).responseImage { (response) -> Void in
            if let img = response.result.value {
                self.imageCache.setObject(img, forKey: (response.request?.URLString)!)
                dispatch_async(dispatch_get_main_queue()) {
                    cell.imageView.image = img
                }
            } else {
                // If the cell went off-screen before the image was downloaded, we cancel it and an NSURLErrorDomain(-999: canclled) is returned. This is a normal behavior
            }
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(Constant.PopularShowPhotoSegue, sender: self.photos.objectAtIndex(indexPath.row) as! PhotoInfo)
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    {
        return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: Constant.PhotoBrowserFooterView, forIndexPath: indexPath)
    }
    
    // MARK: - Scroll view delegate method
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + view.frame.height > scrollView.contentSize.height * 0.8 {
            loadPhotos()
        }
    }
    
    // Handle pull-to-refresh
    func handleRefresh()
    {
        self.refreshControl.beginRefreshing()
        
        self.imageCache.removeAllObjects()
        self.photos.removeAllObjects()
        self.currentPage = 1
        self.isLoadingPhotos = false
        
        self.collectionView?.reloadData()
        
        self.refreshControl.endRefreshing()
        
        loadPhotos()
    }
    
}
