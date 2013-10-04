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
#import "MBWebServiceConstants.h"
#import "MBWebServiceManager.h"

#import <FacebookSDK/FacebookSDK.h>

static NSString * const kAuthentication = @"authenticated";
static NSString * const kAppUserId = @"AppUserId";
static NSString * const kFirstName = @"FirstName";

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
    self.importer = [[MBDataImporter alloc] init];

    self.FacebookLogin.delegate = self;

    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ballz.png"]]];
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
        [self login:nil];
    } else {
        [self.passwordField becomeFirstResponder];
    }
    return YES;
}

- (IBAction)cancelButtonPressed:(id)sender {
//    NSURLCredential *cred = [MBCredentialManager defaultCredential];
//    NSLog(@"%@ password %@",[MBCredentialManager defaultCredential], cred.password);
    [FBSession.activeSession closeAndClearTokenInformation];
//    [MBCredentialManager clearCredentials];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)forgotPasswordAction:(id)sender {
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSLog(@"Facebook Error");
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
    if(![[NSUserDefaults standardUserDefaults] boolForKey:kAuthentication]){
        self.progressView.hidden = NO;
        [self.progressView setProgress:0.6 animated:YES];
        __weak MBLoginViewController *weakSelf = self;
        NSDictionary *dict = @{@"facebookId": (NSDictionary *)user[@"id"],@"accessToken":[[[FBSession activeSession] accessTokenData] accessToken]};
        [self.importer getUserWithFacebookID:dict success:^(NSDictionary *JSON) {
            if(JSON){
                if([[(NSDictionary *)JSON[@"LoginAppUserFacebookJsonResult"][@"MbResult"] objectForKey:@"Success"] boolValue]){
                    [self.progressView setProgress:1 animated:YES];
                    weakSelf.email = [[JSON[@"LoginAppUserFacebookJsonResult"][@"Items"] objectAtIndex:0] objectForKey:@"Email"];
                    NSString *pwd = [[JSON[@"LoginAppUserFacebookJsonResult"][@"Items"] objectAtIndex:0] objectForKey:@"Password"];
                    [[NSUserDefaults standardUserDefaults] setObject:[[JSON[@"LoginAppUserFacebookJsonResult"][@"Items"] objectAtIndex:0] objectForKey:@"AppUserId"] forKey:kAppUserId];
                    [[NSUserDefaults standardUserDefaults] setObject:[[JSON[@"LoginAppUserFacebookJsonResult"][@"Items"] objectAtIndex:0] objectForKey:@"FirstName"] forKey:kFirstName];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    self.progressView.hidden = YES;
                    if(pwd == nil){
                        weakSelf.needsPasswordUpdate = YES;
                        [weakSelf showAlertViewToGetPassword];
                    } else {
                        [MBCredentialManager clearCredentials];
                        NSURLCredential *cred = [[NSURLCredential alloc] initWithUser:weakSelf.email password:pwd persistence:NSURLCredentialPersistencePermanent];
                        [MBCredentialManager saveCredential:cred];
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAuthentication];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [weakSelf launchHomeScreen];
                    }
                }
            }
        } failure:^(NSError *error) {
            weakSelf.progressView.hidden = YES;
            NSLog(@"ero %@",error);
        }];
    }
}

- (void)showAlertViewToGetPassword {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Password Found" message:@"Enter a password for your MeetBall Account" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
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
            [self launchHomeScreen];
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
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"login view showing logged out user");
}

- (IBAction)login:(id)sender {
    if([self isLoginFieldsValid]){
        [self.view endEditing:YES];
        self.progressView.hidden = NO;
        [self.progressView setProgress:0.6 animated:YES];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        __weak MBLoginViewController *weakSelf = self;
        [self.importer getUserWithCredtentials:@{@"email": self.emailField.text, @"password":self.passwordField.text} success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
        {
            if (JSON && ![[[[JSON objectForKey:@"LoginAppUserJsonResult"] objectForKey:@"MbResult"] objectForKey:@"Success"] boolValue]){
                weakSelf.progressView.hidden = YES;
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                [weakSelf handleLoginFailureWithError:[[[JSON objectForKey:@"LoginAppUserJsonResult"] objectForKey:@"MbResult"] objectForKey:@"FriendlyErrorMsg"]];
            } else if (JSON && [[[[JSON objectForKey:@"LoginAppUserJsonResult"] objectForKey:@"MbResult"] objectForKey:@"Success"] boolValue]){
                
                NSURLCredential *streetCred = [[NSURLCredential alloc] initWithUser:weakSelf.emailField.text password:weakSelf.passwordField.text persistence:NSURLCredentialPersistencePermanent];
                [MBCredentialManager saveCredential:streetCred];
                weakSelf.passwordField.text = @"";
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAuthentication];
                [[NSUserDefaults standardUserDefaults] setObject:[[JSON[@"LoginAppUserJsonResult"][@"Items"] objectAtIndex:0] objectForKey:@"AppUserId"] forKey:kAppUserId];
                [[NSUserDefaults standardUserDefaults] setObject:[[JSON[@"LoginAppUserJsonResult"][@"Items"] objectAtIndex:0] objectForKey:@"FirstName"] forKey:kFirstName];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [weakSelf.progressView setProgress:1 animated:YES];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                [weakSelf launchHomeScreen];
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
        {
            weakSelf.progressView.hidden = YES;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [weakSelf handleLoginFailureWithError:error.localizedDescription];
        }];
    }
}

- (void)launchHomeScreen {
    self.progressView.hidden = YES;
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"homeStoryBoard" bundle:nil];
    UIViewController *vc = [sb instantiateInitialViewController];
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)handleLoginFailureWithError:(NSString *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:error delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
    [alert show];
}

- (BOOL)isLoginFieldsValid {
    if(self.emailField.text.length > 0 && self.passwordField.text.length > 0){
        return YES;
    } else {
        return NO;
    }
}

@end
