//
//  BaseViewController.h
//  Hedgehog
//
//  Created by Todd Fearn on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Globals.h"
#import "WaitView.h"
#import "SpinnerView.h"


@interface BaseViewController : UIViewController {
    WaitView *_waitView;
	SpinnerView *_spinnerView;
}
@property (nonatomic, readonly) WaitView *waitView;
@property (nonatomic, readonly) SpinnerView *spinnerView;

- (void)showWaitView:(NSString *)message;
- (void)dismissWaitView;
- (void)showSpinnerView;
- (void)dismissSpinnerView;

@end
