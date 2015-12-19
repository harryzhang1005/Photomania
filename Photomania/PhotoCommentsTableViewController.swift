//
//  PhotoCommentsTableViewController.swift
//  Photomania
//
//  Created by Harvey Zhang on 12/16/15.
//  Copyright © 2015 HappyGuy. All rights reserved.
//

import UIKit
import Alamofire

class PhotoCommentsTableViewController: UITableViewController
{
    var photoInfo: PhotoInfo?
    
    var photoComments = [Comment]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Auto row height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80.0
        
        let done = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done")
        self.navigationItem.rightBarButtonItem = done
        
        title = "Comments"
        
        loadComments()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadComments()
    {
        if let pInfo = photoInfo {
            Alamofire.request(Five100px.Router.PhotoComments(pInfo.id, 1)).responseCollection({ (response :Response<[Comment], NSError>) -> Void in
                if response.result.error == nil {
                    self.photoComments = response.result.value!
                    
                    dispatch_async(dispatch_get_main_queue()){
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
    
    func done() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return photoComments.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.PhotoCommentCell, forIndexPath: indexPath) as! CommentTableViewCell

        // Configure the cell...
        cell.configCell(self.photoComments[indexPath.row])

        return cell
    }

}
