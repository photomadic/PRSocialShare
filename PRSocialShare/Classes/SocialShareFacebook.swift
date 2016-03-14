//
//  PRSocialShareFacebook.swift
//  ⌘ Praxent
//
//  Created by Albert Martin on 1/28/16.
//  Copyright © 2016 Praxent. All rights reserved.
//

import FBSDKLoginKit

class SocialShareFacebook: SocialShareTool {
    
    var appID :String?
    
    override init() {
        super.init()
        
        message = ""
        messagePlaceholder = "Write your message here".localized
        image = nil
        actionTitle = "Facebook".localized
        
        type = SocialShareOutlet.Facebook
        composeView = FBComposeViewController(shareTool: self)
    }
    
}

class FBComposeViewController: SocialShareComposeViewController {
    
    let permissions: [String] = ["publish_actions"]
    
    convenience init(shareTool: SocialShareTool) {
        self.init()
        self.shareTool = shareTool
    }
    
    override func userFinishedPost() {
        let tool = shareTool as! SocialShareFacebook
        guard ((tool.appID?.isEmpty) != nil) else {
            print("Invalid facebook app ID")
            return
        }
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            createPost()
            return
        }
        
        let fblogin = FBSDKLoginManager()
        fblogin.loginBehavior = .Web
        fblogin.logInWithPublishPermissions(permissions, fromViewController: self.presentingViewController, handler: userFinishedAuth)
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
            "link": (shareTool.link?.absoluteString)!,
            "name": (shareTool.linkTitle)!,
            "picture": (shareTool.imageLink?.absoluteString)!,
            "message": self.contentText,
            "type": "link"
        ]
        
        FBSDKGraphRequest(graphPath: "me/feed", parameters: parameters, HTTPMethod: "POST").startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            self.shareTool.finishedShare(self.rootView, error: error)
        }
    }
    
}