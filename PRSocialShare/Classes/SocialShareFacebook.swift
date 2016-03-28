//
//  PRSocialShareFacebook.swift
//  ⌘ Praxent
//
//  Created by Albert Martin on 1/28/16.
//  Copyright © 2016 Praxent. All rights reserved.
//

import FBSDKLoginKit

public enum SocialShareFacebookError: ErrorType {
    case InvalidAppID
}

public class SocialShareFacebook: SocialShareTool {
    
    /// Local image URL to be shown on compose view
    var imageURL: NSURL?
    /// Link to be sent on Facebook post
    var link: NSURL?
    /// Link title to display on Facebook post
    var linkTitle: String?
    /// Image link to be sent on Facebook post
    var imageToShareURL: NSURL?
    /// Facebook post caption
    var caption: String?
    
    
    override init() {
        super.init()
        
        let appID = getValueFromPlist("FacebookAppID")
        assert(appID != nil && !appID!.isEmpty, "Info.plist should have a dictionary SocialShareTool with a key/value FacebookAppID and should not be a empty string")
        FBSDKSettings.setAppID(appID)
        
        message = ""
        messagePlaceholder = "Write your message here".localized
        actionTitle = "Facebook".localized
        type = SocialShareType.Facebook
        composeView = FBComposeViewController(shareTool: self)
    }
    
    func logout() {
        FBSDKLoginManager().logOut()
    }
}

class FBComposeViewController: SocialShareComposeViewController {
    
    let permissions: [String] = ["publish_actions"]
    var tool :SocialShareFacebook {
        get {
            return self.shareTool as! SocialShareFacebook
        }
    }
    
    override func userFinishedPost() {
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            createPost()
            return
        }
        
        let fblogin = FBSDKLoginManager()
        fblogin.loginBehavior = .Web
        fblogin.logInWithPublishPermissions(permissions, fromViewController: self.presentingViewController, handler: userFinishedAuth)
    }
    
    override func loadPreviewView() -> UIView! {
        guard self.tool.imageURL != nil else {
            return nil
        }
        
        let data = NSData(contentsOfURL: self.tool.imageURL!)
        guard data != nil else {
            return nil
        }
        
        let image = UIImage(data: data!)
        guard image != nil else {
            return nil
        }
        
        let previewImageView = UIImageView(image: imageThumbnail(image!, size: CGSizeMake(100, 100)))
        previewImageView.contentMode = .ScaleAspectFill
        return previewImageView
    }
    
    func userFinishedAuth(result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if (result.grantedPermissions == nil || error != nil || !FBSDKAccessToken.currentAccessToken().hasGranted("publish_actions")) {
            print("User did not grant publish permissions")
            return
        }
        
        createPost()
    }
    
    func createPost() {
        let parameters: [NSString:NSString] = [
            "caption": tool.caption ?? "",
            "link": tool.link?.absoluteString ?? "",
            "name": tool.linkTitle ?? "",
            "picture": tool.imageToShareURL?.absoluteString ?? "",
            "message": self.contentText,
            "type": "link"
        ]
        
        FBSDKGraphRequest(graphPath: "me/feed", parameters: parameters, HTTPMethod: "POST").startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            self.tool.finished?(sender: self.rootView, error: error)
        }
    }
    
}