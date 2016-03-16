//
//  PRSocialShareTwitter.swift
//  ⌘ Praxent
//
//  Created by Albert Martin on 1/28/16.
//  Copyright © 2016 Praxent. All rights reserved.
//

import TwitterKit

/**
 Twitter social share errors
 
 - InvalidConsumerKey:      Thrown when Twitter consumer key is invalid
 - InvalidSecretKey:        Thrown when Twitter secret key is invalid
 - UserMustBeAuthenticated: Thrown when posting is executed while user is not authenticated
 */
public enum SocialShareTwitterError: ErrorType {
    case InvalidConsumerKey
    case InvalidSecretKey
    case UserMustBeAuthenticated
}

/// Twiiter social share tool
public class SocialShareTwitter: SocialShareTool {
    
    /// Twiiter consumer key (can be found under specific app at https://apps.twitter.com)
    private var consumerKey :String?
    /// Twiiter secret key (can be found under specific app at https://apps.twitter.com)
    private var secretKey :String?
    /// Image to be shared
    var image: UIImage?
    /// Image link to be shared
    var imageLink: NSURL?
    
    /**
     Convenience initializer to be used with Twitter consumer and secret keys
     
     - parameter consumerKey: Twitter consumer key (can be found under specific app at https://apps.twitter.com)
     - parameter secretKey:   Twitter secret key (can be found under specific app at https://apps.twitter.com)
     
     - throws: Throws InvalidConsumerKey or InvalidSecretKey
     
     - returns: SocialShareTwitter with Twitter singleton initialized
     */
    convenience init(consumerKey: String, secretKey: String) throws {
        self.init()
        
        guard !consumerKey.isEmpty else {
            throw SocialShareTwitterError.InvalidConsumerKey
        }
        
        guard !secretKey.isEmpty else {
            throw SocialShareTwitterError.InvalidSecretKey
        }
     
        type = SocialShareType.Twitter
        
        self.consumerKey = consumerKey
        self.secretKey = secretKey
        
        Twitter.sharedInstance().startWithConsumerKey(self.consumerKey!, consumerSecret: self.secretKey!)
        composeView = TwitterComposeViewController(shareTool: self)
    }
    
    func destroySession() {
        let store = Twitter.sharedInstance().sessionStore
        let sessions = store.existingUserSessions()
        for session in sessions {
            store.logOutUserID(session.userID)
        }
    }
    
}

/// Twitter social share composer view controller
class TwitterComposeViewController: SocialShareComposeViewController {
    
    /// Twitter media upload endpoint
    private let uploadEndpoint = "https://upload.twitter.com/1.1/media/upload.json"
    /// Twitter status endpoint
    private let updateEndpoint = "https://api.twitter.com/1.1/statuses/update.json"
    /// Twitter social share tool as convenience property
    private var tool :SocialShareTwitter {
        get {
            return self.shareTool as! SocialShareTwitter
        }
    }
    
    override func isContentValid() -> Bool {
        charactersRemaining = 117 - contentText.characters.count
        
        if (charactersRemaining.intValue < 0) {
            return false
        }
        
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func userFinishedPost() {
        if (Twitter.sharedInstance().sessionStore.session() != nil) {
            self.uploadMedia()
            return
        }
        
        Twitter.sharedInstance().logInWithCompletion { (user, error) in
            if (user == nil || error != nil) {
                self.shareTool.finishedShare(self.rootView, error: error)
                return
            }
            
            self.uploadMedia()
        }
    }
    
    override func loadPreviewView() -> UIView! {
        let image = tool.image
        if image != nil {
            let previewImageView = UIImageView(image: imageThumbnail(image!, size: CGSizeMake(100, 100)))
            previewImageView.contentMode = .ScaleAspectFill
            return previewImageView
        }
        return nil
    }
    
    /**
     Upload image to Twitter before use it on a post.
     
     *WARNING*
     
     There is a problem with current library/API and is not possible to upload any media
     * https://dev.twitter.com/overview/api/response-codes
     * http://stackoverflow.com/questions/31259869/share-video-on-twitter-with-fabric-api-without-composer-ios
     * https://dev.twitter.com/rest/public/uploading-media
     
     As specified on documentation and forums, it is necessary to set Content-Type to multipart/form-data but it is not working either:
     
     uploadRequest.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
     
     */
    func uploadMedia() {
        if (Twitter.sharedInstance().sessionStore.session() == nil) {
            self.tool.finishedShare(self.rootView, error: SocialShareTwitterError.UserMustBeAuthenticated)
            return
        }
        
        let client = TWTRAPIClient(userID: Twitter.sharedInstance().sessionStore.session()!.userID)

        let imageData = UIImageJPEGRepresentation((tool.image)!, 0.8)!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        let mediaParams = ["media_data": imageData]
        let uploadRequest: NSMutableURLRequest = client.URLRequestWithMethod("POST", URL: uploadEndpoint, parameters: mediaParams, error: nil) as! NSMutableURLRequest
        
        client.sendTwitterRequest(uploadRequest) { (response, data, error) -> Void in
            var mediaId: String?
            if (data != nil) {
                do {
                    let media = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    mediaId = media.objectForKey("media_id") as? String
                }
                catch {}
            }
            self.postStatus(mediaId)
        }
    }
    
    
    /**
     To publish after send media to Twitter servers
     
     - parameter mediaId: Media identifier to be shared with post. If nil no media will be shared
     */
    func postStatus(mediaId: String?) {
        guard Twitter.sharedInstance().sessionStore.session() != nil else {
            tool.finishedShare(self.rootView, error: SocialShareTwitterError.UserMustBeAuthenticated)
            return
        }
        
        guard !self.contentText.isEmpty || tool.imageLink != nil else {
            return
        }
        
        var status: String = ""
        
        if self.contentText.isEmpty {
            status = (tool.imageLink?.absoluteString)!
        } else if tool.imageLink == nil {
            status = self.contentText
        } else {
            status = "\(self.contentText) \(tool.imageLink!.absoluteString)"
        }
        
        var post = ["status": status]
        
        if mediaId != nil {
            post["media_ids"] = mediaId
        }
        
        let client = TWTRAPIClient(userID: Twitter.sharedInstance().sessionStore.session()!.userID)
        let request = client.URLRequestWithMethod("POST", URL: updateEndpoint, parameters: post, error: nil)
        
        client.sendTwitterRequest(request) { (response, data, error) -> Void in
            self.tool.finishedShare(self.rootView, error: error)
        }
    }
    
}