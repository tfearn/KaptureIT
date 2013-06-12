//
//  ProfileViewController.m
//  KaptureIt
//
//  Created by Todd Fearn on 6/12/13.
//
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController
@synthesize imageView = _imageView;
@synthesize tableView = _tableView;
@synthesize prizes = _prizes;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"PROFILE";
    
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
    
    // Add a settings button on the nav bar
    image = [UIImage imageNamed:@"SettingsButton"];
    imageHighlighted = [UIImage imageNamed:@"SettingsButtonHighlighted"];
    buttonView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [buttonView addTarget:self action:@selector(settingsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [buttonView setBackgroundImage:image forState:UIControlStateNormal];
    [buttonView setBackgroundImage:imageHighlighted forState:UIControlStateHighlighted];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
    NSArray *rightBarButtons = [[NSArray alloc] initWithObjects:spacer, settingsButton, nil];
    [self.navigationItem setRightBarButtonItems:rightBarButtons];
    
    [self refresh];
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)settingsButtonPressed:(id)sender {
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Game Rules", @"Kapture it Support", nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.parentViewController.view];
}

- (void)getData {
    [self showSpinnerView];
    
    // Retrieve the prizes
    PFQuery *query = [PFQuery queryWithClassName:@"Prize"];
    [query orderByAscending:@"startdate"];
    //[query whereKey:@"userObject" equalTo:[PFObject objectWithoutDataWithClassName:@"_User" objectId:[PFUser currentUser].objectId]];
    [query whereKey:@"redeemed" equalTo:[NSNumber numberWithBool:NO]];
    [query includeKey:@"Contest"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self dismissSpinnerView];
        if(error != nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Database Error" message:[error description] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        self.prizes = nil;
        _prizes = [[NSMutableArray alloc] init];
        
        for(int i=0; i<[objects count]; i++) {
            PFObject *object = [objects objectAtIndex:i];
            
            Prize *prize = [[Prize alloc] init];
            [prize assignValuesFromObject:object];
            
            [self.prizes addObject:prize];
        }
        
        if([self.prizes count] == 0)
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        else
            [self.tableView reloadData];
    }];
}

- (void)refresh {
	[self getData];
}

#pragma mark -
#pragma mark UIActionSheetDelegate Methods

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
        {
            // Game Rules
            GameRulesViewController *controller = [[GameRulesViewController alloc] init];
            UINavigationController *navBar = [[UINavigationController alloc] initWithRootViewController:controller];
            [self presentModalViewController:navBar animated:YES];
            break;
        }
            
        case 1:
        {
            // Kapture it Support
            MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            [controller setToRecipients:[NSArray arrayWithObject: @"support@kaptureit.com"]];
            [controller setSubject:@"Kapture it Support Request"];
            [controller setMessageBody:@"" isHTML:NO];
            [self presentModalViewController:controller animated:YES];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate Methods

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
{
	if (result == MFMailComposeResultSent) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your e-mail message has been sent" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
	}
	
	if(error != nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"E-Mail Error" message:[error description] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
	}
	
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView: (UITableView *)tableview {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableview numberOfRowsInSection:(NSInteger)section {
    return [self.prizes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CustomCellIdentifier = @"ProfileViewCellIdentifier";
	
	int row = [indexPath row];
	Prize *prize = [self.prizes objectAtIndex:row];
    
    ProfileViewCell *cell = (ProfileViewCell *)[tableview dequeueReusableCellWithIdentifier: CustomCellIdentifier];
    if (cell == nil)  {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProfileViewCell" owner:self options:nil];
        for (id oneObject in nib)
            if ([oneObject isKindOfClass:[ProfileViewCell class]])
                cell = (ProfileViewCell *)oneObject;
    }
    
    cell.title.text = prize.contest.name;
    cell.subtitle.text = prize.contest.subtitle;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
	Prize *prize = [self.prizes objectAtIndex:row];
    
    
}

@end
