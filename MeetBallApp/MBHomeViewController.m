//
//  MBHomeViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 8/27/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBHomeViewController.h"
#import "MBCredentialManager.h"
#import "MBLoginViewController.h"
#import "MBSuitUpViewController.h"
#import "MBHomeDataCommunicator.h"
#import "MBCredentialManager.h"

#import "MBUser.h"
#import "MeetBalls.h"

#import <CoreData/CoreData.h>
#import <FacebookSDK/FacebookSDK.h>


@interface MBHomeViewController ()

@property (strong, nonatomic) MBHomeDataCommunicator *homeCommLink;

@end

static NSString * const kAuthentication = @"authenticated";
static NSString * const kAppUserId = @"AppUserId";
static NSString * const kFirstName = @"FirstName";
static NSString * const kSessionId = @"sessionId";

@implementation MBHomeViewController

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
    
    if(self.userInfo){
        self.fullNameLabel.text = self.userInfo.firstName;
        self.emailLabel.text = self.userInfo.email;
    } else if ([[NSUserDefaults standardUserDefaults] objectForKey:kFirstName] && [MBCredentialManager defaultCredential]){
        self.fullNameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:kFirstName];
        self.emailLabel.text = [MBCredentialManager defaultCredential].user;
    }
    
    self.homeCommLink = [[MBHomeDataCommunicator alloc] init];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self.homeCommLink getUpcomingMeetBallsWithSuccess:^(NSDictionary *JSON) {
        if (JSON && [(NSArray *)JSON[@"Items"] count] > 0) {
            NSDictionary *meetball = [JSON[@"Items"] objectAtIndex:0];
            for (id part in meetball) {
                NSLog(@"%@ is of class %@", part, [[meetball objectForKey:part] class]);
            }
        }

//        NSLog(@"Success %@", JSON);
    } failure:^(NSError *er) {
        NSLog(@"Error upcoming meetballs %@", er);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)testCancel:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kAuthentication];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if([self.presentingViewController class] == [MBLoginViewController class] || [self.presentingViewController class] ==[MBSuitUpViewController class]){
        [self dismissViewControllerAnimated:YES completion:nil];
    } else{
        [FBSession.activeSession closeAndClearTokenInformation];
        [MBCredentialManager clearCredentials];
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"loginFlow" bundle:nil];
        UIViewController *vc = [sb instantiateInitialViewController];
        [self presentViewController:vc animated:NO completion:nil];
    }

}
@end
