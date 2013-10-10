//
//  MBProfileViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/23/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBProfileViewController.h"
#import "MBCredentialManager.h"
#import "MBWebServiceManager.h"
#import "MBWebServiceConstants.h"
#import "MBUser.h"
#import "MBEditProfileViewController.h"
#import "MBMenuNaviagtionViewController.h"

#import <FacebookSDK/FacebookSDK.h>
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>

static NSString * const kAnnotaionId = @"pinId";
static NSString * const kCarKey = @"carLocation";
static NSString * const kAuthentication = @"authenticated";
static NSString * const kAppUserId = @"AppUserId";
static NSString * const kFirstName = @"FirstName";
static NSString * const kSessionId = @"sessionId";
static NSString * const kPhoneAppId = @"phoneAppId";
static NSString * const kProfilePicture = @"profilePic";

@interface MBProfileViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) NSArray *infoArray;
@property (strong, nonatomic) NSArray *loginArray;
@property (strong, nonatomic) NSArray *mediaArray;
@property (strong, nonatomic) NSArray *sectionValueArray;
@property (strong, nonatomic) NSArray *sectionArray;
@property (strong, nonatomic) NSArray *subHeaderArray;
@property (strong, nonatomic) NSDictionary *userInfo;

@property (strong, nonatomic) NSString *field;
@property (strong, nonatomic) NSString *fieldValue;

@end

@implementation MBProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.infoArray = [NSArray arrayWithObjects:@"Name", @"Username", @"Phone Number", nil];
    self.loginArray = [NSArray arrayWithObjects:@"Email", @"Password", nil];
    self.mediaArray = [NSArray arrayWithObjects:@"Facebook", nil];
    self.sectionValueArray = [NSArray arrayWithObjects:self.infoArray, self.loginArray, self.mediaArray, nil];
    self.sectionArray = [NSArray arrayWithObjects:@"Personal Information", @"Login Information", @"Social Media", nil];
    [self.navigationItem.leftBarButtonItem setTarget:(MBMenuNaviagtionViewController *)self.navigationController];
    [self.navigationItem.leftBarButtonItem setAction:@selector(showMenu)];
    CGRect frame = self.headerView.frame;
    frame.size.height = 100;
    self.headerView.frame = frame;
    [self.headerView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setTableHeaderView:self.headerView];
	// Do any additional setup after loading the view.
//    [self loadProfile];
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadProfile];
    [self setProfilePicture];

}

- (void)checkForProfilePicture {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kProfilePicture]) {
        NSURL *url = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:kProfilePicture]];
        ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
        __block UIImage *image = nil;
        [lib assetForURL:url resultBlock:^(ALAsset *asset) {
            image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
            [self.profileImageView setImage:image];
        } failureBlock:nil];
        
    }
}

