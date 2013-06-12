//
//  ProfileViewCell.h
//  KaptureIt
//
//  Created by Todd Fearn on 6/12/13.
//
//

#import <UIKit/UIKit.h>

@interface ProfileViewCell : UITableViewCell {
    IBOutlet UILabel *_title;
    IBOutlet UILabel *_subtitle;
}
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *subtitle;

@end
