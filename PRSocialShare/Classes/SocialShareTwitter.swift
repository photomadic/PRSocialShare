//
//  PRSocialShareTwitter.swift
//  ⌘ Praxent
//
//  Created by Albert Martin on 1/28/16.
//  Copyright © 2016 Praxent. All rights reserved.
//

import TwitterKit

public enum SocialShareTwitterError: ErrorType {
    case InvalidConsumerKey
    case InvalidSecretKey
    case UserMustBeAuthenticated
    case InvalidContructor
}

public class SocialShareTwitter: SocialShareTool {
    
    private var consumerKey :String?
    private var secretKey :String?
    
    var image: UIImage?
    var imageLink: NSURL?
    
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

class TwitterComposeViewController: SocialShareComposeViewController {
    
    let uploadEndpoint = "https://upload.twitter.com/1.1/media/upload.json"
    let updateEndpoint = "https://api.twitter.com/1.1/statuses/update.json"
    
    var tool :SocialShareTwitter {
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
    
    func uploadMedia() {
        if (Twitter.sharedInstance().sessionStore.session() == nil) {
            self.tool.finishedShare(self.rootView, error: SocialShareTwitterError.UserMustBeAuthenticated)
            return
        }
        
        let client = TWTRAPIClient(userID: Twitter.sharedInstance().sessionStore.session()!.userID)

        let imageData = UIImageJPEGRepresentation((tool.image)!, 0.8)!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        let mediaParams = ["media_data": imageData]
        let uploadRequest = client.URLRequestWithMethod("POST", URL: uploadEndpoint, parameters: mediaParams, error: nil)
        
        client.sendTwitterRequest(uploadRequest) { (response, data, error) -> Void in
            self.postStatus(data)
        }
    }
    
    func postStatus(data: NSData?) {
        guard Twitter.sharedInstance().sessionStore.session() != nil else {
            tool.finishedShare(self.rootView, error: SocialShareTwitterError.UserMustBeAuthenticated)
            return
        }
        
        var mediaId: String = ""
        
        if (data != nil) {
            do {
                let media = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                mediaId = media.objectForKey("media_id") as! String
            }
            catch {
                tool.finishedShare(self.rootView, error: error)
            }
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
        
        if (mediaId != "") {
            post["media_ids"] = mediaId
        }
        
        let client = TWTRAPIClient(userID: Twitter.sharedInstance().sessionStore.session()!.userID)
        let request = client.URLRequestWithMethod("POST", URL: updateEndpoint, parameters: post, error: nil)
        
        client.sendTwitterRequest(request) { (response, data, error) -> Void in
            self.tool.finishedShare(self.rootView, error: error)
        }
    }
    
}