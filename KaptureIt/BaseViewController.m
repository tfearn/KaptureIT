    //
//  BaseViewController.m
//  Hedgehog
//
//  Created by Todd Fearn on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BaseViewController.h"


@implementation UINavigationBar (BackgroundImage)
//This overridden implementation will patch up the NavBar with a custom Image instead of the title
- (void)drawRect:(CGRect)rect {
    UIImage *image = [UIImage imageNamed: @"banner.png"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}
@end


@implementation BaseViewController
@synthesize waitView = _waitView;
@synthesize spinnerView = _spinnerView;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"";
    
    if ([[UINavigationBar class]respondsToSelector:@selector(appearance)]) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"banner.png"] forBarMetrics:0];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)showWaitView:(NSString *)message {
    _waitView = [[WaitView alloc] initWithMessage: message];
    [self.view addSubview:_waitView];
    return;
    
    if(self.tabBarController.view != nil)
        [self.tabBarController.view addSubview:_waitView];
    else
        [self.view addSubview: _waitView];
}

- (void)dismissWaitView {
	if (_waitView) {
		[_waitView removeFromSuperview];
		[_waitView release];
		_waitView = nil;
	}
}

- (void)showSpinnerView {
    _spinnerView = [[SpinnerView alloc] init];
    [self.view addSubview: _spinnerView];
}

- (void)dismissSpinnerView {
	if (_spinnerView) {
		[_spinnerView removeFromSuperview];
		[_spinnerView release];
		_spinnerView = nil;
	}
}

@end
