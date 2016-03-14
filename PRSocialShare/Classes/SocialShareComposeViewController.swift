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
    
    func userFinishedPost() {
        return
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        textView.text = shareTool.message
        validateContent()
    }
    
    override public func loadPreviewView() -> UIView! {
        let image = shareTool.image
        if image != nil {
            let previewImageView = UIImageView(image: imageThumbnail(image!, size: CGSizeMake(100, 100)))
            previewImageView.contentMode = .ScaleAspectFill
            return previewImageView
        }
        return nil
    }
    
    override public func didSelectCancel() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override public func didSelectPost() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: userFinishedPost)
    }
    
    private func imageThumbnail(image: UIImage, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
}