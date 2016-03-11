//
//  ViewController.swift
//  PRSocialShare
//
//  Created by Joel Costa on 11/03/16.
//  Copyright © 2016 Praxent. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SocialShareDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
         super.viewDidAppear(animated)
    }

    @IBAction func showButtonDidTouch(sender: AnyObject) {
        do {
            let socialShare = try SocialShare(outlets: [SocialShareOutlet.Twitter, SocialShareOutlet.Facebook, SocialShareOutlet.SMS])
            
            socialShare.facebookShare.title = "Facebook"
            socialShare.twitterShare.title = "Twitter"
            socialShare.smsShare.title = "SMS"
            
            socialShare.delegate = self
            
            try socialShare.showFromViewController(self, sender: sender as! UIControl)
        } catch {
            print("\(error)")
        }
    }
    
    func didPerformShare() {
        
    }
    
}

