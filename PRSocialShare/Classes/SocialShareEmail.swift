//
//  SocialShareEmail.swift
//  PRSocialShare
//
//  Created by Joel Costa on 15/03/16.
//  Copyright © 2016 Praxent. All rights reserved.
//

import UIKit

public protocol SocialShareEmailDelegate: SocialShareToolDelegate {
    func sendEmail(email: String) throws
}

public enum SocialShareEmailError: ErrorType {
    case InvalidEmail
}

public class SocialShareEmail: SocialShareTool {
    
    var alertTitle: String = "Send email".localized
    var alertMessage: String = "Please insert the email address".localized
    
    override init() {
        super.init()

        type = SocialShareType.Email
        validateRegex = "^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$"
    }
    
    override func shareFromView(view: UIViewController) {
        let alert = UIAlertController(title: alertTitle.localized, message: alertMessage.localized, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Send".localized, style: .Default, handler: { (action: UIAlertAction!) in
            
            let email = alert.textFields![0].text!
            if !self.validate(email) {
                self.delegate?.didPerformShare(SocialShareEmailError.InvalidEmail)
                return
            }
            
            do {
                try (self.delegate as! SocialShareEmailDelegate).sendEmail(email)
                self.delegate?.didPerformShare(nil)
            } catch {
                self.delegate?.didPerformShare(error)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = self.messagePlaceholder
            textField.keyboardType = .EmailAddress
        })
        
        view.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
}