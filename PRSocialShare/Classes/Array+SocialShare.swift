//
//  Array+SocialShare.swift
//  PRSocialShare
//
//  Created by Joel Costa on 15/03/16.
//  Copyright © 2016 Praxent. All rights reserved.
//

import Foundation

extension Array where Element : Equatable {

    /**
     Method remove an item from the array by comparing objects
     
     - parameter object: The object to be removed
     */
    mutating func removeObject(object : Generator.Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}