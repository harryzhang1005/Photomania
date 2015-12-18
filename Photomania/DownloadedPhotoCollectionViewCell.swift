//
//  DownloadedPhotoCollectionViewCell.swift
//  Photomania
//
//  Created by Harvey Zhang on 12/16/15.
//  Copyright © 2015 HappyGuy. All rights reserved.
//

import UIKit

class DownloadedPhotoCollectionViewCell: UICollectionViewCell
{
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configCell()
    }
    
    func configCell()
    {
        imageView.frame = bounds
        imageView.contentMode = .ScaleAspectFit
        self.addSubview(imageView)
    }
}
