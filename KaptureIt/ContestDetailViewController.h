//
//  ContestDetailViewController.h
//  KaptureIt
//
//  Created by Todd Fearn on 9/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "Contest.h"
#import "ContestViewController.h"
#import "TimePassedFormatter.h"

@interface ContestDetailViewController : BaseViewController {
    IBOutlet UILabel *_titleLabel;
    IBOutlet UIImageView *_imageView;
    IBOutlet UILabel *_timeRemainingLabel;
    IBOutlet UIButton *_joinContestButton;
    Contest *_contest;
}
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UILabel *timeRemainingLabel;
@property (nonatomic, retain) UIButton *joinContestButton;
@property (nonatomic, retain) Contest *contest;

@end
