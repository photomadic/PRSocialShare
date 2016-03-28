//
//  SocialShareEmail.swift
//  PRSocialShare
//
//  Created by Joel Costa on 15/03/16.
//  Copyright © 2016 Praxent. All rights reserved.
//

import UIKit

/**
 Email social share errors
 
 - InvalidEmail: Thrown when email is invalid (string does not comply with regular expression)
 */
public enum SocialShareEmailError: ErrorType {
    case InvalidEmail
}

/// Email social share tool
public class SocialShareEmail: SocialShareTool {
    
    /// Text to be shown on alert controller title
    var alertTitle: String = "Send email".localized
    /// Text to be shown on alert controller message
    var alertMessage: String = "Please insert the email address".localized
    
    var alertText: String = ""
    
    var alertSendButtonText: String = "Send".localized
    
    public var sendEmail: ((email: String) -> (Void))?
    
    override init() {
        super.init()

        type = SocialShareType.Email
        validateRegex = "^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$"
    }
    
    override func shareFromView(view: UIViewController) {
        assert(self.sendEmail != nil, "Delegate or closure must be provided to be able to share email")
        
        let alert = UIAlertController(title: alertTitle.localized, message: alertMessage.localized, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: alertSendButtonText, style: .Default, handler: { (action: UIAlertAction!) in
            
            let email = alert.textFields![0].text!
            if !self.validate(email) {
                self.finished?(sender: nil, error: SocialShareEmailError.InvalidEmail)
                return
            }

            if self.sendEmail != nil {
                self.sendEmail?(email: email)
            }
            self.finished?(sender: nil, error: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = self.messagePlaceholder
            textField.keyboardType = .EmailAddress
            textField.text = self.alertText
        })
        
        view.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
}