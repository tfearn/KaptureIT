//
//  RedeemViewController.h
//  KaptureIt
//
//  Created by Todd Fearn on 6/13/13.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BaseViewController.h"
#import "Prize.h"

@interface RedeemViewController : BaseViewController {
    IBOutlet UIImageView *_imageView;
    IBOutlet UILabel *_messageLabel;
    IBOutlet UILabel *_promoLabel;
    IBOutlet UILabel *_placeLabel;
    IBOutlet UILabel *_streetLabel;
    IBOutlet UILabel *_cityStateZipLabel;
    IBOutlet UILabel *_phoneLabel;
    Prize *_prize;
}
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *promoLabel;
@property (nonatomic, strong) UILabel *placeLabel;
@property (nonatomic, strong) UILabel *streetLabel;
@property (nonatomic, strong) UILabel *cityStateZipLabel;
@property (nonatomic, strong) UILabel *phoneLabel;
@property (nonatomic, strong) Prize *prize;

@end
