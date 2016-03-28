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
        let imageLink: NSURL = NSURL(string: "https://pixabay.com/static/uploads/photo/2015/10/01/21/39/background-image-967820_960_720.jpg")!
        
        let fileURL = (NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]).URLByAppendingPathComponent("image.png", isDirectory: false)
        try! UIImagePNGRepresentation(UIImage(named: "praxent-agile-scrum-process")!)?.writeToURL(fileURL, options: NSDataWritingOptions.AtomicWrite)
        
        let socialShare = SocialShare()
        socialShare.delegate = self
        
        // MARK: - Facebook configuration
        
        let facebookShare = SocialShareFacebook()
        facebookShare.actionTitle = "Facebook"
        facebookShare.imageURL = fileURL
        facebookShare.imageToShareURL = imageLink
        socialShare.facebookShare = facebookShare
        
                
        // MARK: - Twitter configuration
        
        let twitterShare = SocialShareTwitter()
        twitterShare.actionTitle = "Twitter"
        twitterShare.imageURL = fileURL
        twitterShare.imageToShareURL = fileURL
        socialShare.twitterShare = twitterShare
        
        
        // MARK: - Twilio configuration
        
        let smsShare = SocialShareSMS()
        smsShare.actionTitle = "SMS"
        smsShare.message = "Hello!"
        smsShare.link = imageLink
        socialShare.smsShare = smsShare
        
        
        // MARK: - Email configuration
        
        let emailShare = SocialShareEmail()
        emailShare.actionTitle = "Email"
        socialShare.emailShare = emailShare
        
        do {
            // Display view controller
            try socialShare.showFromViewController(self, sender: sender as! UIControl)
            
        } catch {
            print("\(error)")
        }
    }
    
    // #MARK: - SocialShareDelegate
    
    func willPerformShare(vc: UIViewController, completion: (() -> Void)!) {
        completion()
    }
    
    // #MARK: - SocialShareToolDelegate
    
    func didPerformShare(error: ErrorType?) {
        if (error != nil) {
            print("\(error)")
        } else {
            print("Did perform share with success!")
        }
    }
    
}

