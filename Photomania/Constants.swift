//
//  Constants.swift
//  Photomania
//
//  Created by Harvey Zhang on 12/16/15.
//  Copyright © 2015 HappyGuy. All rights reserved.
//

import UIKit
import Alamofire

/////////////////////////////////////////////////////////////////////////

//// Level-1: Serialize a Special Object (In this case, UIImage) ////
// Alamofire provides built-in response serialization for strings, JSON, and property lists, but others can be added in extensions on Alamofire.Request.

extension Alamofire.Request {
    // Creating a Custom Response Serializer
    public static func imageResponseSerializer() -> ResponseSerializer<UIImage, NSError>
    {
        return ResponseSerializer<UIImage, NSError> { request, response, data, error in
            guard error == nil else { return .Failure(error!) }
            
            guard let validData = data else {
                let failureReason = "Data could not be serialized. Input data was nil."
                let err = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(err)
            }
            
            let image = UIImage(data: validData, scale: UIScreen.mainScreen().scale)
            return .Success(image!)
        }
    }
    
    // Usually when you create a response serializer, you'll also want to create a new response handler to go with it and make it easy to use
    public func responseImage(completionHandler: Response<UIImage, NSError> -> Void) -> Self
    {
        return response(responseSerializer: Request.imageResponseSerializer(), completionHandler: completionHandler)
    }
}

//// Level-2: Serialize Generic Object (In this case, PhotoInfo and Comment) ////

// Generic Response Object Serialization
public protocol ResponseObjectSerializable {
    init?(response: NSHTTPURLResponse, representation: AnyObject)
}

// That means if you defien a new class that conforming to ResponeObjectSerializable protocol, Alamofire can automatically return objects of that type from the server.
extension Alamofire.Request {
    // Generics can be used to provide automatic, type-safe response object serialization.
    public func responseObject<T: ResponseObjectSerializable>(completionHandler: Response<T, NSError> -> Void) -> Self
    {
        let responseObjectSerializer = ResponseSerializer<T, NSError> { request, response, data, error in
            guard error == nil else { return .Failure(error!) }
            
            // responseJSONSerializer is type of ResponseSerializer<AnyObject, NSError>
            let responseJSONSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            
            // result is type of Result<AnyObject, NSError>
            let result = responseJSONSerializer.serializeResponse(request, response, data, error)
            
            switch result {
            case .Success(let value):
                if let resp = response, respObject = T(response: resp, representation: value) {
                    return .Success(respObject)
                } else {
                    let failureReason = "JSON could not be serialized into response object: \(value)"
                    let err = Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
                    return .Failure(err)
                }
            case .Failure(let err):
                return .Failure(err)
            }
        }//responseObjectSerializer
        
        return response(responseSerializer: responseObjectSerializer, completionHandler: completionHandler)
    }
}

//// Level-3: Serialize Collection ////

// The same approach can also be used to handle endpoints that return a representation of a collection of objects
public protocol ResponseCollectionSerializable {
    static func collection(response response: NSHTTPURLResponse, representation: AnyObject) -> [Self]
}

extension Alamofire.Request {
    public func responseCollection<T: ResponseCollectionSerializable>(completionHandler: Response<[T], NSError> -> Void) -> Self
    {
        let responseCollectionSerializer = ResponseSerializer<[T], NSError> { request, response, data, error in
            guard error == nil else { return .Failure(error!) }
            
            let responseJSONSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = responseJSONSerializer.serializeResponse(request, response, data, error)
            
            switch result {
            case .Success(let value):
                if let resp = response {
                    return .Success(T.collection(response: resp, representation: value))
                } else {
                    let failureReason = "Response collection could not be serialized due to nil response"
                    let err = Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
                    return .Failure(err)
                }
            case .Failure(let err):
                return .Failure(err)
            }
        }
        
        return response(responseSerializer: responseCollectionSerializer, completionHandler: completionHandler)
    }
}

/////////////////////////////////////////////////////////////////////////

struct Constant {
    static let PopularPhotoItem = "FavPhotoItem"
    static let DownloadedPhotoItem = "DownloadedPhotoItem"
    
    static let PhotoDetailVC = "PhotoDetailVC"
    static let PhotoCommentsTVC = "PhotoCommentsTVC"
    static let PhotoCommentCell = "PhotoCommentCell"
    
    static let PopularShowPhotoSegue = "PopularShowPhoto"
    static let DownloadedShowPhotoSegue = "DownloadedShowPhoto"
    
    static let PhotoBrowserFooterView = "PhotoBrowserFooterView"
}

struct Five100px {
    
    enum Router: URLRequestConvertible {

        static let BaseURL = "https://api.500px.com/v1"
        static let ConsumerKey = "EBin9fMMqiJsbqvaruQbGtaHyg7VtvpZiegCMdbj"
        
        case PopularPhotos(Int)             // param    :   page number
        case SpecialPhoto(Int, ImageSize)   // params   :   photo id, image size
        case PhotoComments(Int, Int)        // param    :   photo id, comments page number
        
        var URLRequest: NSMutableURLRequest {
            let (path, parameters): (String, [String: AnyObject]) = {
                switch self {
                case .PopularPhotos(let page):
                    let params = ["consumer_key": Router.ConsumerKey, "page": "\(page)", "feature": "popular", "rpp": "50", "include_store": "store_download", "include_states": "votes"]
                    return ("/photos", params)
                case .SpecialPhoto(let photoID, let imageSize):
                    let params = ["consumer_key": Router.ConsumerKey, "image_size": "\(imageSize.rawValue)"]
                    return ("/photos/\(photoID)", params)
                case .PhotoComments(let photoID, let commentPage):
                    let params = ["consumer_key": Router.ConsumerKey, "comments": "1", "comments_page": "\(commentPage)"]
                    return ("/photos/\(photoID)/comments", params)
                }
            }()
            
            let url = NSURL(fileURLWithPath: Router.BaseURL)
            let urlRequest = NSURLRequest(URL: url.URLByAppendingPathComponent(path))
            let urlEncoding = Alamofire.ParameterEncoding.URL
            
            // func encode(URLRequest: URLRequestConvertible, parameters: [String : AnyObject]?) -> (NSMutableURLRequest, NSError?)
            return urlEncoding.encode(urlRequest, parameters: parameters).0
        }
    }
    
    enum ImageSize: Int {
        case Tiny = 1, Small = 2, Medium = 3, Large = 4, XLarge = 5
    }

}
