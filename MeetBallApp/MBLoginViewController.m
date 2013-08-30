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
#import "MBCredentialManager.h"

#import <FacebookSDK/FacebookSDK.h>

static NSString * const kAuthentication = @"authenticated";
static NSString * const kAppUserId = @"AppUserId";

@interface MBLoginViewController () <FBLoginViewDelegate>

@property (weak, nonatomic) FBLoginView *FBLogin;
@property (strong, nonatomic) MBDataImporter *importer;
@property (strong, nonatomic) MBDataCommunicator *commLink;
@property (strong, nonatomic) NSManagedObjectContext *moc;
@property (strong, nonatomic) NSString *email;
@property (assign, nonatomic) BOOL needsPasswordUpdate;

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
    self.email = @"";
    self.emailField.text = @"dominic@meetball.com";
    self.passwordField.text = @"password1";
    self.importer = [[MBDataImporter alloc] init];

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
    NSURLCredential *cred = [MBCredentialManager defaultCredential];
    NSLog(@"%@ password %@",[MBCredentialManager defaultCredential], cred.password);
    [FBSession.activeSession closeAndClearTokenInformation];
    [MBCredentialManager clearCredentials];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSLog(@"Facebook Error");
}

-(void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
    [SVProgressHUD showWithStatus:@"Loading Account" maskType:SVProgressHUDMaskTypeClear];
    if(![[NSUserDefaults standardUserDefaults] boolForKey:kAuthentication]){
        __weak MBLoginViewController *weakSelf = self;
        [self.importer getUserWithFacebookID:(NSDictionary *)user success:^(NSDictionary *JSON) {
            if(JSON){
                if([JSON[@"MbResult"][@"Success"] boolValue]){
                    [SVProgressHUD dismiss];
                    weakSelf.email = [[JSON[@"Items"] objectAtIndex:0] objectForKey:@"Email"];
                    NSString *pwd = [[JSON[@"Items"] objectAtIndex:0] objectForKey:@"Password"];
                    [[NSUserDefaults standardUserDefaults] setObject:[[JSON[@"Items"] objectAtIndex:0] objectForKey:@"Email"] forKey:kAppUserId];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    if(pwd == nil){
                        weakSelf.needsPasswordUpdate = YES;
                        [weakSelf showAlertViewToGetPassword];
                    }
                }
            }
        } failure:^(NSError *error) {
            NSLog(@"ero %@",error);
        }];
    }
}

- (void)showAlertViewToGetPassword {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter a password" message:@"To use for your new MeetBall Account" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqualToString:@"Enter a password"]) {
        if (buttonIndex == 1 && [[alertView textFieldAtIndex:0] text].length > 0) {
            [MBCredentialManager clearCredentials];
            NSURLCredential *cred = [[NSURLCredential alloc] initWithUser:self.email password:[alertView textFieldAtIndex:0].text persistence:NSURLCredentialPersistencePermanent];
            [MBCredentialManager saveCredential:cred];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAuthentication];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self setFacebookAccount:@{@"AppUserId": [[NSUserDefaults standardUserDefaults] objectForKey:kAppUserId], @"password":[alertView textFieldAtIndex:0].text}];
        } else {
            [FBSession.activeSession closeAndClearTokenInformation];
        }
    }
}

- (void)setFacebookAccount:(NSDictionary *)data {
    [self.importer setUserPasswordForFacebookUser:data success:^(NSDictionary *success) {
        if(success){
            NSLog(@"%@",success);
        }
    } failure:^(NSError *er) {
        if(er){
            NSLog(@"FacebookPasswordError %@", er);
        }
    }];
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    NSLog(@"login view showing logged in user");
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kAuthentication];
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
            } else if (JSON && [[[[JSON objectForKey:@"LoginAppUserJsonResult"] objectForKey:@"MbResult"] objectForKey:@"Success"] boolValue]){
                
                NSURLCredential *streetCred = [[NSURLCredential alloc] initWithUser:weakSelf.emailField.text password:weakSelf.passwordField.text persistence:NSURLCredentialPersistencePermanent];
                [MBCredentialManager saveCredential:streetCred];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAuthentication];
                [[NSUserDefaults standardUserDefaults] setObject:[[JSON[@"LoginAppUserJsonResult"][@"Items"] objectAtIndex:0] objectForKey:@"AppUserId"] forKey:kAppUserId];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
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

- (void)launchToHomeScreenWithUser:(MBUser *)user{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"homeStoryBoard" bundle:nil];
    MBHomeViewController *home = [sb instantiateInitialViewController];
    home.userInfo = user;
    
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
