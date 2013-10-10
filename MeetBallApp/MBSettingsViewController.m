//
//  MBSettingsViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/23/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBSettingsViewController.h"
#import "MBMenuNavigator.h"
#import "MBMenuNaviagtionViewController.h"
#import "MBSettingsOptionsViewController.h"
#import "MBWebServiceConstants.h"
#import "MBWebServiceManager.h"

static NSString * const kSessionId = @"sessionId";
static NSString * const kFriendSorting = @"friendSorting";
static NSString * const kMeetBallSorting = @"meetBallSorting";
static NSString * const kAppUserId = @"AppUserId";

@interface MBSettingsViewController () <UITableViewDataSource, UITableViewDelegate, MBSettingsOptionDelegate>

@property (strong, nonatomic) NSArray *sectionHeaderArray;
@property (strong, nonatomic) NSArray *sectionValueArray;
@property (strong, nonatomic) NSString *option;
@property (strong, nonatomic) NSDictionary *userDefaults;
@property (assign, nonatomic) NSInteger meetBallSharing;
@property (assign, nonatomic) NSInteger locationSharing;

@end

@implementation MBSettingsViewController

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
    self.sectionHeaderArray = [NSArray arrayWithObjects:@"Sorting Settings", @"Sharing Settings", @"Notification Settings", nil];
    self.sectionValueArray = [NSArray arrayWithObjects:@[@"Friend Sorting", @"MeetBall Sorting"], @[@"My MeetBalls", @"Location"], @[@"Push Notifications", @"Text Messages", @"Email"], nil];
    [self.navigationItem.leftBarButtonItem setTarget:(MBMenuNaviagtionViewController *)self.navigationController];
    [self.navigationItem.leftBarButtonItem setAction:@selector(showMenu)];
    [self getUserDefaults];
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)getUserDefaults {
    __weak MBSettingsViewController *weakSelf = self;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [MBWebServiceManager AFHTTPRequestForWebService:kWebServiceGetUserDefaults URLReplacements:@{@"version":[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"], @"sessionId":[[NSUserDefaults standardUserDefaults] objectForKey:kSessionId]} success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
        if (responseObject) {
            NSError *error;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
            weakSelf.userDefaults = [dict[@"Items"] objectAtIndex:0];
            weakSelf.meetBallSharing = [weakSelf.userDefaults[@"MBSharingID"] integerValue];
            weakSelf.locationSharing = [weakSelf.userDefaults[@"MBRLocationSharingID"] integerValue];
            [weakSelf.tableView reloadData];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSLog(@"Error: %@", error);
    }];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sectionHeaderArray objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellId";
    NSArray *array = [self.sectionValueArray objectAtIndex:indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    cell.textLabel.text = [array objectAtIndex:indexPath.row];
    [cell.textLabel setTextColor:[UIColor darkGrayColor]];
    
    if (indexPath.section == 2) {
        UISwitch *swtch = [[UISwitch alloc] init];
        [swtch setOn:[self findOnValueForKey:cell.textLabel.text]];
        cell.accessoryView = swtch;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.tag = (indexPath.section + 1) * (indexPath.row + 3);
//    NSLog(@"cell Tag:%d text:%@",cell.tag, cell.textLabel.text);
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.sectionValueArray objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionHeaderArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectionStyle == UITableViewCellSelectionStyleNone) {
        return;
    }
    self.option = cell.textLabel.text;
    [self performSegueWithIdentifier:@"optionSegue" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MBSettingsOptionsViewController *vc = (MBSettingsOptionsViewController *)[segue destinationViewController];
    vc.optionTitle = self.option;
    vc.delegate = self;
    if ([self.option isEqualToString:@"My MeetBalls"]) {
        vc.selectedOption = self.meetBallSharing;
    } else if ([self.option isEqualToString:@"Location"]) {
        vc.selectedOption = self.locationSharing;
    }
}

- (BOOL)findOnValueForKey:(NSString *)key {
    //@[@"Push Notifications", @"Text Messages", @"Email"]
    if ([key isEqualToString:@"Push Notifications"]) {
        return [self.userDefaults[@"AppUserPushNotification"] boolValue];
    } else if ([key isEqualToString:@"Text Messages"]) {
        return [self.userDefaults[@"AppUserTextNotification"] boolValue];
    } else {
        return [self.userDefaults[@"AppUserEmailNotification"] boolValue];
    }
}

- (void)changedOptionValue:(NSInteger)value key:(NSString *)key {
    if ([key isEqualToString:@"My MeetBalls"]) {
        self.meetBallSharing = value;
    } else if ([key isEqualToString:@"Location"]) {
        self.locationSharing = value;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)save:(id)sender {
    UITableViewCell *push = (UITableViewCell *)[self.view viewWithTag:9];
    UISwitch *psw = (UISwitch *)push.accessoryView;
    UITableViewCell *text = (UITableViewCell *)[self.view viewWithTag:12];
    UISwitch *tsw = (UISwitch *)text.accessoryView;
    UITableViewCell *email = (UITableViewCell *)[self.view viewWithTag:15];
    UISwitch *esw = (UISwitch *)email.accessoryView;
    
    NSDictionary *defaults = @{@"appUserDefaultsInfo": @{
                               @"AppUserEmailNotification" : [NSString stringWithFormat:@"%d",esw.isOn],
                               @"AppUserFBNotification" : @"0",
                               @"AppUserID" : [[NSUserDefaults standardUserDefaults] objectForKey:kAppUserId],
                               @"AppUserPushNotification" : [NSString stringWithFormat:@"%d",psw.isOn],
                               @"AppUserTextNotification" : [NSString stringWithFormat:@"%d",tsw.isOn],
                               @"AppUserTwitterNotification" : @"0",
                               @"MBPrivate" : @"0",
                               @"MBRLocationSharingID" : [NSString stringWithFormat:@"%d",self.locationSharing],
                               @"MBSharingID" : [NSString stringWithFormat:@"%d",self.meetBallSharing]
                               }
                               };
    
    __weak MBSettingsViewController *weakSelf = self;
    self.progressView.hidden = NO;
    [self.progressView setProgress:0.7 animated:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [MBWebServiceManager AFJSONRequestForWebService:kWebServiceUpdateUserDefaults URLReplacements:@{@"version":[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"], @"sessionId":[[NSUserDefaults standardUserDefaults] objectForKey:kSessionId]} UserInfo:defaults success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
        if (responseObject) {
            NSDictionary *dict = (NSDictionary *)responseObject[@"UpdateAppUserDefaultsResult"];
            if ([dict[@"MbResult"][@"Success"] boolValue]) {
                [weakSelf showAlertWithTitle:@"Success" body:@"Settings Saved"];
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            } else  {
                NSLog(@"Error %@", dict);
                [weakSelf showAlertWithTitle:@"Fumble" body:dict[@"MbResult"][@"FriendlyErrorMsg"]];
            }
            weakSelf.progressView.hidden = YES;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"Error %@", error);
        weakSelf.progressView.hidden = YES;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [weakSelf showAlertWithTitle:@"Fumble" body:error.localizedDescription];
    }];
}

- (void)showAlertWithTitle:(NSString *)title body:(NSString *)body {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:body delegate:Nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
    [alert show];
}
@end
