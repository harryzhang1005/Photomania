//
//  CommentTableViewCell.swift
//  Photomania
//
//  Created by Harvey Zhang on 12/16/15.
//  Copyright © 2015 HappyGuy. All rights reserved.
//

import UIKit
import Alamofire

class CommentTableViewCell: UITableViewCell
{
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var commentBodyLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imgView.layer.cornerRadius = 5.0
        imgView.layer.masksToBounds = true
        
        commentBodyLabel.numberOfLines = 0
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(comment: Comment)
    {
        fullNameLabel.text = comment.userFullname
        commentBodyLabel.text = comment.commentBody
        
        Alamofire.request(.GET, comment.userPictureURL).responseImage { (resp:Response<UIImage, NSError>) -> Void in
            if resp.result.error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.imgView.image = resp.result.value
                }
            }
        }
    }

}
