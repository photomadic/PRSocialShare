//
//  PRSocialShareSMS.swift
//  ⌘ Praxent
//
//  Created by Albert Martin on 1/28/16.
//  Copyright © 2016 Praxent. All rights reserved.
//

import UIKit

class SocialShareTextDelegate: NSObject, UITextFieldDelegate {
    ///
    /// Formats a phone number with proper hyphens and area code enclosure.
    /// Credit: http://stackoverflow.com/a/26600259
    ///
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        let components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        
        let decimalString = components.joinWithSeparator("") as NSString
        let length = decimalString.length
        let hasLeadingOne = length > 0 && decimalString.substringToIndex(1) == "1"
        
        if length == 0 || (length > 10 && !hasLeadingOne) || length > 11 {
            let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
            return (newLength > 10) ? false : true
        }
        var index = 0 as Int
        let formattedString = NSMutableString()
        
        if hasLeadingOne {
            formattedString.appendString("1 ")
            index += 1
        }
        if (length - index) > 3 {
            let areaCode = decimalString.substringWithRange(NSMakeRange(index, 3))
            formattedString.appendFormat("(%@) ", areaCode)
            index += 3
        }
        if length - index > 3 {
            let prefix = decimalString.substringWithRange(NSMakeRange(index, 3))
            formattedString.appendFormat("%@-", prefix)
            index += 3
        }
        
        let remainder = decimalString.substringFromIndex(index)
        formattedString.appendString(remainder)
        textField.text = formattedString as String
        return false
    }
}

enum SocialShareSMSError: ErrorType {
    case InvalidUserInput
    case InvalidSharedLink
}

class SocialShareSMS: SocialShareTool {
    
    var twilioSID :String!
    var twilioToken :String!
    var fromNumber :String!
    
    override init() {
        super.init()
        
        machine = SocialShareOutlet.SMS
        title = ""
    }
    
    override func shareFromView(view: UIViewController) {
        let alert = UIAlertController(title: "where_to_send".localized, message: "sms_gallery".localized, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "Send".localized, style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            do {
                let request = try self.buildTwilioRequest(alert.textFields![0].text!)
                NSURLSession.sharedSession().dataTaskWithRequest(request!, completionHandler: { (data, response, error) in
                    self.finishedShare(view)
                }).resume()
            } catch {
                self.finishedShare(view)
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: UIAlertActionStyle.Cancel, handler: nil))
        
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.delegate = SocialShareTextDelegate()
            textField.keyboardType = .DecimalPad
        })
        
        view.presentViewController(alert, animated: true, completion: nil)
    }
    
    func buildTwilioRequest(phone: String) throws -> NSMutableURLRequest? {
        let userInput = SocialShare.sharedInstance.sharedMessage?["sms"]
        guard userInput != nil else {
            throw SocialShareSMSError.InvalidUserInput
        }
        
        let sharedLink = SocialShare.sharedInstance.sharedLink
        
        guard userInput != nil && sharedLink != nil else {
            throw SocialShareSMSError.InvalidSharedLink
        }
        
        let message = "\(userInput) \(SocialShare.sharedInstance.sharedLink)"
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://\(twilioSID):\(twilioToken)@api.twilio.com/2010-04-01/Accounts/\(twilioSID)/SMS/Messages")!)
        request.HTTPMethod = "POST"
        request.HTTPBody = "From=\(fromNumber)&To=\(phone)&Body=\(message)".dataUsingEncoding(NSUTF8StringEncoding)
        
        return request
    }
    
}
