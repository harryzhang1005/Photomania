//
//  PhotoDetailViewController.swift
//  Photomania
//
//  Created by Harvey Zhang on 12/16/15.
//  Copyright © 2015 HappyGuy. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController
{
    var photoInfo: PhotoInfo?
    
    @IBOutlet weak var highestLabel: UILabel!
    @IBOutlet weak var pulseLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
        loadData()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func setupView()
    {
        let tap = UITapGestureRecognizer(target: self, action: #selector(PhotoDetailViewController.dismiss))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tap)
    }
    
    func loadData()
    {
        if let pInfo = photoInfo {
            highestLabel.text = "\(pInfo.highest ?? 0)"
            pulseLabel.text = "\(pInfo.pulse ?? 0)"
            viewsLabel.text = "\(pInfo.views ?? 0)"
            descLabel.text = pInfo.desc
        }
    }
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
