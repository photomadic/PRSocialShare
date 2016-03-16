# PRSocialShare
Social sharing workflow for users on shared devices such as kiosks

## Installation

Add the following pod reqirements to podfile

    pod 'PRSocialShare', :git => 'https://github.com/praxent/PRSocialShare.git'

## Configuration 

To be able to use the library some keys/tokens should be added to Info.plist. They are mandatory if and only if the specific service will be used.

Add the following to Info.Plist (remove any service that will not be used):

	<key>SocialShareTool</key>
	<dict>
		<key>FacebookAppID</key>
		<string>[INSERT_HERE_FACEBOOK_APP_ID]</string>
		<key>TwilioNumber</key>
		<string>[INSERT_HERE_TWILIO_FROM_NUMBER]</string>
		<key>TwilioSID</key>
		<string>[INSERT_HERE_TWILIO_SID]</string>
		<key>TwilioToken</key>
		<string>[INSERT_HERE_TWILIO_TOKEN]</string>
		<key>TwitterConsumer</key>
		<string>[INSERT_HERE_TWITTER_CONSUMER_KEY]</string>
		<key>TwitterSecret</key>
		<string>[INSERT_HERE_TWITTER_SECRET_KEY]</string>
	</dict>

If you need to use Facebook there are a few more configurations to be added to Info.plist:

	<key>LSApplicationQueriesSchemes</key>
	<array>
    <string>fbapi</string>
		<string>fbapi20130214</string>
		<string>fbapi20130410</string>
		<string>fbapi20130702</string>
		<string>fbapi20131010</string>
		<string>fbapi20131219</string>
		<string>fbapi20140410</string>
		<string>fbapi20140116</string>
		<string>fbapi20150313</string>
		<string>fbapi20150629</string>
		<string>fbauth</string>
		<string>fbauth2</string>
		<string>fb-messenger-api20140430</string>
	</array>
	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleTypeRole</key>
			<string>Editor</string>
			<key>CFBundleURLName</key>
			<string>[INSERT_HERE_APP_NAME]</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>fb[INSERT_HERE_FACEBOOK_APP_ID] </string>
			</array>
		</dict>
	</array>	

## How to use

Add SocialShareDelegate and SocialShareToolDelegate and its methods to view controller:

    class ViewController: UIViewController, SocialShareDelegate, SocialShareToolDelegate {
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
  
Add an action associated with a UIControl:
  
    @IBAction func showButtonDidTouch(sender: AnyObject) {
      /// [...]
    }
  
Initialize the values to be shared:

    let imageToShare: UIImage = SET_IMAGE_TO_SHARE_HERE
    let imageLink: NSURL = NSURL(string: "URL_PATH_TO_EXTERNAL_IMAGE")!

Initialize  'SocialShare' library:

    let socialShare = SocialShare()
    socialShare.delegate = self

Optional: Add Facebook tool option:

    let facebookShare = SocialShareFacebook()
    facebookShare.actionTitle = "Facebook"
    facebookShare.image = imageToShare
    facebookShare.delegate = self
    socialShare.facebookShare = facebookShare

Optional: Add Twitter tool option:

    let twitterShare = SocialShareTwitter()
    twitterShare.actionTitle = "Twitter"
    twitterShare.image = imageToShare
    twitterShare.imageLink = imageLink
    twitterShare.destroySession()
    socialShare.twitterShare = twitterShare

Optional: Add Twilio tool option:

    let smsShare = SocialShareSMS()
    smsShare.actionTitle = "SMS"
    smsShare.message = "Hello!"
    smsShare.link = imageLink
    socialShare.smsShare = smsShare

Optional: Add email tool option:

    let emailShare = SocialShareEmail()
    emailShare.actionTitle = "Email"
    socialShare.emailShare = emailShare

Finally display view controller to the user. It will use the actionsheet if on iPhone and alert popover if on iPad. If only one option is available 
the actionsheet/alert will not be shown, instead the view for that option is displayed.

    do {
        // Display view controller
        try socialShare.showFromViewController(self, sender: sender as! UIControl)
        
    } catch {
        print("\(error)")
    }
