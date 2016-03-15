//
//  String+SocialShare.swift
//  PRSocialShare
//
//  Created by Joel Costa on 11/03/16.
//  Copyright © 2016 Praxent. All rights reserved.
//

import Foundation

extension String {
    /// Property to make localization simpler
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
}