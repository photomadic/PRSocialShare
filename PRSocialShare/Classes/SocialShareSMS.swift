//
//  PRSocialShareSMS.swift
//  ⌘ Praxent
//
//  Created by Albert Martin on 1/28/16.
//  Copyright © 2016 Praxent. All rights reserved.
//

import UIKit

public enum SocialShareSMSError: ErrorType {
    case InvalidUserInput
    case InvalidSharedLink
    case InvalidFromNumber
    case InvalidSID
    case InvalidToken
    case InvalidResponse(response: NSHTTPURLResponse)
}

public class SocialShareSMS: SocialShareTool, UITextFieldDelegate {
    
    /// Link to be sent on sms
    var link: NSURL?
    
    private var twilioSID :String?
    private var twilioToken :String?
    private var fromNumber :String?
    
    var alertMessageTitle :String = "Phone number".localized
    var alertMessageBody :String = "Please insert the phone number".localized
    
    override init() {
        super.init()
        type = SocialShareType.SMS
        
        fromNumber = getValueFromPlist("TwilioNumber")
        assert(fromNumber != nil && !fromNumber!.isEmpty, "Info.plist should have a dictionary SocialShareTool with a key/value TwilioNumber and should not be a empty string")
        
        twilioSID = getValueFromPlist("TwilioSID")
        assert(twilioSID != nil && !twilioSID!.isEmpty, "Info.plist should have a dictionary SocialShareTool with a key/value TwilioSID and should not be a empty string")
        
        twilioToken = getValueFromPlist("TwilioToken")
        assert(twilioToken != nil && !twilioToken!.isEmpty, "Info.plist should have a dictionary SocialShareTool with a key/value TwilioToken and should not be a empty string")
    }
    
    override func shareFromView(view: UIViewController) {
        let alert = UIAlertController(title: alertMessageTitle.localized, message: alertMessageBody.localized, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "Send".localized, style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            do {
                let request = try self.buildTwilioRequest(alert.textFields![0].text!, message: self.message)
                NSURLSession.sharedSession().dataTaskWithRequest(request!, completionHandler: { (data, response, error) in
                    let urlResponse :NSHTTPURLResponse = response as! NSHTTPURLResponse
                    if error == nil && urlResponse.statusCode != 200 {
                        self.finished?(sender:view, error: SocialShareSMSError.InvalidResponse(response: urlResponse))
                    } else {
                        self.finished?(sender:view, error: error)
                    }
                }).resume()
            } catch {
                self.finished?(sender:view, error: error)
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: UIAlertActionStyle.Cancel, handler: nil))
        
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.delegate = self
            textField.keyboardType = .DecimalPad
        })
        
        view.presentViewController(alert, animated: true, completion: nil)
    }
    
    func buildTwilioRequest(phone: String, message: String?) throws -> NSMutableURLRequest? {
        guard message != nil else {
            throw SocialShareSMSError.InvalidUserInput
        }
        
        guard fromNumber != nil else {
            throw SocialShareSMSError.InvalidFromNumber
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://\(twilioSID!):\(twilioToken!)@api.twilio.com/2010-04-01/Accounts/\(twilioSID!)/SMS/Messages")!)
        request.HTTPMethod = "POST"
        request.HTTPBody = "From=\(fromNumber!)&To=\(phone)&Body=\(message!)".dataUsingEncoding(NSUTF8StringEncoding)
        
        return request
    }
    
    ///
    /// Formats a phone number with proper hyphens and area code enclosure.
    /// Credit: http://stackoverflow.com/a/26600259
    ///
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
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
