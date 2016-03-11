//
//  SocialShareTool.swift
//  PRSocialShare
//
//  Created by Joel Costa on 11/03/16.
//  Copyright © 2016 Praxent. All rights reserved.
//

import UIKit

public protocol SocialShareToolDelegate {
    func didPerformShare()
}

public class SocialShareTool: NSObject {
    
    var title: String?
    var machine: SocialShareOutlet?
    var validateRegex: String?
    var composeView: SocialShareComposeViewController?
    var delegate: SocialShareToolDelegate?
    
    
    override init() {
        super.init()
        guard composeView != nil else {
            return
        }
        
        composeView!.title = title
        
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
        composeView!.placeholder = "share_placeholder".localized
        
        composeView!.modalPresentationStyle = .OverCurrentContext;
        view.presentViewController(composeView!, animated: true, completion: nil)
    }
    
    func finishedShare(view: UIViewController) {
        delegate?.didPerformShare()
    }
    
}