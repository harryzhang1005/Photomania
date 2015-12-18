//
//  Comment.swift
//  Photomania
//
//  Created by Harvey Zhang on 12/16/15.
//  Copyright © 2015 HappyGuy. All rights reserved.
//

import UIKit

// Photo Comment Model Class

// ResponseObjectSerializable, ResponseCollectionSerializable - these two case can not do in its extension
final class Comment: NSObject, ResponseObjectSerializable, ResponseCollectionSerializable
{
    let userFullname: String
    let userPictureURL: String
    let commentBody: String
    
    init(json: AnyObject) {
        self.userFullname = json.valueForKeyPath("user.fullname") as! String
        self.userPictureURL = json.valueForKeyPath("user.userpic_url") as! String
        self.commentBody = json.valueForKeyPath("body") as! String
    }

    // MARK: - ResponseObjectSerializable method
    required init?(response: NSHTTPURLResponse, representation: AnyObject) {
        self.userFullname = representation.valueForKeyPath("user.fullname") as! String
        self.userPictureURL = representation.valueForKeyPath("user.userpic_url") as! String
        self.commentBody = representation.valueForKeyPath("body") as! String
    }
    
    // MARK: - ResponseCollectionSerializable method
    
    // Here need this class is a final class
    static func collection(response response: NSHTTPURLResponse, representation: AnyObject) -> [Comment]
    {
        var comments: [Comment] = []
        
        if let values = representation.valueForKeyPath("comments") as? [NSDictionary]
        {
            for v in values {
                if let comment = Comment(response: response, representation: v) {
                    comments.append(comment)
                }
            }
        }
        
        return comments
    }
    
}
