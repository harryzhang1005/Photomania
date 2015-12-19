//
//  PhotoInfo.swift
//  Photomania
//
//  Created by Harvey Zhang on 12/16/15.
//  Copyright © 2015 HappyGuy. All rights reserved.
//

import UIKit

// Photo Model Class
class PhotoInfo: NSObject, ResponseObjectSerializable
{
    let id: Int             // photo id
    let url: String         // photo url
    
    var name: String?       // photo name
    
    var favoritesCount: Int?    // how many people favorite this photo
    var votesCount: Int?        // how many people vote for this photo
    var commentsCount: Int?     // how many comments for this photo
    
    var highest: Float?     // highest score
    var pulse: Float?       // pulse score
    var views: Int?         // how many people view this photo
    var camera: String?     // what kind of camera is used to taken this photo
    var desc: String?       // how do you describe this photo

    init(id: Int, url: String) {
        self.id = id
        self.url = url
    }
    
    // ResponseObjectSerializable method, can not put it in extension
    
    required init?(response: NSHTTPURLResponse, representation: AnyObject) {
        self.id = representation.valueForKeyPath("photo.id") as! Int
        self.url = representation.valueForKeyPath("photo.image_url") as! String
        
        self.favoritesCount = representation.valueForKeyPath("photo.favorites_count") as? Int
        self.votesCount = representation.valueForKeyPath("photo.votes_count") as? Int
        self.commentsCount = representation.valueForKeyPath("photo.comments_count") as? Int
        self.highest = representation.valueForKeyPath("photo.highest_rating") as? Float
        self.pulse = representation.valueForKeyPath("photo.rating") as? Float
        self.views = representation.valueForKeyPath("photo.times_viewed") as? Int
        self.camera = representation.valueForKeyPath("photo.camera") as? String
        self.desc = representation.valueForKeyPath("photo.description") as? String
        self.name = representation.valueForKeyPath("photo.name") as? String
    }
    
    // MARK: - Hashable support
    
    // Hashable - Both isEqual and hash use an integer for the id property so ordering and uniquing PhotoInfo objects will still be a relatively fast operation
    override func isEqual(object: AnyObject?) -> Bool {
        return (object as? PhotoInfo)?.id == self.id
    }
    
    // Override hash property in NSObjectProtocol, var hash: Int { get }
    override var hash: Int {
        return (self as PhotoInfo).id
    }
    
}
