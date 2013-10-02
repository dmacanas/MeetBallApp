//
//  MBProfileViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/23/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBProfileViewController.h"
#import "MBMenuNavigator.h"
#import "MBMenuView.h"
#import "MBCredentialManager.h"
#import "MBWebServiceManager.h"
#import "MBWebServiceConstants.h"
#import "MBUser.h"
#import "MBEditProfileViewController.h"

#import <FacebookSDK/FacebookSDK.h>

static NSString * const kAnnotaionId = @"pinId";
static NSString * const kCarKey = @"carLocation";
static NSString * const kAuthentication = @"authenticated";
static NSString * const kAppUserId = @"AppUserId";
static NSString * const kFirstName = @"FirstName";
static NSString * const kSessionId = @"sessionId";

@interface MBProfileViewController () <MBMenuViewDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) MBMenuView *menu;
@property (assign, nonatomic) BOOL isShowingMenu;
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
    self.infoArray = [NSArray arrayWithObjects:@"Name", @"Handle", @"Phone Number", nil];
    self.loginArray = [NSArray arrayWithObjects:@"Email", @"Password", nil];
    self.mediaArray = [NSArray arrayWithObjects:@"Facebook", nil];
    self.sectionValueArray = [NSArray arrayWithObjects:self.infoArray, self.loginArray, self.mediaArray, nil];
    self.sectionArray = [NSArray arrayWithObjects:@"Personal Information", @"Login Information", @"Social Media", nil];
	// Do any additional setup after loading the view.
    [self setUpMenu];
    [self loadProfile];
}

- (void)loadProfile {
    __weak MBProfileViewController *weakSelf = self;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [MBWebServiceManager AFHTTPRequestForWebService:kWebServiceGetAppUserByAppUserId URLReplacements:@{@"version": [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"], @"sessionId":[[NSUserDefaults standardUserDefaults] objectForKey:kSessionId], @"appUserId":[[NSUserDefaults standardUserDefaults] objectForKey:kAppUserId]} success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (responseObject) {
            NSError *error;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
            if ([[dict[@"MbResult"] objectForKey:@"Success"] boolValue]) {
                NSDictionary *user = [dict[@"Items"] objectAtIndex:0];
                weakSelf.userInfo = user;
                weakSelf.userLabel.text = [NSString stringWithFormat:@"%@ %@", user[@"FirstName"],user[@"LastName"]];
                [weakSelf.tableView reloadData];
            } else {
                NSLog(@"responseObject %@", responseObject);
            }
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fumble" message:@"Error finding your stats" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
        [alert show];
        NSLog(@"error %@", error);
    }];
    
    [MBWebServiceManager AFHTTPRequestForWebService:kWebSerivceGetPhoneNumbers URLReplacements:@{@"version": [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"], @"sessionId":[[NSUserDefaults standardUserDefaults] objectForKey:kSessionId], @"appUserId":[[NSUserDefaults standardUserDefaults] objectForKey:kAppUserId]} success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
        if (responseObject) {
            NSError *error;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
            if ([[dict[@"MbResult"] objectForKey:@"Success"] boolValue]) {
//                NSDictionary *user = [dict[@"Items"] objectAtIndex:0];
//                weakSelf.userInfo = user;
//                weakSelf.userLabel.text = [NSString stringWithFormat:@"%@ %@", user[@"FirstName"],user[@"LastName"]];
//                [weakSelf.tableView reloadData];
            } else {
                NSLog(@"responseObject %@", responseObject);
            }
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fumble" message:@"Error finding your stats" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
        [alert show];
        NSLog(@"error %@", error);
    }];
}

- (void)setUpMenu
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"MBMenuView" owner:self options:nil];
    self.menu = [array objectAtIndex:0];
    self.menu.delegate = self;
    [self.menuContainer addSubview:self.menu];
}

- (void)didSelectionMenuItem:(NSString *)item {
    self.isShowingMenu = NO;
    self.menuContainer.hidden = YES;
    self.blurView.hidden = YES;
    if ([item isEqualToString:@"Profile"]) {
        return;
    }
    
    [self dismissViewControllerAnimated:NO completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"navigate" object:item];
    }];
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
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        cell.detailTextLabel.text = self.userInfo[@"Email"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
        [MBUser truncateAll];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kAuthentication];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSessionId];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAppUserId];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"signOut" object:nil];
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showMenu:(id)sender {
    if (self.isShowingMenu) {
        self.menuContainer.hidden = YES;
        self.blurView.hidden = YES;
        self.isShowingMenu = !self.isShowingMenu;
    } else {
        [self.menu createBlurViewInView:self.view forImageView:self.blurView];
        self.menuContainer.hidden = NO;
        self.blurView.hidden = NO;
        self.isShowingMenu = !self.isShowingMenu;
    }
}

- (IBAction)signout:(id)sender {
    UIAlertView *signOut = [[UIAlertView alloc] initWithTitle:@"Sign Out" message:@"Do you want to sign out?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Sign Out", nil];
    [signOut show];
}
@end
