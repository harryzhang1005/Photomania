//
//  PopularPhotoCollectionViewCell.swift
//  Photomania
//
//  Created by Harvey Zhang on 12/16/15.
//  Copyright © 2015 HappyGuy. All rights reserved.
//

import UIKit
import Alamofire

class PopularPhotoCollectionViewCell: UICollectionViewCell
{
    let imageView = UIImageView()
    
    var request: Alamofire.Request? // Store download image Alamofire request
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configCell()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configCell()
    }
    
    func configCell()
    {
        backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        
        imageView.frame = bounds
        addSubview(imageView)
    }
}

// Spinner view
class PopularPhotoCollectionViewLoadingCell: UICollectionReusableView {
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configView()
    }
    
    func configView()
    {
        spinner.startAnimating()
        spinner.center = self.center
        addSubview(spinner)
        
    }
}



