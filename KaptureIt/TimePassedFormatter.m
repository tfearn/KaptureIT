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
	NSDate *now = [[[NSDate alloc] init] autorelease];
	
    // Determine months, days, etc.
	unsigned int unitFlags = NSHourCalendarUnit | NSSecondCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
	NSDateComponents *breakdownInfo = [sysCalendar components:unitFlags fromDate:date  toDate:now  options:0];
	int days = -1 * [breakdownInfo day];
	int hours = (-1 * [breakdownInfo hour]);
	int minutes = (-1 * [breakdownInfo minute]);
    int seconds = (-1 * [breakdownInfo second]);
    
	if(days > 0) {
		if(days > 1)
			self.formattedValue = [NSString stringWithFormat:@"%d days", days];
		else
			self.formattedValue = [NSString stringWithFormat:@"%d day", days];
	}
	else if(hours > 0) {
		if(hours > 1)
			self.formattedValue = [NSString stringWithFormat:@"%d hours", hours];
		else
			self.formattedValue = [NSString stringWithFormat:@"%d hour", hours];
        if(minutes > 1)
			self.formattedValue = [self.formattedValue stringByAppendingFormat:@", %d minutes", minutes];
        else if(hours > 0)
			self.formattedValue = [self.formattedValue stringByAppendingFormat:@", %d minute", minutes];
	}
	else if(minutes > 0) {
		if(minutes > 1)
			self.formattedValue = [NSString stringWithFormat:@"%d minutes", minutes];
		else
			self.formattedValue= [NSString stringWithFormat:@"%d minute", minutes];
        if(seconds > 1)
			self.formattedValue = [self.formattedValue stringByAppendingFormat:@", %d seconds", seconds];
        else if(seconds > 0)
			self.formattedValue = [self.formattedValue stringByAppendingFormat:@", %d second", seconds];
	}
	else {
		if(seconds > 1)
			self.formattedValue = [NSString stringWithFormat:@"%d seconds", seconds];
		else if(seconds == 1)
			self.formattedValue= [NSString stringWithFormat:@"%d second", seconds];
        else if(seconds <= 0)
            self.formattedValue = @"0 seconds";
	}
    
    self.formattedValue = [self.formattedValue stringByAppendingString:@" left"];
	
	return self.formattedValue;
}

- (void)dealloc {
	[_formattedValue release];
	[super dealloc];
}

@end
