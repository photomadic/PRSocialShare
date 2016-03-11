//
//  PRSocialShareFacebook.swift
//  ⌘ Praxent
//
//  Created by Albert Martin on 1/28/16.
//  Copyright © 2016 Praxent. All rights reserved.
//

import FBSDKLoginKit

class SocialShareFacebook: SocialShareTool {
    
    override init() {
        super.init()
        
        machine = SocialShareOutlet.Facebook
        title = ""
        composeView = FBComposeViewController()
    }
    
}

class FBComposeViewController: SocialShareComposeViewController {
    
    let permissions: [String] = ["publish_actions"]
    
    override func userFinishedPost() {
        
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
            "link": SocialShare.sharedInstance.sharedLink!.absoluteString,
            "name": SocialShare.sharedInstance.sharedLinkTitle!,
            "picture": SocialShare.sharedInstance.sharedLinkImage!.absoluteString,
            "message": self.contentText,
            "type": "link"
        ]
        
        FBSDKGraphRequest(graphPath: "me/feed", parameters: parameters, HTTPMethod: "POST").startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            SocialShareFacebook().finishedShare(self.rootView)
        }
    }
    
}