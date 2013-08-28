//
//  MBLoginViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 8/27/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBLoginViewController.h"

#import "MBHomeViewController.h"
#import "MBAppDelegate.h"
#import "SVProgressHUD.h"
#import "MBUser.h"
#import "MBDataCommunicator.h"
#import "MBDataImporter.h"
#import "MagicalRecordShorthand.h"
#import "NSManagedObject+MagicalFinders.h"

#import <FacebookSDK/FacebookSDK.h>

@interface MBLoginViewController () <FBLoginViewDelegate>

@property (weak, nonatomic) FBLoginView *FBLogin;
@property (strong, nonatomic) MBDataImporter *importer;
@property (strong, nonatomic) NSManagedObjectContext *moc;

@end

@implementation MBLoginViewController 

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
    [self.passwordField setDelegate:self];
    [self.emailField setDelegate:self];
    self.importer = [[MBDataImporter alloc] init];
    self.moc = [NSManagedObjectContext defaultContext];
    self.importer.moc = self.moc;

    self.FacebookLogin.readPermissions = @[@"basic_info", @"email", @"user_mobile_phone"];
    self.FacebookLogin.delegate = self;
    
	// Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.passwordField){
        [self.passwordField endEditing:YES];
    } else {
        [self.passwordField becomeFirstResponder];
    }
    return YES;
}

- (IBAction)cancelButtonPressed:(id)sender {
    NSLog(@"%@",[MBUser MR_findAll]);
    [FBSession.activeSession closeAndClearTokenInformation];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSLog(@"Facebook Error");
}

-(void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
    __weak MBLoginViewController *weakSelf = self;
    if([FBSession.activeSession state] == FBSessionStateClosed){
        [self.importer getUserWithFacebookID:(NSDictionary *)user success:^(NSDictionary *JSON) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebookID == %@",(NSDictionary *)user[@"id"]];
            MBUser *user = [MBUser findFirstWithPredicate:predicate];
            [weakSelf launchToHomeScreenWithName:user.firstName withEmail:user.email];
            NSLog(@"%@",JSON);
        } failure:^(NSError *error) {
            NSLog(@"ero %@",error);
        }];
    }
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    NSLog(@"login view showing logged in user");
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    NSLog(@"login view showing logged out user");
}



- (IBAction)login:(id)sender {
    if([self isLoginFieldsValid]){
        [self.view endEditing:YES];
        [SVProgressHUD showWithStatus:@"Logging In" maskType:SVProgressHUDMaskTypeClear];
        __weak MBLoginViewController *weakSelf = self;
        [self.importer getUserWithCredtentials:@{@"email": self.emailField.text, @"password":self.passwordField.text} success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
        {
            [SVProgressHUD dismiss];
            if (JSON && ![[[[JSON objectForKey:@"LoginAppUserJsonResult"] objectForKey:@"MbResult"] objectForKey:@"Success"] boolValue]){
                [weakSelf handleLoginFailureWithError:[[[JSON objectForKey:@"LoginAppUserJsonResult"] objectForKey:@"MbResult"] objectForKey:@"FriendlyErrorMsg"]];
            }
            NSDictionary *user = [[[(NSDictionary *)JSON objectForKey:@"LoginAppUserJsonResult"] objectForKey:@"Items"] objectAtIndex:0];
            NSString *s = [NSString stringWithFormat:@"%@",user[@"AppUserId"]]; 
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"meetBallID == %@",s];
            MBUser *u = [MBUser MR_findFirstWithPredicate:predicate];
            [weakSelf launchToHomeScreenWithName:u.firstName withEmail:u.email];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
        {
            [SVProgressHUD dismiss];
            [weakSelf handleLoginFailureWithError:error.localizedDescription];
        }];
    }
}

- (void)handleLoginFailureWithError:(NSString *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:error delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
    [alert show];
}

- (void)launchToHomeScreenWithName:(NSString *)name withEmail:(NSString *)email{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"homeStoryBoard" bundle:nil];
    MBHomeViewController *home = [sb instantiateInitialViewController];
    NSDictionary *dict = @{@"name":name, @"email":email};
    home.userInfo = dict;
    
    [self presentViewController:home animated:NO completion:nil];
}

- (BOOL)isLoginFieldsValid {
    if(self.emailField.text.length > 0 && self.passwordField.text.length > 0){
        return YES;
    } else {
        return NO;
    }
}

@end
