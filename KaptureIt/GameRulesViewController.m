//
//  GameRulesViewController.m
//  KaptureIt
//
//  Created by Todd Fearn on 1/8/13.
//
//

#import "GameRulesViewController.h"

@interface GameRulesViewController ()

@end

@implementation GameRulesViewController
@synthesize scrollView = _scrollView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add a close button on the nav bar
    UIImage *image = [UIImage imageNamed:@"close2-button"];
    UIImage *imageHighlighted = [UIImage imageNamed:@"close2-button-highlighted"];
    UIButton *buttonView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [buttonView addTarget:self action:@selector(closePressed) forControlEvents:UIControlEventTouchUpInside];
    [buttonView setBackgroundImage:image forState:UIControlStateNormal];
    [buttonView setBackgroundImage:imageHighlighted forState:UIControlStateHighlighted];
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
    [self.navigationItem setLeftBarButtonItem:closeButton];
    [buttonView release];
    [closeButton release];
    
    self.scrollView.contentSize = CGSizeMake(320, 1800);
}

- (void)dealloc {
    self.scrollView = nil;
    [super dealloc];
}

- (void)closePressed {
    [self dismissModalViewControllerAnimated:YES];
}

@end
