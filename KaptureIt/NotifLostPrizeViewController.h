//
//  NotifLostPrizeViewController.h
//  KaptureIt
//
//  Created by Todd Fearn on 5/20/13.
//
//

#import <UIKit/UIKit.h>
#import "Contest.h"

@interface NotifLostPrizeViewController : UIViewController {
    IBOutlet UILabel *_buttonText;
    Contest *_contest;
}
@property (nonatomic, strong) UILabel *buttonText;
@property (nonatomic, strong) Contest *contest;

@end
