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

public enum SocialShareOutlet: String {
    case Facebook = "facebook"
    case SMS = "sms"
    case Twitter = "twitter"
}

public class SocialShare: NSObject {
    
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
    
    public var outlets: [SocialShareOutlet] = [.Facebook, .SMS, .Twitter]
    
    public var title = "share_title".localized
    public var shareActions: UIAlertController = UIAlertController()
    
    private let constructor: [String: SocialShareTool] = [
        "facebook": SocialShareFacebook(),
        "sms": SocialShareSMS(),
        "twitter": SocialShareTwitter()
    ]
    
    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "destroySession", name:"SocialShareSessionDestroy", object: nil)
    }
    
    public func showMenuFromViewController(vc: UIViewController, sender: UIControl) {

        // Require at least one item to be selected.
        if (shareGroup.count < 1) {
            print("Less than one photo is selected. Share menu will not be shown.")
            return
        }
        
        shareActions = UIAlertController(title: title, message: "", preferredStyle: .ActionSheet)
        
        // Build the share menu from all available social outlets.
        for outlet in outlets {
            let socialOutlet: SocialShareTool = constructor[outlet.rawValue]!
            let action = UIAlertAction(title: socialOutlet.title, style: .Default, handler: { (UIAlertAction) in
                print("Initiating share for \(socialOutlet.title)")
                self.initiateShare(vc, outlet: socialOutlet)
            })
            shareActions.addAction(action)
        }
        
        presentShareMenu(vc, sender: sender)
    }
    
    private func initiateShare(vc: UIViewController, outlet: SocialShareTool) {
        if delegate != nil {
            return outlet.shareFromView(vc)
        }
        
        delegate!.beforeShare(vc, completion: { () -> Void in
            outlet.shareFromView(vc)
        })
    }
    
    private func presentShareMenu(vc: UIViewController, sender: UIControl) {
        let popover: UIPopoverPresentationController = shareActions.popoverPresentationController!
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        vc.presentViewController(shareActions, animated: true, completion: nil)
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
    
}

public protocol SocialShareDelegate {
    func beforeShare(vc: UIViewController, completion: (() -> Void)!)
    func shareShouldContinue() -> Bool
    func afterShare()
}

public protocol SocialShareTool {
    var title: String { get set }
    var machine: String { get set }
    var validateRegex: String? { get set }
    var composeView: SocialShareComposeViewController? { get set }
    
    func shareFromView(view: UIViewController)
    func validate(input: String) -> Bool
    func finishedShare(view: UIViewController)
}

public extension SocialShareTool {
    
    init() {
        self.init()
        if composeView == nil {
            return
        }
        
        composeView!.title = title
        
        if (SocialShare.sharedInstance.sharedMessage != nil && SocialShare.sharedInstance.sharedMessage![machine] != nil) {
            composeView!.shareMessage = SocialShare.sharedInstance.sharedMessage![machine] as! String
        }
    }
    
    func validate(input: String) -> Bool {
        if validateRegex == nil {
            return true
        }
        
        let valid = input.rangeOfString(validateRegex!, options: .RegularExpressionSearch)
        return (valid != nil)
    }
    
    func shareFromView(view: UIViewController) {
        if composeView == nil {
            return
        }
        
        composeView!.rootView = view
        composeView!.placeholder = "share_placeholder".localized
        
        composeView!.modalPresentationStyle = .OverCurrentContext;
        view.presentViewController(composeView!, animated: true, completion: nil)
    }
    
    func finishedShare(view: UIViewController) {
        SocialShare.sharedInstance.delegate?.afterShare()
    }
    
}

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

extension UIAlertController {
    
    public func showWithAutoselect(title: String, view: UIViewController, autoselectInterval: UInt64, handler: ((UIAlertAction) -> Void)?) {
        self.addAction(UIAlertAction(title:title, style: .Default, handler: handler))
        
        dispatch_async(dispatch_get_main_queue()) {
            view.presentViewController(self, animated: true, completion: nil)
        }
        
        // Allow for disabling of the auto-dismiss option.
        if (autoselectInterval <= 0) {
            return
        }
        
        // Automatically dismiss the alert dialogue after _n_ seconds.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * autoselectInterval)), dispatch_get_main_queue()) {
            handler
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
