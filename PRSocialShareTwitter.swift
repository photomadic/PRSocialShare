//
//  PRSocialShareTwitter.swift
//  ⌘ Praxent
//
//  Created by Albert Martin on 1/28/16.
//  Copyright © 2016 Praxent. All rights reserved.
//

import TwitterKit

class SocialShareTwitter: SocialShareTool {
    
    var machine: String = "twitter"
    var title: String = "twitter_title".localized
    
    var composeView: SocialShareComposeViewController? = TwitterComposeViewController()
    var validateRegex: String? = nil
    
    init() {
        let consumerKey = NSBundle.mainBundle().objectForInfoDictionaryKey("SocialShareTwitterConsumer") as! String
        let secretKey = NSBundle.mainBundle().objectForInfoDictionaryKey("SocialShareTwitterSecret") as! String
        Twitter.sharedInstance().startWithConsumerKey(consumerKey, consumerSecret: secretKey)
    }
    
}

class TwitterComposeViewController: SocialShareComposeViewController {
    
    override func isContentValid() -> Bool {
        charactersRemaining = 117 - contentText.characters.count
        
        if (charactersRemaining.intValue < 0) {
            return false
        }
        
        return true
    }
    
    override func userFinishedPost() {
        
        if (Twitter.sharedInstance().sessionStore.session() != nil) {
            self.uploadMedia()
            return
        }
        
        Twitter.sharedInstance().logInWithCompletion { (user, error) in
            if (user == nil || error != nil) {
                print("Unable to authenticate Twitter user", error)
                return
            }
            
            self.uploadMedia()
        }
    }
    
    func uploadMedia() {
        if (Twitter.sharedInstance().sessionStore.session() == nil) {
            print("Twitter user must be logged in to continue.")
            return
        }
        
        let client = TWTRAPIClient(userID: Twitter.sharedInstance().sessionStore.session()!.userID)
        let endpoint = "https://upload.twitter.com/1.1/media/upload.json"
        let imageData = UIImageJPEGRepresentation(SocialShare.sharedInstance.sharedImage!, 0.8)!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        let mediaParams = ["media_data": imageData]
        let uploadRequest = client.URLRequestWithMethod("POST", URL: endpoint, parameters: mediaParams, error: nil)
        
        client.sendTwitterRequest(uploadRequest) { (response, data, error) -> Void in
            if (data != nil) {
                self.postStatus(data!)
                return
            }
            
            print("Error uploading media to Twitter: \(error?.localizedDescription)")
            print(error)
            
            // Continue with the tweet but without any media attachments.
            self.postStatus(nil)
        }
    }
    
    func postStatus(data: NSData?) {
        if (Twitter.sharedInstance().session() == "nil") {
            print("Twitter user must be logged in to continue.")
            return
        }
        
        var mediaId: String = ""
        
        if (data != nil) {
            do {
                let media = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                mediaId = media.objectForKey("media_id") as! String
            }
            catch {
                print("Unable to start decode media response.")
            }
        }
        
        var post = ["status": "\(self.contentText) \(SocialShare.sharedInstance.sharedLink)"]
        
        if (mediaId != "") {
            post["media_ids"] = mediaId
        }
        
        let client = TWTRAPIClient(userID: Twitter.sharedInstance().sessionStore.session()!.userID)
        let endpoint = "https://api.twitter.com/1.1/statuses/update.json"
        let request = client.URLRequestWithMethod("POST", URL: endpoint, parameters: post, error: nil)
        
        client.sendTwitterRequest(request) { (response, data, error) -> Void in
            if (data == nil) {
                print("Error posting status update to Twitter: \(error?.localizedDescription)")
                print(error)
                return
            }
            
            SocialShareTwitter().finishedShare(self.rootView)
        }
    }
    
}