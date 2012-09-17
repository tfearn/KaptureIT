//
//  Globals.h
//  Hedge360
//
//  Created by Todd Fearn on 12/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// Facebook
#define kFacebookAppID				@"263635200406238"
#define kFacebookAccessTokenKey		@"FBAccessTokenKey"
#define kFacebookExpirationDateKey	@"FBExpirationDateKey"

// Twitter
#define kTwitterConsumerKey         @"0xzMziiYtv6FUfUL3Kxg"
#define kTwitterConsumerSecret      @"0oZxjspsl1Kbfw6fGb4sSQAC7JywVRRgsdMjijGixs"

// Other Keys
#define kFacebookUsernameKey        @"fb_username"

// Parse.com does not allow push notification channels to begin with a number.  If a channel name (user.objectId)
// starts with a number, we put this prefix in front
#define kNotificationChannelPrefix  @"channel"

// Notifications
#define kNotificationDoLogin        @"NotificationDoFacebookLogin"
#define kNotificationLoginComplete  @"NotificationLoginComplete"

// Urls
#define kUrlFacebookPicture         @"https://graph.facebook.com/%@/picture"

// Macros
#ifndef NDEBUG
#define MyLog(s, ... ) NSLog(@"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define MyLog( s, ... )
#endif

#define LogFlurryEvent_ViewDidLoad() 	NSDictionary *flurryDict = [NSDictionary dictionaryWithObjectsAndKeys:NSStringFromClass([self class]), @"viewname", nil]; \
										[FlurryAPI logEvent:@"viewDidLoad" withParameters:flurryDict]



// The number of seconds the application will be delayed upon startup.  This is used to display the splash screen for a longer time.
#define kStartupDelay				2.0


@interface Globals : NSObject {
}

+ (NSString *)getContestPlayerObjectId;
+ (void)setContestPlayerObjectId:(NSString *)contestPlayerObjectId;
+ (void)deleteContestPlayerObjectId;


@end
