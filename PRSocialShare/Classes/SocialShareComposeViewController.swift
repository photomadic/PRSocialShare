//
//  SocialShareComposeViewController.swift
//  PRSocialShare
//
//  Created by Joel Costa on 11/03/16.
//  Copyright © 2016 Praxent. All rights reserved.
//

import UIKit
import Social

public class SocialShareComposeViewController: SLComposeServiceViewController {
    
    var preview: UIImageView = UIImageView(frame: CGRectMake(0, 0, 100, 100))
    var shareMessage: String = ""
    var rootView: UIViewController = UIViewController()
    
    func userFinishedPost() {
        return
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        textView.text = shareMessage
        validateContent()
    }
    
    override public func loadPreviewView() -> UIView! {
        preview.contentMode = .ScaleAspectFill
        preview.clipsToBounds = true
        preview.image = SocialShare.sharedInstance.sharedPreview
        
        preview.layer.borderWidth = 1
        preview.layer.borderColor = UIColor.grayColor().CGColor
        
        preview.removeConstraints(preview.constraints)
        
        return preview
    }
    
    override public func didSelectCancel() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override public func didSelectPost() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: userFinishedPost)
    }
    
}