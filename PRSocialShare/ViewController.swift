//
//  ViewController.swift
//  PRSocialShare
//
//  Created by Joel Costa on 11/03/16.
//  Copyright © 2016 Praxent. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SocialShareDelegate {

    @IBOutlet weak var image: UIImageView!
    
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
            socialShare.delegate = self
            
            // MARK: - Facebook configuration
            socialShare.facebookShare.actionTitle = "Facebook"
            // Facebook credentials - mandatory!
            socialShare.facebookShare.appID = ""
            // Facebook dummy data
            socialShare.facebookShare.image = image.image

            // MARK: - Twitter configuration
            socialShare.twitterShare.actionTitle = "Twitter"
            // Twitter credentials - these fields are mandatory!
            socialShare.twitterShare.consumerKey = ""
            socialShare.twitterShare.secretKey = ""
            // Twitter dummy data
            socialShare.twitterShare.image = image.image

            // MARK: - Twilio configuration
            socialShare.smsShare.actionTitle = "SMS"
            //Twilio credentials all - these fields are mandatory!
            socialShare.smsShare.twilioSID = ""
            socialShare.smsShare.twilioToken = ""
            socialShare.smsShare.fromNumber = ""
            // Twilio dummy data
            socialShare.smsShare.image = image.image
            socialShare.smsShare.message = "Hello!"
            socialShare.smsShare.link = NSURL(string: "http://google.com")
            
            // MARK: -
            
            // Display view controller
            try socialShare.showFromViewController(self, sender: sender as! UIControl)
        } catch {
            print("\(error)")
        }
    }
    
    func willPerformShare(vc: UIViewController, completion: (() -> Void)!) {
        completion()
    }
    
    func didPerformShare(error: ErrorType?) {
        if (error != nil) {
            print("\(error)")
        } else {
            print("Did perform share with success!")
        }
    }
    
}

