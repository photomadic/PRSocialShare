//
//  UIAlertController+SocialShare.swift
//  PRSocialShare
//
//  Created by Joel Costa on 11/03/16.
//  Copyright © 2016 Praxent. All rights reserved.
//

import UIKit

extension UIAlertController {

    /**
     To present a view controller with auto-dismiss functionality by selecting a pre-selected alert option
     
     - parameter title:              Alert action title
     - parameter view:               Parent view controller
     - parameter autoselectInterval: Auto-dismiss interval
     - parameter handler:            Handler to be called when auto-dismiss is trigger
     */
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