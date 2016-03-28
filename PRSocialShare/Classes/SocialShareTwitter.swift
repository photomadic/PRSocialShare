//
//  PRSocialShareTwitter.swift
//  ⌘ Praxent
//
//  Created by Albert Martin on 1/28/16.
//  Copyright © 2016 Praxent. All rights reserved.
//

//import TwitterKit
import OAuthSwift

/**
 Twitter social share errors
 
 - UserMustBeAuthenticated: Thrown when posting is executed while user is not authenticated
 */
public enum SocialShareTwitterError: ErrorType {
    case UserMustBeAuthenticated
}

/// Twiiter social share tool
public class SocialShareTwitter: SocialShareTool {

    /// Image local url to be shared
    var imageURL: NSURL?
    
    var consumerKey: String!
    
    var secretKey: String!
    
    /**
     Initialize with consumer and secret Twitter keys.
     Twitter keys can be found under specific app at https://apps.twitter.com
     
     - returns: Tool with Twitter singleton initialized
     */
    override init() {
        super.init()
     
        type = SocialShareType.Twitter
        
        consumerKey = getValueFromPlist("TwitterConsumer")
        assert(consumerKey != nil && !consumerKey!.isEmpty, "Info.plist should have a dictionary SocialShareTool with a key/value TwitterConsumer and should not be a empty string")
        
        secretKey = getValueFromPlist("TwitterSecret")
        assert(secretKey != nil && !secretKey!.isEmpty, "Info.plist should have a dictionary SocialShareTool with a key/value TwitterSecret and should not be a empty string")
        
        //Twitter.sharedInstance().startWithConsumerKey(consumerKey!, consumerSecret: secretKey!)
        composeView = TwitterComposeViewController(shareTool: self)
    }
    
    func logout() {
//        let store = Twitter.sharedInstance().sessionStore
//        let sessions = store.existingUserSessions()
//        for session in sessions {
//            store.logOutUserID(session.userID)
//        }
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
    private var image: UIImage?
    
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
        let oauthswift = OAuth1Swift(
            consumerKey:    tool.consumerKey,
            consumerSecret: tool.secretKey,
            requestTokenUrl: "https://api.twitter.com/oauth/request_token",
            authorizeUrl:    "https://api.twitter.com/oauth/authorize",
            accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
        )
        oauthswift.authorize_url_handler = SafariURLHandler(viewController: self.rootView)
        
        oauthswift.authorizeWithCallbackURL( NSURL(string: "pr-social-share://oauth-callback/twitter")!, success: {credential, response, parameters in
            var data: String? = nil
            if self.tool.imageURL != nil {
                data = NSData(contentsOfURL: self.tool.imageURL!)?.base64EncodedStringWithOptions([NSDataBase64EncodingOptions.EncodingEndLineWithCarriageReturn, NSDataBase64EncodingOptions.EncodingEndLineWithLineFeed])
            }
            
            if data == nil {
                self.updateStatus(oauthswift, mediaIds: nil, success: nil, failure: { error in print(error.localizedDescription) })
            } else {
                oauthswift.client.post("https://upload.twitter.com/1.1/media/upload.json", parameters: ["media_data" : data!], headers: ["Content-Type": "image/png"], success: { (data, response) in
                    
                    let JSON = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
                    let mediaId = JSON["media_id_string"] as! String
                    self.updateStatus(oauthswift, mediaIds: mediaId, success: nil, failure: { error in print(error.localizedDescription) })
                    
                    }, failure: { error in print(error.localizedDescription) })
            }
            }, failure: { error in print(error.localizedDescription) })
    }
    
    override func loadPreviewView() -> UIView! {
        if image == nil &&  tool.imageURL != nil {
            image = UIImage(contentsOfFile: (tool.imageURL?.absoluteString)!)
        }
        
        if image != nil {
            let previewImageView = UIImageView(image: imageThumbnail(image!, size: CGSizeMake(100, 100)))
            previewImageView.contentMode = .ScaleAspectFill
            return previewImageView
        }
        return nil
    }
    
    private func updateStatus(oauthswift: OAuth1Swift, mediaIds: String?, success: OAuthSwiftHTTPRequest.SuccessHandler?, failure: OAuthSwiftHTTPRequest.FailureHandler?) {
        var parameters = ["status": self.contentText]
        if mediaIds != nil {
            parameters["media_ids"] = mediaIds
        }
        oauthswift.client.post("https://api.twitter.com/1.1/statuses/update.json", parameters: parameters, headers: nil, success: success, failure: failure)
    }

}