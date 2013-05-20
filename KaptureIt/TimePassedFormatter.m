//
//  TimePassedFormatter.m
//  Finster
//
//  Created by Todd Fearn on 5/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TimePassedFormatter.h"


@implementation TimePassedFormatter
@synthesize formattedValue = _formattedValue;

- (id)init {
    if (self = [super init]) {
		_formattedValue = [[NSString alloc] init];
    }
    return self;
}

- (NSString *)format:(NSDate *)date {
	NSCalendar *sysCalendar = [NSCalendar currentCalendar];
	NSDate *now = [[NSDate alloc] init];
	
    // Determine months, days, etc.
	unsigned int unitFlags = NSHourCalendarUnit | NSSecondCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
	NSDateComponents *breakdownInfo = [sysCalendar components:unitFlags fromDate:date  toDate:now  options:0];
	int days = -1 * [breakdownInfo day];
	int hours = (-1 * [breakdownInfo hour]);
	int minutes = (-1 * [breakdownInfo minute]);
    int seconds = (-1 * [breakdownInfo second]);
    
    if(days < 0)
        days = 0;
    if(hours < 0)
        hours = 0;
    if(minutes < 0)
        minutes = 0;
    if(seconds < 0)
        seconds = 0;
    
	if(days > 0)
        self.formattedValue = [NSString stringWithFormat:@"%dd ", days];
    self.formattedValue = [self.formattedValue stringByAppendingFormat:@"%2.2d:%2.2d:%2.2d", hours, minutes, seconds];
	
	return self.formattedValue;
}

@end
