//
//  SocialShareTool.swift
//  PRSocialShare
//
//  Created by Joel Costa on 11/03/16.
//  Copyright © 2016 Praxent. All rights reserved.
//

import UIKit

/// Share tool types
public enum SocialShareType: String {
    case Facebook
    case SMS
    case Twitter
    case Email
    
    static let allValues = [Facebook, SMS, Twitter, Email]
}

/**
 *  Protocol to be performed
 */
public protocol SocialShareToolDelegate {
    /**
     Method to be called after share is finished
     
     - parameter error: will be a non nil value if the message was not published
     */
    func didPerformShare(error: ErrorType?)
}

/// Generic class to be inherited by specific tools
public class SocialShareTool: NSObject {
    
    var link: NSURL?
    
    /// Message to be sent
    var message: String?
    /// Text to used as placeholder on text view
    var messagePlaceholder: String?
    /// Text to be used on context menu
    var actionTitle: String?
    /// Social share tool type
    var type: SocialShareType?
    /// Regular expression to validate user input
    var validateRegex: String?
    /// View controller composer to be displayed (if applicable)
    var composeView: SocialShareComposeViewController?
    /// Delegate to be called as soon as share is finished
    var delegate: SocialShareToolDelegate?
    
    override init() {
        super.init()
        
        guard composeView != nil else {
            return
        }
        
        composeView?.shareTool = self
    }
    
    /**
     Method to be called to validate user input
     
     - parameter input: user text input
     
     - returns: returns true is regular expression is valid with user input, false if not
     */
    func validate(input: String) -> Bool {
        if validateRegex == nil {
            return true
        }
        
        let valid = input.rangeOfString(validateRegex!, options: .RegularExpressionSearch)
        return (valid != nil)
    }
    
    /**
     Show compose view controller
     
     - parameter view: parent view controller
     */
    func shareFromView(view: UIViewController) {
        guard composeView != nil else {
            return
        }
        
        composeView!.rootView = view
        composeView!.modalPresentationStyle = .OverCurrentContext;
        view.presentViewController(composeView!, animated: true, completion: nil)
    }
    
    // #MARK: - SocialShareToolDelegate
    
    func finishedShare(view: UIViewController, error: ErrorType?) {
        delegate?.didPerformShare(error)
    }
    
}