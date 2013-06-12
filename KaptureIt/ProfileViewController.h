//
//  ProfileViewController.h
//  KaptureIt
//
//  Created by Todd Fearn on 6/12/13.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "BaseViewController.h"
#import "ProfileViewCell.h"
#import "Prize.h"
#import "GameRulesViewController.h"

@interface ProfileViewController : BaseViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
    IBOutlet UIImageView *_imageView;
    IBOutlet UITableView *_tableView;
    NSMutableArray *_prizes;
}
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *prizes;

@end
