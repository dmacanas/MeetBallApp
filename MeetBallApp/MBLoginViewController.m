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
    self.emailField.text = @"dominic@meetball.com";
    self.passwordField.text = @"password1";
    self.importer = [[MBDataImporter alloc] init];
    self.moc = [(MBAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];

    self.FacebookLogin.readPermissions = @[@"basic_info", @"email", @"user_mobile_phone"];
    self.FacebookLogin.delegate = self;
    
	// Do any additional setup after loading the view.
}

- (void)contextDidSave:(NSNotification *)notification {
    NSLog(@"notification %@ thread%@",notification, [NSManagedObjectContext MR_contextForCurrentThread]);
    SEL selector = @selector(mergeChangesFromContextDidSaveNotification:);
    [[NSManagedObjectContext MR_defaultContext] performSelectorOnMainThread:selector withObject:notification waitUntilDone:YES];
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
    NSLog(@"%@ thread%@",[MBUser MR_findAll], [NSManagedObjectContext MR_contextForCurrentThread]);
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
            [weakSelf launchToHomeScreenWithUser:user];
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
//        __block NSManagedObjectContext *moc = [(MBAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        __block NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [moc setParentContext:[NSManagedObjectContext MR_defaultContext]];
        __weak MBLoginViewController *weakSelf = self;
        [self.importer getUserWithCredtentials:@{@"email": self.emailField.text, @"password":self.passwordField.text} success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
        {
            [SVProgressHUD dismiss];
            if (JSON && ![[[[JSON objectForKey:@"LoginAppUserJsonResult"] objectForKey:@"MbResult"] objectForKey:@"Success"] boolValue]){
                [weakSelf handleLoginFailureWithError:[[[JSON objectForKey:@"LoginAppUserJsonResult"] objectForKey:@"MbResult"] objectForKey:@"FriendlyErrorMsg"]];
            } else if (JSON && [[[[JSON objectForKey:@"LoginAppUserJsonResult"] objectForKey:@"MbResult"] objectForKey:@"Success"] boolValue]){
                NSDictionary *user = [[[(NSDictionary *)JSON objectForKey:@"LoginAppUserJsonResult"] objectForKey:@"Items"] objectAtIndex:0];
                MBUser *mbuser = [MBUser createEntity];
                mbuser.firstName = user[@"FirstName"];
                mbuser.lastName = user[@"LastName"];
                mbuser.meetBallHandle = user[@"Handle"];
                mbuser.meetBallID = @"601";
                mbuser.facebookID = user[@"FacebookId"];
                mbuser.email = user[@"Email"];
                mbuser.phoneNumber = @"1234567890";
                [moc saveWithOptions:MRSaveParentContexts|MRSaveSynchronously completion:^(BOOL success, NSError *error) {
                    if (error) {
                        NSLog(@"error %@",error);
                    }
                }];
            }
//            MBUser *u = [MBUser MR_findFirstWithPredicate:predicate];
            //[weakSelf launchToHomeScreenWithUser:u];
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
