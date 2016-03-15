//
//  SocialShareComposeViewController.swift
//  PRSocialShare
//
//  Created by Joel Costa on 11/03/16.
//  Copyright © 2016 Praxent. All rights reserved.
//

import UIKit
import Social
import ImageIO

public class SocialShareComposeViewController: SLComposeServiceViewController {
    
    var shareTool: SocialShareTool!
    var rootView: UIViewController = UIViewController()
    
    public convenience init(shareTool: SocialShareTool) {
        self.init()
        self.shareTool = shareTool
    }
    
    func userFinishedPost() {
        return
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        textView.text = shareTool.message
        placeholder = shareTool.messagePlaceholder
        validateContent()
    }
    
    override public func didSelectCancel() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override public func didSelectPost() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: userFinishedPost)
    }
    
    func imageThumbnail(image: UIImage, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
}