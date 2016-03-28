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

/// Generic class to be inherited by specific tools
public class SocialShareTool: NSObject {
    
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
    
    var finished: ((sender: AnyObject?, error: ErrorType?)->())?
    
    /// Dictionary on Info.plist with social share tools settings
    private var settings: [String: String]?
    
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
    
    /**
     To get settings values from info.plist
     
     - parameter key: setting key to retrieve the value
     */
    func getValueFromPlist(key: String) -> String? {
        if settings == nil {
            let infoData = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Info", ofType: "plist")!) as! [String: AnyObject]
            settings = infoData["SocialShareTool"] as? [String: String]
        }
        
        return settings?[key]
    }
    
}