- (void)setProfilePicture {
    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView.layer.cornerRadius = 30.0;
    self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profileImageView.layer.borderWidth = 0.5f;
    self.profileImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.profileImageView.layer.shouldRasterize = YES;
    self.profileImageView.clipsToBounds = YES;
    [self checkForProfilePicture];
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)loadProfile {
    __weak MBProfileViewController *weakSelf = self;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [MBWebServiceManager AFHTTPRequestForWebService:kWebServiceGetAppUserByAppUserId URLReplacements:@{@"version": [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"], @"sessionId":[[NSUserDefaults standardUserDefaults] objectForKey:kSessionId], @"appUserId":[[NSUserDefaults standardUserDefaults] objectForKey:kAppUserId]} success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
        if (responseObject) {
            NSError *error;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
            if ([[dict[@"MbResult"] objectForKey:@"Success"] boolValue]) {
                NSDictionary *user = [dict[@"Items"] objectAtIndex:0];
                weakSelf.userInfo = user;
                weakSelf.userLabel.text = [NSString stringWithFormat:@"%@ %@", user[@"FirstName"],user[@"LastName"]];
                weakSelf.handleLabel.text = user[@"Handle"];
                [weakSelf.tableView reloadData];
                
            } else {
                NSLog(@"responseObject %@", responseObject);
            }
            [MBWebServiceManager AFHTTPRequestForWebService:kWebSerivceGetPhoneNumbers URLReplacements:@{@"version": [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"], @"sessionId":[[NSUserDefaults standardUserDefaults] objectForKey:kSessionId], @"appUserId":[[NSUserDefaults standardUserDefaults] objectForKey:kAppUserId]} success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
                if (responseObject) {
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    NSError *error;
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
                    if ([[dict[@"MbResult"] objectForKey:@"Success"] boolValue]) {
                        if ([(NSArray *)dict[@"Items"] count] > 0) {
                            NSDictionary *pn = [dict[@"Items"] objectAtIndex:0];
                            [[NSUserDefaults standardUserDefaults] setObject:pn[@"PhoneAppUserId"] forKey:kPhoneAppId];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            NSMutableDictionary *d = [weakSelf.userInfo mutableCopy];
                            [d setObject:pn[@"Phone"] forKey:@"phone"];
                            weakSelf.userInfo = d;
                            [weakSelf.tableView reloadData];
                        }
                    } else {
                        NSLog(@"responseObject %@", responseObject);
                    }
                }
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                [weakSelf showError];
            }];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [weakSelf showError];
    }];
}

- (void)showError {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fumble" message:@"Error finding your stats" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
    [alert show];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    NSArray *array = [self.sectionValueArray objectAtIndex:indexPath.section];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    cell.textLabel.text = [array objectAtIndex:indexPath.row];
    [cell.textLabel setTextColor:[UIColor darkGrayColor]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if ([[array objectAtIndex:indexPath.row] isEqualToString:@"Name"]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (self.userInfo) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", self.userInfo[@"FirstName"], self.userInfo[@"LastName"]];
        }
    }
    if ([[array objectAtIndex:indexPath.row] isEqualToString:@"Facebook"]) {
        UISwitch *swtch = [[UISwitch alloc] init];
        if (self.userInfo) {
            [swtch setOn:[self.userInfo[@"Facebook"] boolValue]];
        }
        [swtch addTarget:self action:@selector(facebookLinking:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = swtch;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.section == 0 && indexPath.row == 1) {
        cell.detailTextLabel.text = self.userInfo[@"Handle"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        cell.detailTextLabel.text = self.userInfo[@"Email"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if (indexPath.section == 0 && indexPath.row == 2) {
        cell.detailTextLabel.text = self.userInfo[@"phone"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectionStyle == UITableViewCellSelectionStyleNone) {
        return;
    }
    self.field = cell.textLabel.text;
    self.fieldValue = cell.detailTextLabel.text;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self performSegueWithIdentifier:@"profileDetail" sender:nil];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 100;
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MBEditProfileViewController *vc = (MBEditProfileViewController *)[segue destinationViewController];
    vc.field = self.field;
    vc.value = self.fieldValue;
}

- (void)facebookLinking:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    if ([[FBSession activeSession] state] == FBSessionStateOpen) {
        NSLog(@"FBSession active");
        if (sw.isOn) {
            [self FBAssociateToken:[[[FBSession activeSession] accessTokenData] accessToken]];
        } else {
            [self FBDisaaociate];
        }
    } else {
        if (sw.isOn == NO) {
            [self FBDisaaociate];
            return;
        }
        FBSession *session = [[FBSession alloc] init];
        [FBSession setActiveSession:session];
        [session openWithBehavior:FBSessionLoginBehaviorWithFallbackToWebView completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (status == FBSessionStateOpen && sw.isOn) {
                [self FBAssociateToken:[[session accessTokenData] accessToken]];
            }
            
        }];
    }
}

- (void)FBAssociateToken:(NSString *)token {
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSDictionary *dict = (NSDictionary *)result;
        NSLog(@"ID %@", dict[@"id"]);
        NSDictionary *d = @{@"facebookID": dict[@"id"], @"accessToken":token, @"sessionId":[[NSUserDefaults standardUserDefaults] objectForKey:kSessionId]};
        [MBWebServiceManager AFJSONRequestForWebService:kWebServiceAssociateFacebookAcct URLReplacements:@{@"version": [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]} UserInfo:d success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
            NSLog(@"ResponseObject %@", responseObject);
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"Error %@", error);
        }];
        
    }];
}

- (void)FBDisaaociate {
    [MBWebServiceManager AFJSONRequestForWebService:kWebServiceDisassociateFacebookAcct URLReplacements:@{@"version": [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]} UserInfo:@{@"sessionId":[[NSUserDefaults standardUserDefaults] objectForKey:kSessionId]} success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
        NSLog(@"dis Response Object %@", responseObject);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"dis Error %@", error);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 1:
            return 2;
            break;
        case 2:
            return 1;
            break;
        default:
            return 3;
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sectionArray objectAtIndex:section];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [FBSession.activeSession closeAndClearTokenInformation];
        [MBCredentialManager clearCredentials];
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            [MBUser truncateAllInContext:localContext];
        }];
        
//        [MagicalRecord cleanUp];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kAuthentication];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSessionId];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAppUserId];
        [[NSUserDefaults standardUserDefaults] synchronize];
//        [MagicalRecord setupCoreDataStack];
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"loginFlow" bundle:[NSBundle mainBundle]];
        UIViewController *vc = [sb instantiateInitialViewController];
        [self presentViewController:vc animated:NO completion:^{
            [self didReceiveMemoryWarning];
        }];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *pickedImage = (UIImage *)info[@"UIImagePickerControllerOriginalImage"];
    [self.profileImageView setImage:pickedImage];
    [[NSUserDefaults standardUserDefaults] setObject:[info[@"UIImagePickerControllerReferenceURL"] absoluteString] forKey:kProfilePicture];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)signout:(id)sender {
    UIAlertView *signOut = [[UIAlertView alloc] initWithTitle:@"Sign Out" message:@"Do you want to sign out?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Sign Out", nil];
    [signOut show];
}

- (IBAction)profilePicture:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    [picker setDelegate:[self.navigationController.viewControllers objectAtIndex:0]];
    [self presentViewController:picker animated:YES completion:nil];
}
@end
