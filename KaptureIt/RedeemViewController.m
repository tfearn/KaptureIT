//
//  RedeemViewController.m
//  KaptureIt
//
//  Created by Todd Fearn on 6/13/13.
//
//

#import "RedeemViewController.h"

@interface RedeemViewController ()

@end

@implementation RedeemViewController
@synthesize imageView = _imageView;
@synthesize messageLabel = _messageLabel;
@synthesize promoLabel = _promoLabel;
@synthesize placeLabel= _placeLabel;
@synthesize streetLabel = _streetLabel;
@synthesize cityStateZipLabel = _cityStateZipLabel;
@synthesize phoneLabel = _phoneLabel;
@synthesize prize = _prize;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create a spacer button
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [spacer setWidth:8];
    
    // Add a back button on the nav bar
    UIImage *image = [UIImage imageNamed:@"BackButton"];
    UIImage *imageHighlighted = [UIImage imageNamed:@"BackButtonHighlighted"];
    UIButton *buttonView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [buttonView addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [buttonView setBackgroundImage:image forState:UIControlStateNormal];
    [buttonView setBackgroundImage:imageHighlighted forState:UIControlStateHighlighted];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
    NSArray *leftBarButtons = [[NSArray alloc] initWithObjects:spacer, backButton, nil];
    [self.navigationItem setLeftBarButtonItems:leftBarButtons];
    
    self.navigationItem.title = @"REDEEM";
    
    [self.prize.contest.imagefile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if(error == nil) {
            UIImage *image = [UIImage imageWithData:data];
            self.imageView.image = image;
        }
    }];
    
    self.messageLabel.text = [self.prize.contest.winnerInfo.message uppercaseString];
    self.promoLabel.text = [self.prize.contest.winnerInfo.promo uppercaseString];
    self.placeLabel.text = [self.prize.contest.winnerInfo.place uppercaseString];
    self.streetLabel.text = [self.prize.contest.winnerInfo.street uppercaseString];
    self.cityStateZipLabel.text = [NSString stringWithFormat:@"%@, %@ %@",
                                   [self.prize.contest.winnerInfo.city uppercaseString],
                                   [self.prize.contest.winnerInfo.state uppercaseString],
                                   [self.prize.contest.winnerInfo.zip uppercaseString]
                                   ];
    self.phoneLabel.text = [self.prize.contest.winnerInfo.phone uppercaseString];
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)redeemButtonPressed:(id)sender {
    if(self.prize.redeemed) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Already Redeemed" message:@"This prize has already been redeemed." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // Mark as redeemed
    [self showSpinnerView];
    PFObject *prizeObject = [PFObject objectWithClassName:@"Prize"];
    [prizeObject setObjectId:self.prize.objectId];
    [prizeObject setObject:[NSNumber numberWithBool:YES] forKey:@"redeemed"];
    [prizeObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self dismissSpinnerView];

        if(error != nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Database Error" message:[error description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Redemption" message:@"Your prize has been successfully redeemed" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [self.navigationController popViewControllerAnimated:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshPrizes object:self userInfo:nil];
        }
    }];
}

- (IBAction)phoneButtonPressed:(id)sender {
    NSString *phone = [self.prize.contest.winnerInfo.phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", phone]]];
}

- (IBAction)getDirectionsButtonPressed:(id)sender {
    
    //Apple Maps, using the MKMapItem class
    
    CLLocationCoordinate2D rdLocation = CLLocationCoordinate2DMake(self.prize.contest.winnerInfo.acquireLocation.latitude, self.prize.contest.winnerInfo.acquireLocation.longitude);
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:rdLocation addressDictionary:nil];
    MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
    item.name = self.prize.contest.name;
    [item openInMapsWithLaunchOptions:nil];
}

@end
