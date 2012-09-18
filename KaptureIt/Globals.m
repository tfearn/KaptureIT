//
//  Globals.m
//  Hedge360
//
//  Created by Todd Fearn on 12/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Globals.h"

@implementation Globals

+ (void)initialize {
}

+ (NSString *)getContestPlayerObjectId {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"contest_player_object_id"];
}

+ (void)setContestPlayerObjectId:(NSString *)contestPlayerObjectId {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if (standardUserDefaults) {
		[standardUserDefaults setObject:contestPlayerObjectId forKey:@"contest_player_object_id"];
		[standardUserDefaults synchronize];
	}
}

+ (void)deleteContestPlayerObjectId {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"contest_player_object_id"];
}

@end
