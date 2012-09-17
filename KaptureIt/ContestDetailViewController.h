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

@interface ContestDetailViewController : BaseViewController {
    IBOutlet UILabel *_titleLabel;
    IBOutlet UILabel *_subtitleLabel;
    IBOutlet UIImageView *_imageView;
    IBOutlet UILabel *_starttimeLabel;
    IBOutlet UILabel *_endtimeLabel;
    IBOutlet UITextView *_descriptionView;
    Contest *_contest;
}
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *subtitleLabel;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UILabel *starttimeLabel;
@property (nonatomic, retain) UILabel *endtimeLabel;
@property (nonatomic, retain) UITextView *descriptionView;
@property (nonatomic, retain) Contest *contest;

@end
