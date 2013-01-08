//
//  GameRulesViewController.h
//  KaptureIt
//
//  Created by Todd Fearn on 1/8/13.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface GameRulesViewController : BaseViewController {
    IBOutlet UIScrollView *_scrollView;
}
@property (nonatomic, retain) UIScrollView *scrollView;

@end
