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
import TwitterKit

@objc public protocol SocialShareDelegate {
    
    func didPerformShare()
    
    optional func willPerformShare(vc: UIViewController, completion: (() -> Void)!)
    optional func shareShouldContinue() -> Bool
}

public enum SocialShareError: ErrorType {
    case NoAvailableOutlets
}

public enum SocialShareOutlet: String {
    case Facebook
    case SMS
    case Twitter
    case Email
    
    static let allValues = [Facebook, SMS, Twitter, Email]
}

public class SocialShare: NSObject, SocialShareToolDelegate {
    
    private(set) var facebookShare: SocialShareFacebook!
    private(set) var smsShare: SocialShareSMS!
    private(set) var twitterShare: SocialShareTwitter!
    
    private var availableOutlets :[SocialShareTool]!
    
    /// Allows the social share object to be accessed as a global singleton.
    public static let sharedInstance = SocialShare()
    
    public var delegate: SocialShareDelegate?
    public var sharedLink: NSURL?
    public var sharedLinkTitle: String?
    public var sharedLinkImage: NSURL?
    public var sharedImage: UIImage?
    public var sharedPreview: UIImage?
    public var sharedMessage: [NSString: NSString]?
    public var shareGroup: NSMutableDictionary = NSMutableDictionary()
    
    public var title: String?
    
    convenience init(outlets: [SocialShareOutlet]) throws {
        self.init()
        
        guard outlets.count > 0 else {
            throw SocialShareError.NoAvailableOutlets
        }
        
        availableOutlets = []
        
        if outlets.contains(SocialShareOutlet.Facebook) {
            facebookShare = SocialShareFacebook()
            facebookShare.delegate = self
            availableOutlets.append(facebookShare)
        }
        
        if outlets.contains(SocialShareOutlet.SMS) {
            smsShare = SocialShareSMS()
            smsShare.delegate = self
            availableOutlets.append(smsShare)
        }
        
        if outlets.contains(SocialShareOutlet.Twitter) {
            twitterShare = SocialShareTwitter()
            twitterShare.delegate = self
            availableOutlets.append(twitterShare)
        }
    }
    
    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "destroySession", name:"SocialShareSessionDestroy", object: nil)
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
            let action = UIAlertAction(title: outlet.title, style: .Default, handler: { (UIAlertAction) in
                self.initiateShare(vc, outlet: outlet)
            })
            alertViewController.addAction(action)
        }
        
        return alertViewController
    }
    
    public func destroySession() {
        shareGroup.removeAllObjects()
        
        FBSDKLoginManager().logOut()
        
        if (Twitter.sharedInstance().sessionStore.session() != nil) {
            let uid = Twitter.sharedInstance().sessionStore.session()!.userID
            Twitter.sharedInstance().sessionStore.logOutUserID(uid)
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("SocialShareSessionChange", object: nil)
    }
    
    public func didPerformShare() {
        delegate?.didPerformShare()
    }
    
}

