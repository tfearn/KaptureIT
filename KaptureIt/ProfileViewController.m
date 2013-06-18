//
//  ProfileViewController.m
//  KaptureIt
//
//  Created by Todd Fearn on 6/12/13.
//
//

#import "ProfileViewController.h"
#import "UIImage+Scaling.h"

#define kActionSheetUserPhoto   1
#define kActionSheetSettings    2

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
    [buttonView addTarget:self action:@selector(settingsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [buttonView setBackgroundImage:image forState:UIControlStateNormal];
    [buttonView setBackgroundImage:imageHighlighted forState:UIControlStateHighlighted];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
    NSArray *rightBarButtons = [[NSArray alloc] initWithObjects:spacer, settingsButton, nil];
    [self.navigationItem setRightBarButtonItems:rightBarButtons];
    
    // Observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:kNotificationRefreshPrizes object:nil];
    
    // User image
    PFFile *imageFile = [[PFUser currentUser] objectForKey:@"imageFile"];
    if(imageFile != nil) {
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if(error == nil) {
                UIImage *image = [UIImage imageWithData:data];
                self.imageView.image = image;
            }
        }];
    }
    
    [self refresh];
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)settingsButtonPressed:(id)sender {
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Game Rules", @"Kapture it Support", @"Logout", nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    popupQuery.tag = kActionSheetSettings;
    [popupQuery showInView:self.view];
}

- (IBAction)pictureButtonPressed:(id)sender {
    // Do we have a camera?
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
        UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose From Library", nil];
        popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        popupQuery.tag = kActionSheetUserPhoto;
        [popupQuery showInView:self.view];
    }
    else {
        // No camera, just go to the media browser
        [self startMediaBrowserFromViewController:self usingDelegate:self];
    }
}

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller usingDelegate: (id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO) || (delegate == nil) || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    mediaUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = delegate;
    
    [controller presentModalViewController: mediaUI animated: YES];
    return YES;
}

- (BOOL) startCameraControllerFromViewController:(UIViewController*) controller usingDelegate: (id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) || (delegate == nil) || (controller == nil))
        return NO;
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = delegate;
    
    [controller presentModalViewController: cameraUI animated: YES];
    return YES;
}

- (void)getData {
    [self showSpinnerView];
    
    // Retrieve the prizes
    PFQuery *query = [PFQuery queryWithClassName:@"Prize"];
    [query orderByAscending:@"startdate"];
    [query whereKey:@"userObject" equalTo:[PFObject objectWithoutDataWithClassName:@"_User" objectId:[PFUser currentUser].objectId]];
    [query whereKey:@"redeemed" equalTo:[NSNumber numberWithBool:NO]];
    [query includeKey:@"contestObject"];
    [query includeKey:@"contestObject.winnerInfoObject"];
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
        [self.tableView reloadData];
    }];
}

- (void)refresh {
	[self getData];
}

#pragma mark -
#pragma mark UIActionSheetDelegate Methods

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    if(actionSheet.tag == kActionSheetUserPhoto) {
        switch (buttonIndex) {
            case 0:
                [self startCameraControllerFromViewController:self usingDelegate:self];
                break;
                
            case 1:
                [self startMediaBrowserFromViewController:self usingDelegate:self];
                break;
                
            default:
                break;
        }
    }
    else if(actionSheet.tag == kActionSheetSettings) {
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
                
            case 2:
            {
                // Logout
                [PFUser logOut];
                [self.navigationController popToRootViewControllerAnimated:YES];
                [self performSelector:@selector(doLogin) withObject:nil afterDelay:0.5];
                break;
            }
                
            default:
                break;
        }
    }
}

- (void)doLogin {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDoLogin object:self userInfo:nil];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate Methods

// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    
    [picker dismissModalViewControllerAnimated: YES];
}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController:(UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    UIImage *originalImage, *editedImage;
    
    // Handle a still image capture
    UIImage *imageForUser = nil;
    editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
    originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
    if (editedImage)
        imageForUser = editedImage;
    else
        imageForUser = originalImage;
    
    // Set the button to the image
    [self.imageView setImage:imageForUser];
    
    [picker dismissModalViewControllerAnimated: YES];
    
    // Save the image to the User record
    [self showSpinnerView];
    UIImage *image = [imageForUser scaleAndRotateImage:imageForUser maxResolution:400];
    NSData *imageData = UIImagePNGRepresentation(image);
    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error != nil) {
            [self dismissSpinnerView];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Database Error" message:@"Error uploading the new image" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        PFUser *user = [PFUser currentUser];
        [user setObject:imageFile.url forKey:@"imageUrl"];
        [user setObject:imageFile forKey:@"imageFile"];
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self dismissSpinnerView];
            if(error != nil) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Database Error" message:@"Could not save the new image." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }];
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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
	Prize *prize = [self.prizes objectAtIndex:row];
    
	RedeemViewController *controller = [[RedeemViewController alloc] init];
	controller.prize = prize;
	[self.navigationController pushViewController:controller animated:YES];
}

@end
