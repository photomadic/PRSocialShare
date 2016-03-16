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
    
    var linkTitle: String?
    var image: UIImage?
    var imageLink: NSURL?
    
    override init() {
        super.init()
        
        let appID = getValueFromPlist("FacebookAppID")
        assert(appID != nil && !appID!.isEmpty, "Info.plist should have a dictionary SocialShareTool with a key/value FacebookAppID and should not be a empty string")
        FBSDKSettings.setAppID(appID)
        
        message = ""
        messagePlaceholder = "Write your message here".localized
        image = nil
        actionTitle = "Facebook".localized
        type = SocialShareType.Facebook
        composeView = FBComposeViewController(shareTool: self)
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
        let image = tool.image
        if image != nil {
            let previewImageView = UIImageView(image: imageThumbnail(image!, size: CGSizeMake(100, 100)))
            previewImageView.contentMode = .ScaleAspectFill
            return previewImageView
        }
        return nil
    }
    
    func userFinishedAuth(result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if (result.grantedPermissions == nil || error != nil || !FBSDKAccessToken.currentAccessToken().hasGranted("publish_actions")) {
            print("User did not grant publish permissions")
            return
        }
        
        FBSDKGraphRequest(graphPath: "me?fields=name,email", parameters: nil).startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            print(result)
        }
        
        createPost()
    }
    
    func createPost() {
        let parameters: [NSString:NSString] = [
            "caption": "powered_by".localized,
            "link": (tool.link?.absoluteString)!,
            "name": (tool.linkTitle)!,
            "picture": (tool.imageLink?.absoluteString)!,
            "message": self.contentText,
            "type": "link"
        ]
        
        FBSDKGraphRequest(graphPath: "me/feed", parameters: parameters, HTTPMethod: "POST").startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            self.tool.finishedShare(self.rootView, error: error)
        }
    }
    
}