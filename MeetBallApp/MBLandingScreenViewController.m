//
//  MBViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 8/27/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBLandingScreenViewController.h"
#import "SVProgressHUD.h"
#import "MBUser.h"

#import <FacebookSDK/FacebookSDK.h>

@interface MBLandingScreenViewController ()

@end

static NSString * const kAuthentication = @"authenticated";

@implementation MBLandingScreenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ballz.png"]]];
    
    NSLog(@"Resources %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"environment"]);
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"environment"]) {
//        [[NSUserDefaults standardUserDefaults] setObject:@"dev" forKey:@"environment"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kAuthentication]){
        __weak MBLandingScreenViewController *weakSelf = self;
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"homeStoryBoard" bundle:[NSBundle mainBundle]];
        UIViewController *vc = [sb instantiateInitialViewController];
        [weakSelf presentViewController:vc animated:NO completion:nil];
    }
}

@end
