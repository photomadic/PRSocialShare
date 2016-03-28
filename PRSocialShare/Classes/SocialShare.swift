//
//  PRSocialShare.swift
//  ⌘ Praxent
//
//  Social sharing workflow for users on shared devices such as kiosks.
//
//  Created by Albert Martin on 9/25/15.
//  Copyright © 2015 Praxent. All rights reserved.
//

import FBSDKLoginKit
//import TwitterKit

public protocol SocialShareDelegate {
    func willPerformShare(vc: UIViewController, completion: (() -> Void)!)
}

public enum SocialShareError: ErrorType {
    case NoAvailableOutlets
}

public class SocialShare: NSObject {
    
    private var availableOutlets :[SocialShareTool]!

    public var facebookShare: SocialShareFacebook? {
        willSet {
            if facebookShare != nil {
                availableOutlets.removeObject(facebookShare!)
            }
        }
        didSet {
            if facebookShare != nil {
                availableOutlets.append(facebookShare!)
            }
        }
    }
    
    public var smsShare: SocialShareSMS? {
        willSet {
            if smsShare != nil {
                availableOutlets.removeObject(smsShare!)
            }
        }
        didSet {
            if smsShare != nil {
                availableOutlets.append(smsShare!)
            }
        }
    }
    
    public var twitterShare: SocialShareTwitter? {
        willSet {
            if twitterShare != nil {
                availableOutlets.removeObject(twitterShare!)
            }
        }
        didSet {
            if twitterShare != nil {
                availableOutlets.append(twitterShare!)
            }
        }
    }

    public var emailShare: SocialShareEmail? {
        willSet {
            if emailShare != nil {
                availableOutlets.removeObject(emailShare!)
            }
        }
        didSet {
            if emailShare != nil {
                availableOutlets.append(emailShare!)
            }
        }
    }
    
    public var delegate: SocialShareDelegate?
    public var title: String?
    
    override init() {
        super.init()
        availableOutlets = []
    }
    
    public func showFromViewController(vc: UIViewController, sender: UIControl) throws {
        
        guard availableOutlets?.count > 0 else {
            throw SocialShareError.NoAvailableOutlets
        }
        
        if availableOutlets.count == 1 {
            initiateShare(vc, outlet: availableOutlets[0])
        } else {
            try presentShareMenu(vc, sender: sender, options: availableOutlets)
        }
    }
    
    private func initiateShare(vc: UIViewController, outlet: SocialShareTool) {
        guard let willPerformShare = delegate?.willPerformShare else {
            return outlet.shareFromView(vc)
        }
        
        willPerformShare(vc, completion: { () -> Void in
            outlet.shareFromView(vc)
        })
    }
    
    private func presentShareMenu(vc: UIViewController, sender: UIControl, options: [SocialShareTool]) throws {
        guard options.count > 0 else {
            throw SocialShareError.NoAvailableOutlets
        }
        
        do {
            let shareViewController = try shareAlertController(vc, options: options)
            
            if (shareViewController.popoverPresentationController != nil) {
                shareViewController.modalPresentationStyle = .Popover
                let popover: UIPopoverPresentationController = shareViewController.popoverPresentationController!
                popover.sourceView = sender
                popover.sourceRect = sender.bounds
            }
            
            vc.presentViewController(shareViewController, animated: true, completion: nil)
        } catch {
            throw error
        }
    }
    
    private func shareAlertController(vc: UIViewController, options: [SocialShareTool]) throws -> UIAlertController {
        guard options.count > 0 else {
            throw SocialShareError.NoAvailableOutlets
        }
        
        let alertViewController :UIAlertController = UIAlertController(title: title, message: nil, preferredStyle: .ActionSheet)
        
        // Build the share menu from all available social outlets.
        for outlet: SocialShareTool in options {
            let action = UIAlertAction(title: outlet.actionTitle, style: .Default, handler: { (UIAlertAction) in
                self.initiateShare(vc, outlet: outlet)
            })
            alertViewController.addAction(action)
        }
        
        return alertViewController
    }
    
    public func destroySession() {
        FBSDKLoginManager().logOut()
//        twitterShare?.destroySession()
    }
    
}

