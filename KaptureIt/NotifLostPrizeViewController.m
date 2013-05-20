//
//  NotifLostPrizeViewController.m
//  KaptureIt
//
//  Created by Todd Fearn on 5/20/13.
//
//

#import "NotifLostPrizeViewController.h"

@implementation NotifLostPrizeViewController
@synthesize buttonText = _buttonText;
@synthesize contest = _contest;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.buttonText.text = [NSString stringWithFormat:@"Steal it back in %ds", self.contest.shieldtime];
}

- (IBAction)continueButtonPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

@end
