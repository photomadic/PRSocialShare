//
//  SocialShareTool.swift
//  PRSocialShare
//
//  Created by Joel Costa on 11/03/16.
//  Copyright © 2016 Praxent. All rights reserved.
//

import UIKit

public protocol SocialShareToolDelegate {
    func didPerformShare(error: ErrorType?)
}

public class SocialShareTool: NSObject {
    
    var link: NSURL?
    var linkTitle: String?
    var message: String?
    var messagePlaceholder: String?
    var image: UIImage?
    var imageLink: NSURL?
    
    var actionTitle: String?
    var type: SocialShareOutlet?
    var validateRegex: String?
    var composeView: SocialShareComposeViewController?
    var delegate: SocialShareToolDelegate?
    
    
    override init() {
        super.init()
        
        guard composeView != nil else {
            return
        }
        
        composeView?.shareTool = self
        
//        if (SocialShare.sharedInstance.sharedMessage != nil && SocialShare.sharedInstance.sharedMessage![machine!] != nil) {
//            composeView!.shareMessage = SocialShare.sharedInstance.sharedMessage![machine] as! String
//        }
    }
    
    func validate(input: String) -> Bool {
        if validateRegex == nil {
            return true
        }
        
        let valid = input.rangeOfString(validateRegex!, options: .RegularExpressionSearch)
        return (valid != nil)
    }
    
    func shareFromView(view: UIViewController) {
        guard composeView != nil else {
            return
        }
        
        composeView!.rootView = view
        composeView!.placeholder = messagePlaceholder        
        composeView!.modalPresentationStyle = .OverCurrentContext;
        view.presentViewController(composeView!, animated: true, completion: nil)
    }
    
    func finishedShare(view: UIViewController, error: ErrorType?) {
        delegate?.didPerformShare(error)
    }
    
}